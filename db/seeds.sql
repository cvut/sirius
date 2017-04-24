--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.1
-- Dumped by pg_dump version 9.5.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

--
-- Data for Name: faculty_semesters; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO faculty_semesters VALUES (1, 'B141', 18000, false, 'odd', '2014-09-22', '2014-12-20', '2015-01-05', '2015-02-14', '2015-02-14', '{07:30:00,08:15:00,09:15:00,10:00:00,11:00:00,11:45:00,12:45:00,13:30:00,14:30:00,15:15:00,16:15:00,17:00:00,18:00:00,18:45:00,19:45:00}', 45, '2014-10-03 15:18:47.907429', '2014-10-03 15:18:47.907429', false);
INSERT INTO faculty_semesters VALUES (2, 'B141', 13000, false, 'odd', '2014-09-22', '2014-12-20', '2015-01-05', '2015-02-14', '2015-02-14', '{07:30:00,08:15:00,09:15:00,10:00:00,11:00:00,11:45:00,12:45:00,13:30:00,14:30:00,15:15:00,16:15:00,17:00:00,18:00:00,18:45:00,19:45:00}', 45, '2014-10-03 15:18:47.94049', '2014-10-03 15:18:47.94049', false);
INSERT INTO faculty_semesters VALUES (3, 'B142', 18000, false, 'even', '2015-02-16', '2015-05-16', '2015-05-18', '2015-06-27', '2015-09-21', '{07:30:00,08:15:00,09:15:00,10:00:00,11:00:00,11:45:00,12:45:00,13:30:00,14:30:00,15:15:00,16:15:00,17:00:00,18:00:00,18:45:00,19:45:00}', 45, '2015-01-22 05:17:33.233842', '2015-01-22 05:17:33.233842', false);
INSERT INTO faculty_semesters VALUES (4, 'B142', 13000, false, 'odd', '2015-02-16', '2015-05-23', '2015-05-25', '2015-06-26', '2015-09-21', '{07:30:00,08:15:00,09:15:00,10:00:00,11:00:00,11:45:00,12:45:00,13:30:00,14:30:00,15:15:00,16:15:00,17:00:00,18:00:00,18:45:00,19:45:00}', 45, '2015-01-27 05:11:56.265673', '2015-01-27 05:11:56.265673', false);
INSERT INTO faculty_semesters VALUES (10, 'B161', 18000, false, 'even', '2016-10-03', '2017-01-08', '2017-01-09', '2017-02-17', '2017-02-19', '{07:30:00,08:15:00,09:15:00,10:00:00,11:00:00,11:45:00,12:45:00,13:30:00,14:30:00,15:15:00,16:15:00,17:00:00,18:00:00,18:45:00,19:45:00}', 45, '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', false);
INSERT INTO faculty_semesters VALUES (12, 'B162', 13000, true, 'even', '2017-02-20', '2017-05-28', '2017-05-29', '2017-09-08', '2017-09-30', '{07:30:00,08:15:00,09:15:00,10:00:00,11:00:00,11:45:00,12:45:00,13:30:00,14:30:00,15:15:00,16:15:00,17:00:00,18:00:00,18:45:00,19:45:00}', 45, '2016-09-05 18:08:26.616446', '2016-09-05 18:08:26.616446', true);
INSERT INTO faculty_semesters VALUES (13, 'B162', 18000, true, 'even', '2017-02-20', '2017-05-21', '2017-05-22', '2017-07-02', '2017-10-01', '{07:30:00,08:15:00,09:15:00,10:00:00,11:00:00,11:45:00,12:45:00,13:30:00,14:30:00,15:15:00,16:15:00,17:00:00,18:00:00,18:45:00,19:45:00}', 45, '2017-01-16 01:24:09.563795', '2017-01-16 01:24:09.563795', true);
INSERT INTO faculty_semesters VALUES (11, 'B161', 13000, false, 'even', '2016-10-03', '2017-01-15', '2017-01-16', '2017-02-19', '2017-02-19', '{07:30:00,08:15:00,09:15:00,10:00:00,11:00:00,11:45:00,12:45:00,13:30:00,14:30:00,15:15:00,16:15:00,17:00:00,18:00:00,18:45:00,19:45:00}', 45, '2016-09-05 17:33:44.55526', '2016-09-05 17:33:44.55526', false);
INSERT INTO faculty_semesters VALUES (5, 'B151', 18000, false, 'odd', '2015-10-05', '2016-01-10', '2016-01-11', '2016-02-21', '2016-02-22', '{07:30:00,08:15:00,09:15:00,10:00:00,11:00:00,11:45:00,12:45:00,13:30:00,14:30:00,15:15:00,16:15:00,17:00:00,18:00:00,18:45:00,19:45:00}', 45, '2015-06-15 18:13:58.520049', '2015-06-15 18:13:58.520049', false);
INSERT INTO faculty_semesters VALUES (7, 'B152', 13000, false, 'even', '2016-02-22', '2016-05-29', '2016-05-30', '2016-09-09', '2016-09-30', '{07:30:00,08:15:00,09:15:00,10:00:00,11:00:00,11:45:00,12:45:00,13:30:00,14:30:00,15:15:00,16:15:00,17:00:00,18:00:00,18:45:00,19:45:00}', 45, '2016-02-04 14:18:44.412765', '2016-02-04 14:18:44.412765', false);
INSERT INTO faculty_semesters VALUES (8, 'B152', 18000, false, 'even', '2016-02-22', '2016-05-22', '2016-05-23', '2016-07-02', '2016-09-30', '{07:30:00,08:15:00,09:15:00,10:00:00,11:00:00,11:45:00,12:45:00,13:30:00,14:30:00,15:15:00,16:15:00,17:00:00,18:00:00,18:45:00,19:45:00}', 45, '2016-02-08 14:58:25.197503', '2016-02-08 14:58:25.197503', false);
INSERT INTO faculty_semesters VALUES (6, 'B151', 13000, false, 'even', '2015-10-01', '2016-01-18', '2016-01-18', '2016-02-21', '2016-02-22', '{07:30:00,08:15:00,09:15:00,10:00:00,11:00:00,11:45:00,12:45:00,13:30:00,14:30:00,15:15:00,16:15:00,17:00:00,18:00:00,18:45:00,19:45:00}', 45, '2015-06-15 18:13:58.520049', '2015-06-15 18:13:58.520049', false);


