Sequel.migration do
  up do
    run <<-SQL
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
    source_type,
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
    'manual_entry',
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

  if event.source_type <> 'manual_entry' then
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
SQL
  end

  down do
  end
end
