Sequel.migration do
  up do
    run <<-SQL
-- Create functions --

/**
 * Returns copy of the given JSON value without elements which value is null.
 *
 * @param json
 * @return json
 */
create or replace function json_compact(json)
returns json as $$

declare
  result json;
begin
  select json_object_agg(key, value)
  into result
  from json_each($1)
  where json_typeof(value) != 'null';

  return result;
end;

$$ language plpgsql strict
   immutable;

/**
 * Creates room entry if does not exist yet.
 *
 * @param _room_code {text} KOS code of the room (e.g. T9:105a).
 */
create or replace function create_room_if_not_exist(_room_code rooms.id%TYPE)
returns void as $$
begin
  if not exists(select id from rooms where id = btrim(_room_code)) then
    raise notice 'Sirius does not know room with code %, it will be created.',
      _room_code;

    insert into rooms (id, created_at, updated_at)
    values (btrim(_room_code), now(), now());
  end if;
end;
$$ language plpgsql strict;


/**
 * Recalculates relative_sequence_number for all events belonging to
 * the specified parallel.
 *
 * @param _parallel_id {bigint} KOS (database) ID of the parallel.
 */
create or replace function renumber_events(_parallel_id events.parallel_id%TYPE)
returns void as $$
begin
  with positions as (
    select
      id,
      row_number() over (
        partition by event_type, course_id, parallel_id
        order by starts_at
      ) as position
    from events
    where deleted = false and parallel_id = _parallel_id
  )
  update events
    set relative_sequence_number = p.position
  from positions p
  where p.id = events.id;
end;
$$ language plpgsql strict;


/**
 * Creates a event associated to an existing parallel.
 *
 * @param _parallel_id {bigint} KOS (database) ID of the parallel.
 * @param _starts_at {timestamp without time zone} When the event starts.
 * @param _ends_at {timestamp without time zone} When the event ends.
 * @param _room_code {text} KOS code of the room (e.g. T9:105a).
 * @return {bigint} ID of the created event.
 */
create or replace function create_event (
  _parallel_id  events.parallel_id%TYPE,
  _starts_at    events.starts_at%TYPE,
  _ends_at      events.ends_at%TYPE,
  _room_code    events.room_id%TYPE
)
returns events.id%TYPE as $$

declare
  event_id  events.id%TYPE;
  par       parallels%ROWTYPE;

begin
  select * into par from parallels where id = _parallel_id;
  if not found then
    raise exception 'Sirius does not know parallel with id = %.', _parallel_id;
  end if;

  select id into event_id from events
  where parallel_id = _parallel_id
    and (_starts_at, _ends_at) overlaps (starts_at, ends_at)
  limit 1;
  if found then
    raise notice 'The specified time range overlaps with existing event of this parallel; id = %.',
      event_id;
  end if;

  perform create_room_if_not_exist(_room_code);

  raise notice 'Creating event of type % for course % in semester %.',
    par.parallel_type, par.course_id, par.semester;

  insert into events (
    starts_at,
    ends_at,
    created_at,
    updated_at,
    teacher_ids,
    student_ids,
    event_type,
    parallel_id,
    course_id,
    semester,
    faculty,
    capacity,
    room_id
  ) values (
    _starts_at,
    _ends_at,
    now(),
    now(),
    par.teacher_ids,
    par.student_ids,
    par.parallel_type,
    _parallel_id,
    par.course_id,
    par.semester,
    par.faculty,
    par.capacity,
    _room_code
  ) returning id into event_id;

  insert into audits (action, table_name, primary_key, changed_values)
  values ('I', 'events', event_id, json_build_object(
      'starts_at', _starts_at,
      'ends_at', _ends_at,
      'parallel_id', _parallel_id,
      'room_id', _room_code
    )::jsonb);

  perform renumber_events(_parallel_id);

  return event_id;
end;
$$ language plpgsql strict
    security definer
    set search_path = public, pg_temp;


/**
 * Updates some attributes of manually inserted event.
 *
 * @param _event_id {bigint} ID of the event to be updated.
 * @param _starts_at {timestamp without time zone} When the event starts.
 *        If null, then this attribute will not be modified. Defaults to null.
 * @param _ends_at {timestamp without time zone} When the event ends. If null,
 *        then this attribute will not be modified. Defaults to null.
 * @param _room_code {text} KOS code of the room (e.g. T9:105a). If null, then
 *        this attribute will not be modified. Defaults to null.
 * @param _deleted {boolean} Flag if the event is deleted (true), or not (false).
 *        Defaults to false.
 */
