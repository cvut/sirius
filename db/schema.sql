--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.5.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--



--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--



--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--



SET search_path = public, pg_catalog;

--
-- Name: event_source_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE event_source_type AS ENUM (
    'manual_entry',
    'timetable_slot',
    'course_event',
    'exam',
    'teacher_timetable_slot'
);


--
-- Name: event_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE event_type AS ENUM (
    'lecture',
    'tutorial',
    'laboratory',
    'course_event',
    'exam',
    'assessment',
    'teacher_timetable_slot'
);


--
-- Name: exception_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE exception_type AS ENUM (
    'cancel',
    'relative_move',
    'room_change',
    'teacher_change'
);


--
-- Name: parallel_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE parallel_type AS ENUM (
    'lecture',
    'tutorial',
    'laboratory'
);


--
-- Name: parity; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE parity AS ENUM (
    'both',
    'odd',
    'even'
);


--
-- Name: semester_period_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE semester_period_type AS ENUM (
    'teaching',
    'exams',
    'holiday'
);



--
-- Name: create_event(bigint, timestamp without time zone, timestamp without time zone, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_event(_parallel_id bigint, _starts_at timestamp without time zone, _ends_at timestamp without time zone, _room_code text) RETURNS bigint
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO public, pg_temp
    AS $$

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
$$;


--
-- Name: create_exception_teacher_change(text[], bigint, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_exception_teacher_change(_teacher_ids text[], _event_id bigint, _name text DEFAULT NULL::text, _note text DEFAULT NULL::text) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO public, pg_temp
    AS $$

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
$$;


--
-- Name: create_exception_teacher_change(text[], bigint[], timestamp without time zone, timestamp without time zone, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_exception_teacher_change(_teacher_ids text[], _timetable_slot_ids bigint[], _starts_at timestamp without time zone DEFAULT NULL::timestamp without time zone, _ends_at timestamp without time zone DEFAULT NULL::timestamp without time zone, _name text DEFAULT NULL::text, _note text DEFAULT NULL::text) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO public, pg_temp
    AS $$

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
    'teacher_change',
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
        'exception_type', 'teacher_change',
        'starts_at', _starts_at,
        'ends_at', _ends_at,
        'timetable_slot_ids', _timetable_slot_ids,
        'options', _options
      ))::jsonb
    );

  return _exception_id;
end;
$$;


