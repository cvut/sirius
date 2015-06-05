--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

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



SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: courses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE courses (
    id text NOT NULL,
    department text,
    name hstore,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id bigint NOT NULL,
    name hstore,
    note hstore,
    starts_at timestamp without time zone,
    ends_at timestamp without time zone,
    absolute_sequence_number integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    teacher_ids text[],
    student_ids text[],
    relative_sequence_number integer,
    deleted boolean DEFAULT false NOT NULL,
    event_type text,
    parallel_id bigint,
    timetable_slot_id bigint,
    course_id text,
    semester text,
    faculty integer,
    capacity integer,
    source hstore,
    room_id text,
    applied_schedule_exception_ids bigint[]
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
-- Name: faculty_semesters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE faculty_semesters (
    id integer NOT NULL,
    code text,
    faculty integer,
    update_parallels boolean DEFAULT true,
    first_week_parity integer,
    starts_at date,
    teaching_ends_at date,
    exams_start_at date,
    exams_end_at date,
    ends_at date,
    hour_starts time without time zone[],
    hour_duration integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
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
-- Name: parallels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE parallels (
    id bigint NOT NULL,
    parallel_type text,
    course_id text,
    code integer,
    capacity integer,
    occupied integer,
    semester text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    teacher_ids text[],
    student_ids text[],
    faculty integer
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
-- Name: people; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE people (
    id text NOT NULL,
    full_name text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rooms (
    id text NOT NULL,
    name hstore,
    capacity hstore,
    division text,
    locality text,
    type text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: schedule_exceptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schedule_exceptions (
    id bigint NOT NULL,
    exception_type integer,
    name text,
    note text,
    starts_at timestamp without time zone,
    ends_at timestamp without time zone,
    faculty integer,
    semester text,
    timetable_slot_ids bigint[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
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
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    filename text NOT NULL
);


--
-- Name: timetable_slots; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE timetable_slots (
    id bigint NOT NULL,
    day integer,
    parity integer,
    first_hour integer,
    duration integer,
    parallel_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    room_id text
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
-- Name: tokens; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tokens (
    uuid uuid NOT NULL,
    username text,
    last_used_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: update_logs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE update_logs (
    id bigint NOT NULL,
    type integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: update_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE update_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: update_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE update_logs_id_seq OWNED BY update_logs.id;


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

ALTER TABLE ONLY timetable_slots ALTER COLUMN id SET DEFAULT nextval('timetable_slots_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY update_logs ALTER COLUMN id SET DEFAULT nextval('update_logs_id_seq'::regclass);


--
-- Name: courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: faculty_semesters_code_faculty_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY faculty_semesters
    ADD CONSTRAINT faculty_semesters_code_faculty_key UNIQUE (code, faculty);


--
-- Name: faculty_semesters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY faculty_semesters
    ADD CONSTRAINT faculty_semesters_pkey PRIMARY KEY (id);


--
-- Name: parallels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY parallels
    ADD CONSTRAINT parallels_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: schedule_exceptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schedule_exceptions
    ADD CONSTRAINT schedule_exceptions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (filename);


--
-- Name: timetable_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY timetable_slots
    ADD CONSTRAINT timetable_slots_pkey PRIMARY KEY (id);


--
-- Name: tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (uuid);


--
-- Name: update_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY update_logs
    ADD CONSTRAINT update_logs_pkey PRIMARY KEY (id);


--
-- Name: events_absolute_sequence_number_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX events_absolute_sequence_number_index ON events USING btree (absolute_sequence_number);


--
-- Name: events_faculty_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX events_faculty_index ON events USING btree (faculty);


--
-- Name: events_semester_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX events_semester_index ON events USING btree (semester);


--
-- Name: events_source_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX events_source_index ON events USING gin (source);


--
-- Name: events_student_ids_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX events_student_ids_index ON events USING gin (student_ids);


--
-- Name: events_teacher_ids_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX events_teacher_ids_index ON events USING gin (teacher_ids);


--
-- Name: events_timetable_slot_id_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX events_timetable_slot_id_index ON events USING btree (timetable_slot_id);


--
-- Name: faculty_semesters_code_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX faculty_semesters_code_index ON faculty_semesters USING btree (code);


--
-- Name: faculty_semesters_faculty_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX faculty_semesters_faculty_index ON faculty_semesters USING btree (faculty);


--
-- Name: parallels_faculty_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX parallels_faculty_index ON parallels USING btree (faculty);


--
-- Name: parallels_student_ids_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX parallels_student_ids_index ON parallels USING gin (student_ids);


--
-- Name: parallels_teacher_ids_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX parallels_teacher_ids_index ON parallels USING gin (teacher_ids);


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
-- Name: events_timetable_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_timetable_slot_id_fkey FOREIGN KEY (timetable_slot_id) REFERENCES timetable_slots(id);


--
-- Name: parallels_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parallels
    ADD CONSTRAINT parallels_course_id_fkey FOREIGN KEY (course_id) REFERENCES courses(id);


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