create or replace function update_event (
  _event_id   events.id%TYPE,
  _starts_at  events.starts_at%TYPE  default null,
  _ends_at    events.ends_at%TYPE    default null,
  _room_code  events.room_id%TYPE    default null,
  _deleted    events.deleted%TYPE    default null
)
returns void as $$

declare
  event events%ROWTYPE;
  field text;
  changes jsonb;

begin
  select * into event from events where id = _event_id;
  if not found then
    raise exception 'Event with id = % does not exist.', _event_id;
  end if;

  -- XXX: Stupid heuristic, 'cause we do not distinguish between generated
  -- manually inserted events yet.
  if event.parallel_id is null or event.timetable_slot_id is not null then
    raise exception 'This does not look like a manually inserted event, you cannot modify it.';
  end if;

  perform create_room_if_not_exist(_room_code);

  update events set
    starts_at  = coalesce(_starts_at, event.starts_at),
    ends_at    = coalesce(_ends_at, event.ends_at),
    room_id    = coalesce(_room_code, event.room_id),
    deleted    = coalesce(_deleted, event.deleted),
    updated_at = now()
  where id = _event_id;

  insert into audits (action, table_name, primary_key, changed_values)
  values ('U', 'events', _event_id,
      json_compact(json_build_object(
        'starts_at', _starts_at,
        'ends_at', _ends_at,
        'room_id', _room_code,
        'deleted', _deleted
      ))::jsonb
  );

  perform renumber_events(event.parallel_id);
end;
$$ language plpgsql
    security definer
    set search_path = public, pg_temp;


/**
 * Creates a schedule exception of the type TEACHER_CHANGE for the given
 * timetable slots.
 *
 * @see https://github.com/cvut/sirius/blob/master/docs/schedule-exceptions.adoc
 *
 * @param _teacher_ids {text[]} An array of teachers usernames that will
 *        override value from the timetable slot(s) (imported from KOS). It may
 *        be empty, but not null.
 * @param _timetable_slot_ids {bigint[]} An array of timetable slot IDs for
 *        which the exception should be applied.
 * @param _starts_at {timestamp without time zone} If provided, then the exception
 *        will be applied only to events that starts after this date (optional).
 * @param _ends_at {timestamp without time zone} If provided, then the exception
 *        will be applied only to events that ends before this date (optional).
 * @param _name {text} Name of the exception (optional).
 * @param _note {text} Note (optional).
 * @return {bigint} ID of the created exception.
 */
create or replace function create_exception_teacher_change (
  _teacher_ids text[],
  _timetable_slot_ids bigint[],
  _starts_at schedule_exceptions.starts_at%TYPE default null,
  _ends_at schedule_exceptions.ends_at%TYPE default null,
  _name schedule_exceptions.name%TYPE default null,
  _note schedule_exceptions.note%TYPE default null
)
returns schedule_exceptions.id%TYPE as $$

declare
  _teacher_id text;
  _slot_id bigint;
  _faculty schedule_exceptions.faculty%TYPE;
  _semester schedule_exceptions.semester%TYPE;
  _exception_id schedule_exceptions.id%TYPE;
  _options hstore;

begin
  foreach _teacher_id in array _teacher_ids loop
    if not exists (select * from people where id = _teacher_id) then
      raise exception 'Sirius does not know person with id = %.', _teacher_id;
    end if;
  end loop;

  foreach _slot_id in array _timetable_slot_ids loop
    if not exists (select * from timetable_slots where id = _slot_id) then
      raise exception 'Sirius does not know timetable slot with id = %.', _slot_id;
    end if;
  end loop;

  perform distinct p.faculty, p.semester
    from timetable_slots s join parallels p on p.id = s.parallel_id
    where s.id = any(_timetable_slot_ids)
    offset 1;
  if found then
    raise exception 'All the given timetable slots must be in the same semester and faculty.';
  end if;

  select into _faculty, _semester
      p.faculty, p.semester
    from timetable_slots s join parallels p on p.id = s.parallel_id
    where s.id = _timetable_slot_ids[1];

  select format('"teacher_ids"=>"{%s}"', array_to_string(_teacher_ids, ','))::hstore into _options;

  insert into schedule_exceptions (
    exception_type,
    name,
    note,
    starts_at,
    ends_at,
    faculty,
    semester,
    timetable_slot_ids,
    options,
    created_at,
    updated_at
  ) values (
    3,
    _name,
    _note,
    _starts_at,
    _ends_at,
    _faculty,
    _semester,
    _timetable_slot_ids,
    _options,
    now(),
    now()
  ) returning id into _exception_id;

  insert into audits (action, table_name, primary_key, changed_values)
    values ('I', 'schedule_exceptions', _exception_id,
      json_compact(json_build_object(
        'exception_type', 3,
        'starts_at', _starts_at,
        'ends_at', _ends_at,
        'timetable_slot_ids', _timetable_slot_ids,
        'options', _options
      ))::jsonb
    );

  return _exception_id;