--
-- Name: create_room_if_not_exist(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_room_if_not_exist(_room_code text) RETURNS void
    LANGUAGE plpgsql STRICT
    AS $$
begin
  if not exists(select id from rooms where id = btrim(_room_code)) then
    raise notice 'Sirius does not know room with code %, it will be created.',
      _room_code;

    insert into rooms (id, created_at, updated_at)
    values (btrim(_room_code), now(), now());
  end if;
end;
$$;


--
-- Name: delete_exception(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delete_exception(_exception_id bigint) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO public, pg_temp
    AS $$

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
$$;


--
-- Name: json_compact(json); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION json_compact(json) RETURNS json
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $_$

declare
  result json;
begin
  select json_object_agg(key, value)
  into result
  from json_each($1)
  where json_typeof(value) != 'null';

  return result;
end;

$_$;


--
-- Name: renumber_events(bigint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION renumber_events(_parallel_id bigint) RETURNS void
    LANGUAGE plpgsql STRICT
    AS $$
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
$$;


--
-- Name: update_event(bigint, timestamp without time zone, timestamp without time zone, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_event(_event_id bigint, _starts_at timestamp without time zone DEFAULT NULL::timestamp without time zone, _ends_at timestamp without time zone DEFAULT NULL::timestamp without time zone, _room_code text DEFAULT NULL::text, _deleted boolean DEFAULT NULL::boolean) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO public, pg_temp
    AS $$

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
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: audits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE audits (
    id bigint NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    user_id text DEFAULT ("session_user"())::text NOT NULL,
    action text NOT NULL,
    table_name text NOT NULL,
    primary_key text NOT NULL,
    changed_values jsonb
);


--
-- Name: audits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE audits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE audits_id_seq OWNED BY audits.id;


--
-- Name: courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE courses (
    id text NOT NULL,
    department text,
    name hstore NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE courses_id_seq OWNED BY courses.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE events (
    id bigint NOT NULL,
    name hstore,
    note hstore,
    starts_at timestamp without time zone NOT NULL,
    ends_at timestamp without time zone NOT NULL,
    absolute_sequence_number integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    teacher_ids text[],
    student_ids text[],
    relative_sequence_number integer,
    deleted boolean DEFAULT false NOT NULL,
    event_type event_type NOT NULL,
    parallel_id bigint,
    course_id text,
    semester text NOT NULL,
    faculty integer,
    capacity integer,
    room_id text,
    applied_schedule_exception_ids bigint[],
    original_starts_at timestamp without time zone,
    original_ends_at timestamp without time zone,
    original_room_id text,
    source_type event_source_type NOT NULL,
    source_id text
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: faculty_semesters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE faculty_semesters (
    id integer NOT NULL,
    code text NOT NULL,
    faculty integer NOT NULL,
    update_parallels boolean DEFAULT true NOT NULL,
    first_week_parity parity NOT NULL,
    starts_at date NOT NULL,
    teaching_ends_at date NOT NULL,
    exams_start_at date NOT NULL,
    exams_end_at date,
    ends_at date NOT NULL,
    hour_starts time without time zone[] NOT NULL,
    hour_duration integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    update_other boolean DEFAULT false NOT NULL
);


--
-- Name: faculty_semesters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE faculty_semesters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: faculty_semesters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE faculty_semesters_id_seq OWNED BY faculty_semesters.id;


--
-- Name: parallels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE parallels (
    id bigint NOT NULL,
    parallel_type parallel_type NOT NULL,
    course_id text NOT NULL,
    code integer NOT NULL,
    capacity integer,
    occupied integer,
    semester text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    teacher_ids text[],
    student_ids text[],
    faculty integer NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: parallels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE parallels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parallels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE parallels_id_seq OWNED BY parallels.id;


--
-- Name: people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE people (
    id text NOT NULL,
    full_name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    access_token uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rooms (
    id text NOT NULL,
    name hstore,
    capacity hstore,
    division text,
    locality text,
    type text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: schedule_exceptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schedule_exceptions (
    id bigint NOT NULL,
    exception_type exception_type NOT NULL,
    name text NOT NULL,
    note text,
    starts_at timestamp without time zone,
    ends_at timestamp without time zone,
    faculty integer,
    semester text,
    timetable_slot_ids bigint[],
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    options hstore,
    course_ids text[]
);


--
-- Name: schedule_exceptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE schedule_exceptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedule_exceptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE schedule_exceptions_id_seq OWNED BY schedule_exceptions.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    filename text NOT NULL
);


--
-- Name: semester_periods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE semester_periods (
    id bigint NOT NULL,
    faculty_semester_id integer NOT NULL,
    starts_at date NOT NULL,
    ends_at date NOT NULL,
    type semester_period_type NOT NULL,
    first_week_parity parity,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    first_day_override integer,
    irregular boolean DEFAULT false NOT NULL,
    name hstore
);


--
-- Name: semester_periods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE semester_periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: semester_periods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE semester_periods_id_seq OWNED BY semester_periods.id;


--
-- Name: timetable_slots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE timetable_slots (
    id bigint NOT NULL,
    day integer NOT NULL,
    parity parity,
    first_hour integer,
    duration integer,
    parallel_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    room_id text,
    deleted_at timestamp without time zone,
    start_time time without time zone,
    end_time time without time zone,
    weeks integer[]
);


--
-- Name: timetable_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE timetable_slots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: timetable_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE timetable_slots_id_seq OWNED BY timetable_slots.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY audits ALTER COLUMN id SET DEFAULT nextval('audits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses ALTER COLUMN id SET DEFAULT nextval('courses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY faculty_semesters ALTER COLUMN id SET DEFAULT nextval('faculty_semesters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY parallels ALTER COLUMN id SET DEFAULT nextval('parallels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedule_exceptions ALTER COLUMN id SET DEFAULT nextval('schedule_exceptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY semester_periods ALTER COLUMN id SET DEFAULT nextval('semester_periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY timetable_slots ALTER COLUMN id SET DEFAULT nextval('timetable_slots_id_seq'::regclass);


--
-- Name: audits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- Name: courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: events_faculty_source_type_source_id_absolute_sequence_numb_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_faculty_source_type_source_id_absolute_sequence_numb_key UNIQUE (faculty, source_type, source_id, absolute_sequence_number);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: faculty_semesters_code_faculty_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY faculty_semesters
    ADD CONSTRAINT faculty_semesters_code_faculty_key UNIQUE (code, faculty);


--
-- Name: faculty_semesters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY faculty_semesters
    ADD CONSTRAINT faculty_semesters_pkey PRIMARY KEY (id);


--
-- Name: parallels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parallels
    ADD CONSTRAINT parallels_pkey PRIMARY KEY (id);


--
-- Name: people_access_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_access_token_key UNIQUE (access_token);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: schedule_exceptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedule_exceptions
    ADD CONSTRAINT schedule_exceptions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (filename);


--
-- Name: semester_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY semester_periods
    ADD CONSTRAINT semester_periods_pkey PRIMARY KEY (id);


--
-- Name: timetable_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY timetable_slots
    ADD CONSTRAINT timetable_slots_pkey PRIMARY KEY (id);


--
-- Name: events_absolute_sequence_number_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_absolute_sequence_number_index ON events USING btree (absolute_sequence_number);


--
-- Name: events_applied_schedule_exception_ids_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_applied_schedule_exception_ids_index ON events USING gin (applied_schedule_exception_ids);


--
-- Name: events_course_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_course_id_index ON events USING btree (course_id);


--
-- Name: events_faculty_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_faculty_index ON events USING btree (faculty);


--
-- Name: events_room_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_room_id_index ON events USING btree (room_id);


--
-- Name: events_semester_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_semester_index ON events USING btree (semester);


--
-- Name: events_source_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_source_id_index ON events USING btree (source_id);


--
-- Name: events_source_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_source_type_index ON events USING btree (source_type);


--
-- Name: events_student_ids_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_student_ids_index ON events USING gin (student_ids);


--
-- Name: events_teacher_ids_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX events_teacher_ids_index ON events USING gin (teacher_ids);


--
-- Name: faculty_semesters_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX faculty_semesters_code_index ON faculty_semesters USING btree (code);


--
-- Name: faculty_semesters_faculty_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX faculty_semesters_faculty_index ON faculty_semesters USING btree (faculty);


--
-- Name: parallels_deleted_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX parallels_deleted_at_index ON parallels USING btree (deleted_at);


--
-- Name: parallels_faculty_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX parallels_faculty_index ON parallels USING btree (faculty);


--
-- Name: parallels_student_ids_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX parallels_student_ids_index ON parallels USING gin (student_ids);


--
-- Name: parallels_teacher_ids_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX parallels_teacher_ids_index ON parallels USING gin (teacher_ids);


--
-- Name: semester_periods_faculty_semester_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX semester_periods_faculty_semester_id_index ON semester_periods USING btree (faculty_semester_id);


--
-- Name: semester_periods_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX semester_periods_type_index ON semester_periods USING btree (type);


--
-- Name: timetable_slots_deleted_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX timetable_slots_deleted_at_index ON timetable_slots USING btree (deleted_at);


--
-- Name: events_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: events_parallel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_parallel_id_fkey FOREIGN KEY (parallel_id) REFERENCES parallels(id);


--
-- Name: events_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_room_id_fkey FOREIGN KEY (room_id) REFERENCES rooms(id);


--
-- Name: parallels_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parallels
    ADD CONSTRAINT parallels_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: semester_periods_faculty_semester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY semester_periods
    ADD CONSTRAINT semester_periods_faculty_semester_id_fkey FOREIGN KEY (faculty_semester_id) REFERENCES faculty_semesters(id);


--
-- Name: timetable_slots_parallel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY timetable_slots
    ADD CONSTRAINT timetable_slots_parallel_id_fkey FOREIGN KEY (parallel_id) REFERENCES parallels(id);


--
-- Name: timetable_slots_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY timetable_slots
    ADD CONSTRAINT timetable_slots_room_id_fkey FOREIGN KEY (room_id) REFERENCES rooms(id);


--
-- PostgreSQL database dump complete
--

SET search_path = "$user", public;

INSERT INTO "schema_migrations" ("filename") VALUES ('1409657056_fix_array_indexes.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1410088335_create_tokens.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1410433713_add_options_to_schedule_exceptions.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1410790752_rename_parallel_ids_to_timetable_slot_ids.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1410795097_add_course_ids_to_schedule_exceptions.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1410867754_tokens_timestamp.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1411132487_ids_to_bigint.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1411147098_events_id_to_bigint.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1411506543_parallel_id_to_bigint.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1411653818_add_faculty_semesters.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1412095059_change_teacher_student_ids_type.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1412725971_add_semester_and_faculty_to_events.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1412730258_add_faculty_to_parallel.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1413467599_add_indexes_to_events.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1415024054_add_capacity_to_events.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1419305160_add_source_to_events.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1420032483_add_index_to_events_source.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1420765805_set_events_deleted_as_not_null_default_false.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1421860982_add_faculty_semester_planning_parametrization.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1422545075_change_rooms_primary_key_to_kos_code.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1424431659_change_events_name_note_to_hstore.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1433519124_add_applied_schedule_exception_ids_to_events.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1434994575_add_original_fields_to_events.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1441021231_create_semester_periods.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1442325052_add_access_token_to_people.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1443194817_add_deleted_at_to_parallels_and_timetable_slots.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1443807443_add_first_day_override_to_semester_periods.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1444408228_add_indexes_to_events.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1454511860_add_irregular_to_semester_periods.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1457024495_add_gin_index_to_applied_schedule_exception_ids.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1465481874_create_audits_if_not_exists.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1465486180_split_source_in_events.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1467309659_import_event_functions.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1467309979_update_event_functions.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1467312179_remove_source_timetable_slot_id.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1467918523_add_absolute_sequence_numbers_to_course_events_exams.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1469128840_remove_unused_tables.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1469130929_add_not_null_constraints.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1469463514_convert_text_to_enum.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1469465920_convert_schedule_exception_type_to_enum.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1469470701_convert_parities_to_enum.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1493051746_convert_semester_period_type_to_enum.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1499120813_add_name_to_semester_periods.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1599665760_add_start_time_and_end_time_to_timetable_slots.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1599920640_allow_null_for_change_first_hour_and_duration.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1601543796_add_weeks_to_timetable_slots.rb');
INSERT INTO "schema_migrations" ("filename") VALUES ('1601552486_allow_null_for_parity_in_timetable_slots.rb');