--
-- Name: faculty_semesters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('faculty_semesters_id_seq', 13, true);


--
-- Data for Name: schedule_exceptions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO schedule_exceptions VALUES (4, 'relative_move', 'MI-MDW - posun začátku přednášky na 7:15', 'posun kvůli výuce FA', NULL, NULL, 18000, 'B141', '{392622000}', '1970-01-01 01:00:00', '1970-01-01 01:00:00', '"offset"=>"-15"', NULL);
INSERT INTO schedule_exceptions VALUES (5, 'cancel', 'MI-EVY - výuka až od 13. 10. 2014', NULL, NULL, '2014-10-13 00:00:00', 18000, 'B141', NULL, '1970-01-01 01:00:00', '1970-01-01 01:00:00', NULL, '{MI-EVY,MIE-EVY}');
INSERT INTO schedule_exceptions VALUES (6, 'cancel', 'MI-EVY - výuka pouze do 5. 12. 2014', NULL, '2014-12-06 00:00:00', NULL, 18000, 'B141', NULL, '1970-01-01 01:00:00', '1970-01-01 01:00:00', NULL, '{MI-EVY,MIE-EVY}');
INSERT INTO schedule_exceptions VALUES (8, 'cancel', 'MI-MVI - odpadá výuka 20. 10. 2014', NULL, '2014-10-20 00:00:00', '2014-10-21 00:00:00', 18000, 'B141', NULL, '2014-10-19 00:00:00', '2014-10-19 00:00:00', NULL, '{MI-MVI}');
INSERT INTO schedule_exceptions VALUES (10, 'cancel', 'Velikonoční pondělí', NULL, '2015-04-06 00:00:00', '2015-04-07 00:00:00', NULL, 'B142', NULL, '2015-01-22 04:47:51.057353', '2015-01-22 04:47:51.057353', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (11, 'cancel', 'Děkanský den FIT', 'Výuka odpadá', '2015-04-30 00:00:00', '2015-05-01 00:00:00', 18000, 'B142', NULL, '2015-01-22 04:50:07.162538', '2015-01-22 04:50:07.162538', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (14, 'cancel', 'Děkanský den FEL', NULL, '2015-04-03 00:00:00', '2015-04-04 00:00:00', 13000, 'B142', NULL, '2015-01-27 05:21:04.779597', '2015-01-27 05:21:04.779597', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (15, 'cancel', 'Rektorský den', NULL, '2015-05-13 00:00:00', '2015-05-14 00:00:00', NULL, 'B142', NULL, '2015-01-27 05:21:04.779597', '2015-01-27 05:21:04.779597', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (7, 'room_change', 'MI-MPI - přednáška 24. 9. 2014 přesunuta do T9:105', NULL, '2014-09-24 00:00:00', '2014-09-25 00:00:00', 18000, 'B141', '{392651000}', '1970-01-01 01:00:00', '1970-01-01 01:00:00', '"room_id"=>"T9:105"', NULL);
INSERT INTO schedule_exceptions VALUES (9, 'room_change', 'BI-ZMA - přesun přednášky 4. 12. 2014 do T9:155', NULL, '2014-12-04 00:00:00', '2014-12-05 00:00:00', 18000, 'B141', '{392356000}', '2014-10-19 00:00:00', '2014-10-19 00:00:00', '"room_id"=>"T9:155"', NULL);
INSERT INTO schedule_exceptions VALUES (16, 'cancel', 'Den vzniku samostatného československého státu', NULL, '2015-10-28 00:00:00', '2015-10-29 00:00:00', NULL, 'B151', NULL, '2015-06-15 19:15:10.507685', '2015-06-15 19:15:10.507685', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (17, 'cancel', 'Den boje za svobodu a demokracii', NULL, '2015-11-17 00:00:00', '2015-11-18 00:00:00', NULL, 'B151', NULL, '2015-06-15 19:15:56.244907', '2015-06-15 19:15:56.244907', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (19, 'relative_move', 'MI-MDW - posun začátku přednášky na 7:15', 'posun kvůli výuce FA', NULL, NULL, 18000, 'B151', '{428739000}', '1970-01-01 01:00:00', '1970-01-01 01:00:00', '"offset"=>"-15"', NULL);
INSERT INTO schedule_exceptions VALUES (18, 'cancel', 'Zimní prázdniny', NULL, '2015-12-23 00:00:00', '2016-01-04 00:00:00', NULL, 'B151', NULL, '2015-06-15 19:26:13.56595', '2015-06-15 19:26:13.56595', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (20, 'cancel', 'Rektorský den', NULL, '2016-05-11 00:00:00', '2016-05-12 00:00:00', NULL, 'B152', NULL, '2016-02-04 15:29:22.164551', '2016-02-04 15:29:22.164551', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (21, 'cancel', 'Velký pátek', NULL, '2016-03-25 00:00:00', '2016-03-26 00:00:00', NULL, 'B152', NULL, '2016-02-04 15:29:22.164551', '2016-02-04 15:29:22.164551', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (22, 'cancel', 'Velikonoční pondělí', NULL, '2016-03-28 00:00:00', '2016-03-29 00:00:00', NULL, 'B152', NULL, '2016-02-04 15:29:22.164551', '2016-02-04 15:29:22.164551', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (24, 'relative_move', 'MI-MDW - posun začátku přednášky na 7:15', 'posun kvůli výuce FA', NULL, NULL, 18000, 'B152', '{722248273505}', '2016-02-08 15:58:22.95251', '2016-02-08 15:58:22.95251', '"offset"=>"-15"', NULL);
INSERT INTO schedule_exceptions VALUES (25, 'cancel', 'Děkanský den', NULL, '2016-03-24 00:00:00', '2016-03-25 00:00:00', 18000, 'B152', NULL, '2016-02-17 14:08:33.031212', '2016-02-17 14:08:33.031212', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (26, 'cancel', 'Svátek práce', NULL, '2016-05-01 00:00:00', '2016-05-02 00:00:00', NULL, 'B152', NULL, '2016-02-17 14:08:33.031212', '2016-02-17 14:08:33.031212', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (27, 'cancel', 'Den vítězství', NULL, '2016-05-08 00:00:00', '2016-05-09 00:00:00', NULL, 'B152', NULL, '2016-02-17 14:08:33.031212', '2016-02-17 14:08:33.031212', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (1, 'cancel', 'Den české státnosti', NULL, '2014-09-28 00:00:00', '2014-09-29 00:00:00', NULL, 'B141', NULL, '1970-01-01 01:00:00', '1970-01-01 01:00:00', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (2, 'cancel', 'Den vzniku samostatného československého státu', NULL, '2014-10-28 00:00:00', '2014-10-29 00:00:00', NULL, 'B141', NULL, '1970-01-01 01:00:00', '1970-01-01 01:00:00', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (3, 'cancel', 'Den boje za svobodu a demokracii', NULL, '2014-11-17 00:00:00', '2014-11-18 00:00:00', NULL, 'B141', NULL, '1970-01-01 01:00:00', '1970-01-01 01:00:00', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (12, 'cancel', 'Svátek práce', NULL, '2015-05-01 00:00:00', '2015-05-02 00:00:00', NULL, 'B142', NULL, '2015-01-22 04:52:07.533893', '2015-01-22 04:52:07.533893', NULL, NULL);
INSERT INTO schedule_exceptions VALUES (13, 'cancel', 'Den osvobození', NULL, '2015-05-08 00:00:00', '2015-05-09 00:00:00', NULL, 'B142', NULL, '2015-01-22 04:53:19.826746', '2015-01-22 04:53:19.826746', NULL, NULL);


--
-- Name: schedule_exceptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('schedule_exceptions_id_seq', 27, true);


--
-- Data for Name: semester_periods; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO semester_periods VALUES (1, 3, '2015-02-16', '2015-05-15', 'teaching', 'even', '2015-08-31 19:19:00.890199', '2015-08-31 19:19:00.890199', NULL, false);
INSERT INTO semester_periods VALUES (2, 3, '2015-05-18', '2015-06-26', 'exams', NULL, '2015-08-31 19:19:00.925363', '2015-08-31 19:19:00.925363', NULL, false);
INSERT INTO semester_periods VALUES (3, 3, '2015-06-29', '2015-08-28', 'holiday', NULL, '2015-08-31 19:19:00.938457', '2015-08-31 19:19:00.938457', NULL, false);
INSERT INTO semester_periods VALUES (5, 5, '2015-12-23', '2016-01-03', 'holiday', NULL, '2015-08-31 19:19:01.004245', '2015-08-31 19:19:01.004245', NULL, false);
INSERT INTO semester_periods VALUES (6, 5, '2016-01-04', '2016-01-10', 'teaching', 'even', '2015-08-31 19:19:01.017416', '2015-08-31 19:19:01.017416', NULL, false);
INSERT INTO semester_periods VALUES (7, 5, '2016-01-11', '2016-02-20', 'exams', NULL, '2015-08-31 19:19:01.033625', '2015-08-31 19:19:01.033625', NULL, false);
INSERT INTO semester_periods VALUES (13, 6, '2015-12-23', '2016-01-03', 'holiday', NULL, '2015-08-31 20:44:26.249147', '2015-08-31 20:44:26.249147', NULL, false);
INSERT INTO semester_periods VALUES (15, 6, '2016-01-18', '2016-02-21', 'exams', NULL, '2015-08-31 20:44:26.291144', '2015-08-31 20:44:26.291144', NULL, false);
INSERT INTO semester_periods VALUES (14, 6, '2016-01-04', '2016-01-17', 'teaching', 'odd', '2015-08-31 20:44:26.263927', '2015-08-31 20:44:26.263927', NULL, false);
INSERT INTO semester_periods VALUES (12, 6, '2015-10-01', '2015-12-22', 'teaching', 'even', '2015-08-31 20:44:26.220635', '2015-08-31 20:44:26.220635', NULL, false);
INSERT INTO semester_periods VALUES (4, 5, '2015-10-05', '2015-12-20', 'teaching', 'odd', '2015-08-31 19:19:00.963844', '2015-10-21 15:59:23.69002', NULL, false);
INSERT INTO semester_periods VALUES (18, 7, '2016-02-22', '2016-05-29', 'teaching', 'even', '2016-02-04 14:18:44.412765', '2016-02-04 14:18:44.412765', NULL, false);
INSERT INTO semester_periods VALUES (19, 7, '2016-05-30', '2016-07-03', 'exams', NULL, '2016-02-04 14:18:44.412765', '2016-02-04 14:18:44.412765', NULL, false);
INSERT INTO semester_periods VALUES (20, 7, '2016-07-04', '2016-09-04', 'holiday', NULL, '2016-02-04 14:18:44.412765', '2016-02-04 14:18:44.412765', NULL, false);
INSERT INTO semester_periods VALUES (21, 7, '2016-09-05', '2016-09-09', 'exams', NULL, '2016-02-04 14:18:44.412765', '2016-02-04 14:18:44.412765', NULL, false);
INSERT INTO semester_periods VALUES (22, 7, '2016-09-10', '2016-09-30', 'holiday', NULL, '2016-02-04 14:18:44.412765', '2016-02-04 14:18:44.412765', NULL, false);
INSERT INTO semester_periods VALUES (23, 8, '2016-02-22', '2016-04-03', 'teaching', 'even', '2016-02-08 14:58:25.197503', '2016-02-08 14:58:25.197503', NULL, false);
INSERT INTO semester_periods VALUES (26, 8, '2016-05-23', '2016-07-02', 'exams', NULL, '2016-02-08 14:58:25.197503', '2016-02-08 14:58:25.197503', NULL, false);
INSERT INTO semester_periods VALUES (27, 8, '2016-07-03', '2016-09-04', 'holiday', NULL, '2016-02-08 14:58:25.197503', '2016-02-08 14:58:25.197503', NULL, false);
INSERT INTO semester_periods VALUES (16, 5, '2015-12-21', '2015-12-21', 'teaching', 'even', '2015-10-21 15:59:23.69002', '2015-10-21 15:59:23.69002', 3, true);
INSERT INTO semester_periods VALUES (17, 5, '2015-12-22', '2015-12-22', 'teaching', 'odd', '2015-10-21 15:59:23.69002', '2015-10-21 15:59:23.69002', 2, true);
INSERT INTO semester_periods VALUES (24, 8, '2016-04-04', '2016-04-04', 'teaching', 'odd', '2016-02-08 14:58:25.197503', '2016-02-08 14:58:25.197503', 1, true);
INSERT INTO semester_periods VALUES (88, 13, '2017-05-09', '2017-05-10', 'teaching', 'odd', '2017-01-16 01:24:09.563795', '2017-02-02 00:32:52.68254', NULL, false);
INSERT INTO semester_periods VALUES (28, 8, '2016-05-18', '2016-05-18', 'teaching', 'odd', '2016-02-17 14:08:33.031212', '2016-02-17 14:08:33.031212', 3, true);
INSERT INTO semester_periods VALUES (29, 8, '2016-04-05', '2016-05-17', 'teaching', 'even', '2016-02-17 14:08:33.031212', '2016-02-17 14:08:33.031212', NULL, false);
INSERT INTO semester_periods VALUES (30, 8, '2016-05-19', '2016-05-22', 'teaching', 'even', '2016-02-17 14:08:33.031212', '2016-02-17 14:08:33.031212', NULL, false);
INSERT INTO semester_periods VALUES (31, 1, '2014-09-22', '2014-12-20', 'teaching', 'odd', '2016-05-18 17:14:11.789702', '2016-05-18 17:14:11.789702', NULL, false);
INSERT INTO semester_periods VALUES (32, 1, '2014-12-21', '2015-01-04', 'holiday', NULL, '2016-05-18 17:14:11.789702', '2016-05-18 17:14:11.789702', NULL, false);
INSERT INTO semester_periods VALUES (33, 1, '2015-01-05', '2015-02-14', 'exams', NULL, '2016-05-18 17:14:11.789702', '2016-05-18 17:14:11.789702', NULL, false);
INSERT INTO semester_periods VALUES (34, 2, '2014-09-22', '2014-12-20', 'teaching', 'odd', '2016-05-18 17:20:33.525339', '2016-05-18 17:20:33.525339', NULL, false);
INSERT INTO semester_periods VALUES (35, 2, '2014-12-21', '2015-01-04', 'holiday', NULL, '2016-05-18 17:20:33.525339', '2016-05-18 17:20:33.525339', NULL, false);
INSERT INTO semester_periods VALUES (36, 2, '2015-01-05', '2015-02-14', 'exams', NULL, '2016-05-18 17:20:33.525339', '2016-05-18 17:20:33.525339', NULL, false);
INSERT INTO semester_periods VALUES (37, 10, '2016-10-03', '2016-10-27', 'teaching', 'even', '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', NULL, false);
INSERT INTO semester_periods VALUES (38, 10, '2016-10-28', '2016-10-28', 'holiday', NULL, '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', NULL, false);
INSERT INTO semester_periods VALUES (39, 10, '2016-10-29', '2016-11-15', 'teaching', 'odd', '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', NULL, false);
INSERT INTO semester_periods VALUES (41, 10, '2016-11-17', '2016-11-17', 'holiday', NULL, '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', NULL, false);
INSERT INTO semester_periods VALUES (42, 10, '2016-11-18', '2016-12-18', 'teaching', 'even', '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', NULL, false);
INSERT INTO semester_periods VALUES (44, 10, '2016-12-20', '2016-12-21', 'teaching', 'odd', '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', NULL, false);
INSERT INTO semester_periods VALUES (45, 10, '2016-12-22', '2016-12-22', 'holiday', NULL, '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', NULL, false);
INSERT INTO semester_periods VALUES (46, 10, '2016-12-23', '2017-01-01', 'holiday', NULL, '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', NULL, false);
INSERT INTO semester_periods VALUES (47, 10, '2017-01-02', '2017-01-03', 'teaching', 'odd', '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', NULL, false);
INSERT INTO semester_periods VALUES (49, 10, '2017-01-05', '2017-01-08', 'teaching', 'odd', '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', NULL, false);
INSERT INTO semester_periods VALUES (50, 10, '2017-01-09', '2017-02-17', 'exams', NULL, '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', NULL, false);
INSERT INTO semester_periods VALUES (40, 10, '2016-11-16', '2016-11-16', 'teaching', 'even', '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', 4, true);
INSERT INTO semester_periods VALUES (43, 10, '2016-12-19', '2016-12-19', 'teaching', 'odd', '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', 5, true);
INSERT INTO semester_periods VALUES (48, 10, '2017-01-04', '2017-01-04', 'teaching', 'even', '2016-05-23 16:33:18.659885', '2016-05-23 16:33:18.659885', 3, true);
INSERT INTO semester_periods VALUES (51, 11, '2016-10-03', '2016-10-27', 'teaching', 'even', '2016-09-05 17:33:44.55526', '2016-09-05 17:33:44.55526', NULL, false);
INSERT INTO semester_periods VALUES (52, 11, '2016-10-28', '2016-10-28', 'holiday', NULL, '2016-09-05 17:33:44.55526', '2016-09-05 17:33:44.55526', NULL, false);
INSERT INTO semester_periods VALUES (53, 11, '2016-10-29', '2016-11-15', 'teaching', 'odd', '2016-09-05 17:33:44.55526', '2016-09-05 17:33:44.55526', NULL, false);
INSERT INTO semester_periods VALUES (54, 11, '2016-11-16', '2016-11-16', 'teaching', 'even', '2016-09-05 17:33:44.55526', '2016-09-05 17:33:44.55526', 5, true);
INSERT INTO semester_periods VALUES (55, 11, '2016-11-17', '2016-11-17', 'holiday', NULL, '2016-09-05 17:33:44.55526', '2016-09-05 17:33:44.55526', NULL, false);
INSERT INTO semester_periods VALUES (56, 11, '2016-11-18', '2016-11-18', 'holiday', NULL, '2016-09-05 17:33:44.55526', '2016-09-05 17:33:44.55526', NULL, false);
INSERT INTO semester_periods VALUES (57, 11, '2016-11-19', '2016-12-18', 'teaching', 'even', '2016-09-05 17:33:44.55526', '2016-09-05 17:33:44.55526', NULL, false);
INSERT INTO semester_periods VALUES (58, 11, '2016-12-19', '2016-12-19', 'teaching', 'odd', '2016-09-05 17:33:44.55526', '2016-09-05 17:33:44.55526', 5, true);
INSERT INTO semester_periods VALUES (59, 11, '2016-12-20', '2016-12-22', 'teaching', 'odd', '2016-09-05 17:33:44.55526', '2016-09-05 17:33:44.55526', NULL, false);
INSERT INTO semester_periods VALUES (60, 11, '2016-12-23', '2017-01-01', 'holiday', NULL, '2016-09-05 17:33:44.55526', '2016-09-05 17:33:44.55526', NULL, false);
INSERT INTO semester_periods VALUES (61, 11, '2017-01-02', '2017-01-15', 'teaching', 'odd', '2016-09-05 17:33:44.55526', '2016-09-05 17:33:44.55526', NULL, false);
INSERT INTO semester_periods VALUES (62, 11, '2017-01-16', '2017-02-19', 'exams', NULL, '2016-09-05 17:33:44.55526', '2016-09-05 17:33:44.55526', NULL, false);
INSERT INTO semester_periods VALUES (63, 12, '2017-02-20', '2017-04-13', 'teaching', 'even', '2016-09-05 18:08:26.616446', '2016-09-05 18:08:26.616446', NULL, false);
INSERT INTO semester_periods VALUES (64, 12, '2017-04-14', '2017-04-14', 'holiday', NULL, '2016-09-05 18:08:26.616446', '2016-09-05 18:08:26.616446', NULL, false);
INSERT INTO semester_periods VALUES (65, 12, '2017-04-15', '2017-04-16', 'teaching', 'odd', '2016-09-05 18:08:26.616446', '2016-09-05 18:08:26.616446', NULL, false);
INSERT INTO semester_periods VALUES (66, 12, '2017-04-17', '2017-04-17', 'holiday', NULL, '2016-09-05 18:08:26.616446', '2016-09-05 18:08:26.616446', NULL, false);
INSERT INTO semester_periods VALUES (67, 12, '2017-04-18', '2017-04-30', 'teaching', 'even', '2016-09-05 18:08:26.616446', '2016-09-05 18:08:26.616446', NULL, false);
INSERT INTO semester_periods VALUES (68, 12, '2017-05-01', '2017-05-01', 'holiday', NULL, '2016-09-05 18:08:26.616446', '2016-09-05 18:08:26.616446', NULL, false);
INSERT INTO semester_periods VALUES (69, 12, '2017-05-02', '2017-05-02', 'teaching', 'even', '2016-09-05 18:08:26.616446', '2016-09-05 18:08:26.616446', 1, true);
INSERT INTO semester_periods VALUES (70, 12, '2017-05-03', '2017-05-07', 'teaching', 'even', '2016-09-05 18:08:26.616446', '2016-09-05 18:08:26.616446', NULL, false);
INSERT INTO semester_periods VALUES (71, 12, '2017-05-08', '2017-05-08', 'holiday', NULL, '2016-09-05 18:08:26.616446', '2016-09-05 18:08:26.616446', NULL, false);
INSERT INTO semester_periods VALUES (74, 12, '2017-05-11', '2017-05-11', 'teaching', 'odd', '2016-09-05 18:08:26.616446', '2016-09-05 18:08:26.616446', 1, true);
INSERT INTO semester_periods VALUES (76, 12, '2017-05-29', '2017-07-02', 'exams', NULL, '2016-09-05 18:08:26.616446', '2016-09-05 18:08:26.616446', NULL, false);
INSERT INTO semester_periods VALUES (77, 12, '2017-07-03', '2017-09-03', 'holiday', NULL, '2016-09-05 18:08:26.616446', '2016-09-05 18:08:26.616446', NULL, false);
INSERT INTO semester_periods VALUES (78, 12, '2017-09-04', '2017-09-08', 'exams', NULL, '2016-09-05 18:08:26.616446', '2016-09-05 18:08:26.616446', NULL, false);
INSERT INTO semester_periods VALUES (79, 13, '2017-02-20', '2017-04-13', 'teaching', 'even', '2017-01-16 01:24:09.563795', '2017-01-16 01:24:09.563795', NULL, false);
INSERT INTO semester_periods VALUES (80, 13, '2017-04-14', '2017-04-14', 'holiday', NULL, '2017-01-16 01:24:09.563795', '2017-01-16 01:24:09.563795', NULL, false);
INSERT INTO semester_periods VALUES (81, 13, '2017-04-15', '2017-04-16', 'teaching', 'odd', '2017-01-16 01:24:09.563795', '2017-01-16 01:24:09.563795', NULL, false);
INSERT INTO semester_periods VALUES (82, 13, '2017-04-17', '2017-04-17', 'holiday', NULL, '2017-01-16 01:24:09.563795', '2017-01-16 01:24:09.563795', NULL, false);
INSERT INTO semester_periods VALUES (83, 13, '2017-04-18', '2017-04-30', 'teaching', 'even', '2017-01-16 01:24:09.563795', '2017-01-16 01:24:09.563795', NULL, false);
INSERT INTO semester_periods VALUES (84, 13, '2017-05-01', '2017-05-01', 'holiday', NULL, '2017-01-16 01:24:09.563795', '2017-01-16 01:24:09.563795', NULL, false);
INSERT INTO semester_periods VALUES (85, 13, '2017-05-02', '2017-05-02', 'teaching', 'even', '2017-01-16 01:24:09.563795', '2017-01-16 01:24:09.563795', 1, true);
INSERT INTO semester_periods VALUES (86, 13, '2017-05-03', '2017-05-07', 'teaching', 'even', '2017-01-16 01:24:09.563795', '2017-01-16 01:24:09.563795', NULL, false);
INSERT INTO semester_periods VALUES (87, 13, '2017-05-08', '2017-05-08', 'holiday', NULL, '2017-01-16 01:24:09.563795', '2017-01-16 01:24:09.563795', NULL, false);
INSERT INTO semester_periods VALUES (89, 13, '2017-05-17', '2017-05-17', 'holiday', NULL, '2017-01-16 01:24:09.563795', '2017-01-16 01:24:09.563795', NULL, false);
INSERT INTO semester_periods VALUES (90, 13, '2017-05-18', '2017-05-21', 'teaching', 'odd', '2017-01-16 01:24:09.563795', '2017-01-16 01:24:09.563795', NULL, true);
INSERT INTO semester_periods VALUES (72, 12, '2017-05-09', '2017-05-10', 'teaching', 'odd', '2016-09-05 18:08:26.616446', '2017-02-27 18:17:18.665794', NULL, false);
INSERT INTO semester_periods VALUES (75, 12, '2017-05-12', '2017-05-16', 'teaching', 'odd', '2016-09-05 18:08:26.616446', '2017-02-27 18:17:31.400464', NULL, false);
INSERT INTO semester_periods VALUES (91, 13, '2017-05-22', '2017-07-02', 'exams', NULL, '2017-01-16 01:24:09.563795', '2017-01-16 01:24:09.563795', NULL, false);
INSERT INTO semester_periods VALUES (92, 13, '2017-07-03', '2017-10-01', 'holiday', NULL, '2017-01-16 01:24:09.563795', '2017-01-16 01:24:09.563795', NULL, false);
INSERT INTO semester_periods VALUES (93, 13, '2017-05-12', '2017-05-16', 'teaching', 'odd', '2017-02-02 00:32:52.68254', '2017-02-02 00:32:52.68254', NULL, false);
INSERT INTO semester_periods VALUES (94, 13, '2017-05-11', '2017-05-11', 'teaching', 'odd', '2017-02-02 00:32:52.68254', '2017-02-02 00:32:52.68254', 1, true);
INSERT INTO semester_periods VALUES (95, 12, '2017-05-17', '2017-05-17', 'holiday', NULL, '2017-02-27 17:44:38.552381', '2017-02-27 17:44:38.552381', NULL, false);
INSERT INTO semester_periods VALUES (96, 12, '2017-05-18', '2017-05-28', 'teaching', 'even', '2017-02-27 17:44:38.552381', '2017-02-27 17:44:38.552381', NULL, false);


--
-- Name: semester_periods_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('semester_periods_id_seq', 96, true);


--
-- PostgreSQL database dump complete
--