end;
$$ language plpgsql
    security definer
    set search_path = public, pg_temp;


/**
 * Creates a schedule exception of the type TEACHER_CHANGE for a timetable slot
 * and date range infered from the specified event.
 *
 * @param _teacher_ids {text[]} An array of teachers usernames that will
 *        override value from the event's timetable slot(s) (imported from
 *        KOS). It may be empty, but not null.
 * @param _event_id {bigint} ID of the event to infer exception scope from.
 * @param _name {text} Name of the exception (optional).
 * @param _note {text} Note (optional).
 * @return {bigint} ID of the created exception.
 */
create or replace function create_exception_teacher_change (
  _teacher_ids text[],
  _event_id events.id%TYPE,
  _name schedule_exceptions.name%TYPE default null,
  _note schedule_exceptions.note%TYPE default null
)
returns schedule_exceptions.id%TYPE as $$

declare
  _exception_id schedule_exceptions.id%TYPE;

begin
  select into _exception_id
    create_exception_teacher_change(
      _teacher_ids := _teacher_ids,
      _timetable_slot_ids := ARRAY[timetable_slot_id],
      _starts_at := date_trunc('week', starts_at),
      _ends_at := date_trunc('week', ends_at) + '7 days'::interval,
      _name := _name,
      _note := _note
    )
    from events where id = _event_id;

  if not found then
    raise exception 'Sirius does not know event with id = %.', _event_id;
  end if;

  return _exception_id;
end;
$$ language plpgsql
    security definer
    set search_path = public, pg_temp;


/**
 * Deletes a schedule exception. This operation is NOT revertable!
 *
 * @param _exception_id {bigint} ID of the schedule exception to delete.
 */
create or replace function delete_exception (
  _exception_id schedule_exceptions.id%TYPE
)
returns void as $$

declare
  _changed_values jsonb;

begin
  select to_jsonb(t) into _changed_values
    from schedule_exceptions t where t.id = _exception_id;
  if not found then
    raise exception 'Sirius does not know schedule exception with id = %.', _exception_id;
  end if;

  delete from schedule_exceptions where id = _exception_id;

  -- write audit log
  insert into audits (action, table_name, primary_key, changed_values)
    values ('D', 'schedule_exceptions', _exception_id, _changed_values);

end;
$$ language plpgsql
    security definer
    set search_path = public, pg_temp;
SQL
  end

  down do
    run <<-SQL
      DROP FUNCTION IF EXISTS create_event(_parallel_id bigint, _starts_at timestamp
        without time zone, _ends_at timestamp without time zone, _room_code text);
      DROP FUNCTION IF EXISTS create_room_if_not_exist(_room_code text);
      DROP FUNCTION IF EXISTS json_compact(json);
      DROP FUNCTION IF EXISTS renumber_events(_parallel_id bigint);
      DROP FUNCTION IF EXISTS update_event(_event_id bigint, _starts_at timestamp
        without time zone, _ends_at timestamp without time zone, _room_code text, _deleted boolean);
      DROP FUNCTION IF EXISTS create_exception_teacher_change(_teacher_ids text[],
        _timetable_slot_ids bigint[],
        _starts_at schedule_exceptions.starts_at%TYPE,
        _ends_at schedule_exceptions.ends_at%TYPE,
        _name schedule_exceptions.name%TYPE,
        _note schedule_exceptions.note%TYPE);
      DROP FUNCTION IF EXISTS create_exception_teacher_change(_teacher_ids text[],
        _event_id events.id%TYPE,
        _name schedule_exceptions.name%TYPE,
        _note schedule_exceptions.note%TYPE);
      DROP FUNCTION IF EXISTS delete_exception(_exception_id schedule_exceptions.id%TYPE);
    SQL
  end
end
