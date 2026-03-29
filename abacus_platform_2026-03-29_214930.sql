--
-- PostgreSQL database dump
--

-- Dumped from database version 14.12 (Homebrew)
-- Dumped by pg_dump version 14.12 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: assignments; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.assignments (
    id integer NOT NULL,
    teacher_id integer NOT NULL,
    student_id integer NOT NULL,
    lesson_id integer NOT NULL,
    assigned_date timestamp without time zone DEFAULT now() NOT NULL,
    assignment_kind character varying(20) DEFAULT 'homework'::character varying NOT NULL,
    available_on date
);


ALTER TABLE public.assignments OWNER TO prabhatshukla;

--
-- Name: assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

CREATE SEQUENCE public.assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.assignments_id_seq OWNER TO prabhatshukla;

--
-- Name: assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prabhatshukla
--

ALTER SEQUENCE public.assignments_id_seq OWNED BY public.assignments.id;


--
-- Name: units; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.units (
    id integer NOT NULL,
    sub_lesson_id integer NOT NULL,
    unit_name character varying(120) NOT NULL
);


ALTER TABLE public.units OWNER TO prabhatshukla;

--
-- Name: chapters_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

CREATE SEQUENCE public.chapters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.chapters_id_seq OWNER TO prabhatshukla;

--
-- Name: chapters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prabhatshukla
--

ALTER SEQUENCE public.chapters_id_seq OWNED BY public.units.id;


--
-- Name: curriculum_question_attempts; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.curriculum_question_attempts (
    id bigint NOT NULL,
    unit_attempt_id bigint NOT NULL,
    curriculum_question_id integer NOT NULL,
    student_answer text NOT NULL,
    is_correct boolean NOT NULL,
    attempted_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.curriculum_question_attempts OWNER TO prabhatshukla;

--
-- Name: curriculum_question_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

CREATE SEQUENCE public.curriculum_question_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.curriculum_question_attempts_id_seq OWNER TO prabhatshukla;

--
-- Name: curriculum_question_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prabhatshukla
--

ALTER SEQUENCE public.curriculum_question_attempts_id_seq OWNED BY public.curriculum_question_attempts.id;


--
-- Name: curriculum_questions; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.curriculum_questions (
    id integer NOT NULL,
    question_text text NOT NULL,
    unit_id integer,
    answer_text text,
    "order" integer
);


ALTER TABLE public.curriculum_questions OWNER TO prabhatshukla;

--
-- Name: curriculum_unit_attempts; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.curriculum_unit_attempts (
    id bigint NOT NULL,
    student_id integer NOT NULL,
    unit_id integer NOT NULL,
    status character varying(20) DEFAULT 'in_progress'::character varying NOT NULL,
    elapsed_seconds integer DEFAULT 0 NOT NULL,
    correct_count integer DEFAULT 0 NOT NULL,
    wrong_count integer DEFAULT 0 NOT NULL,
    completed_at timestamp without time zone,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    assignment_id integer
);


ALTER TABLE public.curriculum_unit_attempts OWNER TO prabhatshukla;

--
-- Name: curriculum_unit_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

CREATE SEQUENCE public.curriculum_unit_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.curriculum_unit_attempts_id_seq OWNER TO prabhatshukla;

--
-- Name: curriculum_unit_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prabhatshukla
--

ALTER SEQUENCE public.curriculum_unit_attempts_id_seq OWNED BY public.curriculum_unit_attempts.id;


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO prabhatshukla;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

ALTER TABLE public.django_content_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO prabhatshukla;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

ALTER TABLE public.django_migrations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO prabhatshukla;

--
-- Name: grades; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.grades (
    id integer NOT NULL,
    grade_name character varying(60) NOT NULL
);


ALTER TABLE public.grades OWNER TO prabhatshukla;

--
-- Name: grades_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

CREATE SEQUENCE public.grades_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.grades_id_seq OWNER TO prabhatshukla;

--
-- Name: grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prabhatshukla
--

ALTER SEQUENCE public.grades_id_seq OWNED BY public.grades.id;


--
-- Name: learnings_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

CREATE SEQUENCE public.learnings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.learnings_id_seq OWNER TO prabhatshukla;

--
-- Name: learnings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prabhatshukla
--

ALTER SEQUENCE public.learnings_id_seq OWNED BY public.curriculum_questions.id;


--
-- Name: lesson_types; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.lesson_types (
    id integer NOT NULL,
    grade_id integer NOT NULL,
    lesson_name character varying(120) NOT NULL
);


ALTER TABLE public.lesson_types OWNER TO prabhatshukla;

--
-- Name: lesson_types_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

CREATE SEQUENCE public.lesson_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lesson_types_id_seq OWNER TO prabhatshukla;

--
-- Name: lesson_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prabhatshukla
--

ALTER SEQUENCE public.lesson_types_id_seq OWNED BY public.lesson_types.id;


--
-- Name: questions; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.questions (
    id integer NOT NULL,
    assignment_id integer NOT NULL,
    question_text text NOT NULL,
    correct_answer character varying(120) NOT NULL,
    "order" integer
);


ALTER TABLE public.questions OWNER TO prabhatshukla;

--
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

CREATE SEQUENCE public.questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.questions_id_seq OWNER TO prabhatshukla;

--
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prabhatshukla
--

ALTER SEQUENCE public.questions_id_seq OWNED BY public.questions.id;


--
-- Name: student_answers; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.student_answers (
    id integer NOT NULL,
    question_id integer NOT NULL,
    student_id integer NOT NULL,
    student_answer character varying(120) NOT NULL,
    is_correct boolean NOT NULL
);


ALTER TABLE public.student_answers OWNER TO prabhatshukla;

--
-- Name: student_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

CREATE SEQUENCE public.student_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.student_answers_id_seq OWNER TO prabhatshukla;

--
-- Name: student_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prabhatshukla
--

ALTER SEQUENCE public.student_answers_id_seq OWNED BY public.student_answers.id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.students (
    id integer NOT NULL,
    user_id integer NOT NULL,
    grade_id integer,
    first_name character varying(120),
    last_name character varying(120),
    father_name character varying(120),
    mother_name character varying(120),
    contact character varying(40),
    profile_photo text,
    date_of_birth date
);


ALTER TABLE public.students OWNER TO prabhatshukla;

--
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

CREATE SEQUENCE public.students_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.students_id_seq OWNER TO prabhatshukla;

--
-- Name: students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prabhatshukla
--

ALTER SEQUENCE public.students_id_seq OWNED BY public.students.id;


--
-- Name: sub_lesson_type_master; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.sub_lesson_type_master (
    id integer NOT NULL,
    type_name character varying(120) NOT NULL
);


ALTER TABLE public.sub_lesson_type_master OWNER TO prabhatshukla;

--
-- Name: sub_lesson_type_master_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

CREATE SEQUENCE public.sub_lesson_type_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sub_lesson_type_master_id_seq OWNER TO prabhatshukla;

--
-- Name: sub_lesson_type_master_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prabhatshukla
--

ALTER SEQUENCE public.sub_lesson_type_master_id_seq OWNED BY public.sub_lesson_type_master.id;


--
-- Name: sub_lessons; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.sub_lessons (
    id integer NOT NULL,
    lesson_type_id integer NOT NULL,
    sub_lesson_name character varying(120) NOT NULL,
    sub_lesson_type_master_id integer
);


ALTER TABLE public.sub_lessons OWNER TO prabhatshukla;

--
-- Name: sub_lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

CREATE SEQUENCE public.sub_lessons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sub_lessons_id_seq OWNER TO prabhatshukla;

--
-- Name: sub_lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prabhatshukla
--

ALTER SEQUENCE public.sub_lessons_id_seq OWNED BY public.sub_lessons.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: prabhatshukla
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    email character varying(180) NOT NULL,
    password text NOT NULL,
    role character varying(20) NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['teacher'::character varying, 'student'::character varying])::text[])))
);


ALTER TABLE public.users OWNER TO prabhatshukla;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: prabhatshukla
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO prabhatshukla;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: prabhatshukla
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: assignments id; Type: DEFAULT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.assignments ALTER COLUMN id SET DEFAULT nextval('public.assignments_id_seq'::regclass);


--
-- Name: curriculum_question_attempts id; Type: DEFAULT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.curriculum_question_attempts ALTER COLUMN id SET DEFAULT nextval('public.curriculum_question_attempts_id_seq'::regclass);


--
-- Name: curriculum_questions id; Type: DEFAULT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.curriculum_questions ALTER COLUMN id SET DEFAULT nextval('public.learnings_id_seq'::regclass);


--
-- Name: curriculum_unit_attempts id; Type: DEFAULT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.curriculum_unit_attempts ALTER COLUMN id SET DEFAULT nextval('public.curriculum_unit_attempts_id_seq'::regclass);


--
-- Name: grades id; Type: DEFAULT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.grades ALTER COLUMN id SET DEFAULT nextval('public.grades_id_seq'::regclass);


--
-- Name: lesson_types id; Type: DEFAULT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.lesson_types ALTER COLUMN id SET DEFAULT nextval('public.lesson_types_id_seq'::regclass);


--
-- Name: questions id; Type: DEFAULT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.questions ALTER COLUMN id SET DEFAULT nextval('public.questions_id_seq'::regclass);


--
-- Name: student_answers id; Type: DEFAULT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.student_answers ALTER COLUMN id SET DEFAULT nextval('public.student_answers_id_seq'::regclass);


--
-- Name: students id; Type: DEFAULT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public.students_id_seq'::regclass);


--
-- Name: sub_lesson_type_master id; Type: DEFAULT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.sub_lesson_type_master ALTER COLUMN id SET DEFAULT nextval('public.sub_lesson_type_master_id_seq'::regclass);


--
-- Name: sub_lessons id; Type: DEFAULT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.sub_lessons ALTER COLUMN id SET DEFAULT nextval('public.sub_lessons_id_seq'::regclass);


--
-- Name: units id; Type: DEFAULT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.units ALTER COLUMN id SET DEFAULT nextval('public.chapters_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: assignments; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.assignments (id, teacher_id, student_id, lesson_id, assigned_date, assignment_kind, available_on) FROM stdin;
58	2	4	15	2026-03-27 00:40:25.230083	classroom	2026-03-27
79	2	4	27	2026-03-28 02:00:45.925919	homework	2026-03-28
80	2	4	28	2026-03-28 02:00:45.925987	homework	2026-03-28
81	2	4	29	2026-03-28 02:00:45.926005	homework	2026-03-28
82	2	4	30	2026-03-28 02:00:45.926063	homework	2026-03-28
83	2	4	31	2026-03-28 02:00:45.926077	homework	2026-03-28
84	2	4	32	2026-03-28 02:00:45.92609	homework	2026-03-28
85	2	4	33	2026-03-28 02:00:45.926102	homework	2026-03-28
86	2	4	34	2026-03-28 02:00:45.926114	homework	2026-03-28
87	2	4	35	2026-03-28 02:00:45.926126	homework	2026-03-28
31	2	3	13	2026-03-25 21:25:08.574498	homework	2026-03-25
88	2	4	36	2026-03-28 02:00:45.926137	homework	2026-03-28
\.


--
-- Data for Name: curriculum_question_attempts; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.curriculum_question_attempts (id, unit_attempt_id, curriculum_question_id, student_answer, is_correct, attempted_at) FROM stdin;
1	1	30	1	f	2026-03-26 21:42:42.564452
2	1	31	2	f	2026-03-26 21:42:44.762861
3	2	40	2	t	2026-03-26 22:07:32.349112
4	2	41	2	f	2026-03-26 22:07:34.95252
5	2	42	2	f	2026-03-26 22:07:36.796241
6	2	43	2	f	2026-03-26 22:07:37.425705
7	2	44	2	f	2026-03-26 22:07:37.732114
8	2	45	2	f	2026-03-26 22:07:37.897279
9	2	46	2	f	2026-03-26 22:07:38.099364
10	2	47	2	f	2026-03-26 22:07:38.287263
11	2	48	2	f	2026-03-26 22:07:38.448821
12	2	49	2	f	2026-03-26 22:07:38.631884
13	3	9	2	f	2026-03-26 23:18:07.175772
14	3	11	3	f	2026-03-26 23:18:07.833094
15	3	10	4	t	2026-03-26 23:18:08.369184
16	3	12	3	f	2026-03-26 23:18:09.209489
17	4	19	3	f	2026-03-26 23:18:26.710739
18	4	20	4	f	2026-03-26 23:18:27.260055
19	4	21	2	f	2026-03-26 23:18:28.051506
20	4	22	3	f	2026-03-26 23:18:28.602726
21	1	32	2	f	2026-03-26 23:20:55.747887
22	1	33	3	f	2026-03-26 23:20:58.355424
23	1	34	2	f	2026-03-26 23:21:01.475161
27	6	8	3	t	2026-03-27 00:48:44.139777
28	7	2500	7	t	2026-03-28 02:16:29.853305
29	7	2501	9	t	2026-03-28 02:16:32.958507
30	7	2502	11	t	2026-03-28 02:16:35.251562
31	7	2503	13	t	2026-03-28 02:16:38.79521
32	7	2504	15	t	2026-03-28 02:16:40.535364
33	7	2505	17	t	2026-03-28 02:16:42.875401
34	7	2506	19	t	2026-03-28 02:16:45.303282
35	7	2507	21	t	2026-03-28 02:16:49.972553
36	7	2508	25	f	2026-03-28 02:16:55.246774
37	7	2509	25	t	2026-03-28 02:16:58.946388
38	8	3100	2	t	2026-03-28 02:20:14.019905
39	8	3101	3	t	2026-03-28 02:20:14.986465
40	8	3102	3	f	2026-03-28 02:20:15.321857
41	8	3103	3	f	2026-03-28 02:20:15.548499
42	8	3104	3	f	2026-03-28 02:20:15.725501
43	8	3105	3	f	2026-03-28 02:20:15.896258
44	8	3106	3	f	2026-03-28 02:20:16.069542
45	8	3107	3	f	2026-03-28 02:20:16.25176
46	8	3108		f	2026-03-28 02:20:16.412836
47	8	3109	33	f	2026-03-28 02:20:17.56209
48	9	4900	10	t	2026-03-28 02:22:38.0975
49	9	4901	12	t	2026-03-28 02:22:40.500735
50	9	4902	14	t	2026-03-28 02:22:42.544238
51	9	4903	16	t	2026-03-28 02:22:46.127741
52	9	4904	18	t	2026-03-28 02:22:48.245942
53	9	4905	20	t	2026-03-28 02:22:51.441262
54	9	4906	22	t	2026-03-28 02:22:57.896721
55	9	4907	24	t	2026-03-28 02:23:00.728321
56	9	4908	26	t	2026-03-28 02:23:05.815945
57	9	4909	28	t	2026-03-28 02:23:09.217177
58	10	4910	3	f	2026-03-28 02:23:19.138396
59	10	4911	3	f	2026-03-28 02:23:19.36244
60	10	4912	3	f	2026-03-28 02:23:19.587206
61	10	4913	3	f	2026-03-28 02:23:19.783717
62	10	4914	3	f	2026-03-28 02:23:20.018401
63	10	4915	3	f	2026-03-28 02:23:20.262636
64	10	4916	3	f	2026-03-28 02:23:20.471204
65	10	4917	3	f	2026-03-28 02:23:20.70469
66	10	4918	3	f	2026-03-28 02:23:20.888428
67	10	4919	3	f	2026-03-28 02:23:21.1126
68	11	100	4	t	2026-03-28 02:25:12.508883
69	11	101	6	t	2026-03-28 02:25:14.150149
70	11	102	8	t	2026-03-28 02:25:16.411007
71	11	103	10	t	2026-03-28 02:25:18.278092
72	11	104	11	f	2026-03-28 02:25:20.453024
73	11	105	14	t	2026-03-28 02:25:23.370355
74	11	106	16	t	2026-03-28 02:25:26.660009
75	11	107	18	t	2026-03-28 02:25:28.399685
76	11	108	20	t	2026-03-28 02:25:33.674817
77	11	109	22	t	2026-03-28 02:25:37.154477
98	12	119	22	f	2026-03-28 02:59:33.2756
99	13	120	2	f	2026-03-28 02:59:54.950289
100	13	121		f	2026-03-28 02:59:55.677507
101	13	122	2	f	2026-03-28 02:59:56.433066
102	13	123	2	f	2026-03-28 02:59:58.7844
103	13	124	2	f	2026-03-28 03:00:00.152609
104	13	125	2	f	2026-03-28 03:00:01.357899
105	13	126	2	f	2026-03-28 03:00:02.566868
106	13	127	3	f	2026-03-28 03:00:05.604926
107	13	128	2	f	2026-03-28 03:00:07.578219
108	13	129	3	f	2026-03-28 03:00:09.320085
109	14	170	2	f	2026-03-28 03:00:27.877503
110	14	171	2	f	2026-03-28 03:00:28.269782
111	14	172	2	f	2026-03-28 03:00:28.590965
112	14	173	2	f	2026-03-28 03:00:28.870675
113	14	174	2	f	2026-03-28 03:00:29.153283
114	14	175	2	f	2026-03-28 03:00:29.433916
115	14	176	2	f	2026-03-28 03:00:29.686285
116	14	177	2	f	2026-03-28 03:00:29.889418
117	14	178	2	f	2026-03-28 03:00:30.485543
118	14	179	2	f	2026-03-28 03:00:31.512329
\.


--
-- Data for Name: curriculum_questions; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.curriculum_questions (id, question_text, unit_id, answer_text, "order") FROM stdin;
16	2\n+2	11	4	8
17	2\n+3	11	5	9
18	2\n+4	11	6	10
19	1\n+1	12	2	1
20	1\n+2	12	3	2
21	1\n+3	12	4	3
22	1\n+3	12	4	4
23	1\n+3	12	4	5
24	1\n+3	12	4	6
25	1\n+3	12	4	7
26	1\n+3	12	4	8
27	1\n+3	12	4	9
28	1\n+3	12	4	10
29	1\n+3	3	4	1
7	1\n+2	7	3	1
30	1\n+1	13	2	1
31	1\n+2	13	3	2
32	1\n+3	13	4	3
33	1\n+4	13	5	4
34	1\n+5	13	6	5
35	1\n+5	13	6	6
36	1\n+6	13	7	7
37	1\n+7	13	8	8
38	1\n+8	13	9	9
121	6\n+2	25	8	2
122	7\n+3	25	10	3
123	8\n+4	25	12	4
90	2\n5\n3	22	10	1
91	4\n1\n2	22	7	2
92	6\n2\n1	22	9	3
93	3\n3\n4	22	10	4
94	5\n2\n2	22	9	5
95	7\n1\n1	22	9	6
96	8\n1\n0	22	9	7
97	4\n4\n1	22	9	8
98	2\n2\n5	22	9	9
99	6\n1\n2	22	9	10
124	9\n+5	25	14	5
125	10\n+6	25	16	6
126	11\n+7	25	18	7
127	12\n+8	25	20	8
128	13\n+9	25	22	9
129	14\n+10	25	24	10
100	3\n+1	23	4	1
101	4\n+2	23	6	2
102	5\n+3	23	8	3
103	6\n+4	23	10	4
104	7\n+5	23	12	5
105	8\n+6	23	14	6
106	9\n+7	23	16	7
107	10\n+8	23	18	8
108	11\n+9	23	20	9
109	12\n+10	23	22	10
110	4\n+1	24	5	1
111	5\n+2	24	7	2
112	6\n+3	24	9	3
113	7\n+4	24	11	4
114	8\n+5	24	13	5
115	9\n+6	24	15	6
116	10\n+7	24	17	7
117	11\n+8	24	19	8
118	12\n+9	24	21	9
119	13\n+10	24	23	10
72	8\n/2	20	4	3
73	9\n/3	20	3	4
74	12\n/3	20	4	5
75	12\n/4	20	3	6
77	10\n/2	20	5	8
78	15\n/3	20	5	9
79	18\n/3	20	6	10
80	4\n/2	21	2	1
81	6\n/2	21	3	2
82	8\n/2	21	4	3
84	12\n/3	21	4	5
85	12\n/4	21	3	6
86	16\n/4	21	4	7
87	10\n/2	21	5	8
88	15\n/3	21	5	9
89	18\n/3	21	6	10
50	2\nx2	18	4	1
51	2\nx3	18	6	2
52	2\nx4	18	8	3
53	3\nx3	18	9	4
54	3\nx4	18	12	5
41	1\n+2	17	3	2
42	1\n+3	17	4	3
43	1\n+4	17	5	4
44	1\n+5	17	6	5
55	4\nx3	18	12	6
56	4\nx4	18	16	7
57	5\nx2	18	10	8
58	5\nx3	18	15	9
59	6\nx2	18	12	10
60	2\nx2	19	4	1
61	2\nx3	19	6	2
62	2\nx4	19	8	3
63	3\nx3	19	9	4
65	4\nx3	19	12	6
66	4\nx4	19	16	7
67	5\nx2	19	10	8
68	5\nx3	19	15	9
69	6\nx2	19	12	10
70	4\n/2	20	2	1
76	16\n/4	20	4	7
83	9\n/3	21	3	4
49	5\n-8910	17	10	10
39	5\n-8910	13	10	10
4	1\n+2\n+3	3	6	1
5	2\n+1\n+4	3	7	2
45	1\n+5	17	6	6
46	1\n+6	17	7	7
47	1\n+7	17	8	8
48	1\n+8	17	9	9
6	1\n+2	4	3	1
12	1\n+1	11	2	4
64	3\nx4	19	12	5
71	6\n/2	20	3	2
8	1\n+2	9	3	1
40	1\n+1	17	2	1
9	1\n+2	11	3	1
10	1\n+3	11	4	2
11	1\n+1	11	2	1
13	1\n+2	11	3	5
14	1\n+5	11	6	6
15	1\n+3	11	4	7
159	17\n+10	28	27	10
160	9\n+1	29	10	1
161	10\n+2	29	12	2
162	11\n+3	29	14	3
163	12\n+4	29	16	4
164	13\n+5	29	18	5
165	14\n+6	29	20	6
166	15\n+7	29	22	7
167	16\n+8	29	24	8
168	17\n+9	29	26	9
169	18\n+10	29	28	10
170	10\n+1	30	11	1
171	11\n+2	30	13	2
172	12\n+3	30	15	3
173	13\n+4	30	17	4
174	14\n+5	30	19	5
175	15\n+6	30	21	6
176	16\n+7	30	23	7
177	17\n+8	30	25	8
178	18\n+9	30	27	9
179	19\n+10	30	29	10
180	11\n+1	31	12	1
181	12\n+2	31	14	2
182	13\n+3	31	16	3
183	14\n+4	31	18	4
184	15\n+5	31	20	5
120	5\n+1	25	6	1
185	16\n+6	31	22	6
186	17\n+7	31	24	7
187	18\n+8	31	26	8
188	19\n+9	31	28	9
189	20\n+10	31	30	10
190	12\n+1	32	13	1
191	13\n+2	32	15	2
192	14\n+3	32	17	3
193	15\n+4	32	19	4
194	16\n+5	32	21	5
195	17\n+6	32	23	6
196	18\n+7	32	25	7
197	19\n+8	32	27	8
198	20\n+9	32	29	9
199	21\n+10	32	31	10
200	3\n+1	33	4	1
201	4\n+2	33	6	2
202	5\n+3	33	8	3
203	6\n+4	33	10	4
204	7\n+5	33	12	5
205	8\n+6	33	14	6
206	9\n+7	33	16	7
207	10\n+8	33	18	8
208	11\n+9	33	20	9
209	12\n+10	33	22	10
210	4\n+1	34	5	1
131	7\n+2	26	9	2
132	8\n+3	26	11	3
133	9\n+4	26	13	4
134	10\n+5	26	15	5
135	11\n+6	26	17	6
136	12\n+7	26	19	7
137	13\n+8	26	21	8
138	14\n+9	26	23	9
139	15\n+10	26	25	10
140	7\n+1	27	8	1
141	8\n+2	27	10	2
142	9\n+3	27	12	3
143	10\n+4	27	14	4
144	11\n+5	27	16	5
145	12\n+6	27	18	6
146	13\n+7	27	20	7
147	14\n+8	27	22	8
148	15\n+9	27	24	9
149	16\n+10	27	26	10
150	8\n+1	28	9	1
151	9\n+2	28	11	2
152	10\n+3	28	13	3
153	11\n+4	28	15	4
154	12\n+5	28	17	5
155	13\n+6	28	19	6
156	14\n+7	28	21	7
157	15\n+8	28	23	8
158	16\n+9	28	25	9
240	7\n+1	37	8	1
241	8\n+2	37	10	2
242	9\n+3	37	12	3
243	10\n+4	37	14	4
244	11\n+5	37	16	5
245	12\n+6	37	18	6
246	13\n+7	37	20	7
247	14\n+8	37	22	8
248	15\n+9	37	24	9
249	16\n+10	37	26	10
250	8\n+1	38	9	1
251	9\n+2	38	11	2
252	10\n+3	38	13	3
253	11\n+4	38	15	4
254	12\n+5	38	17	5
255	13\n+6	38	19	6
256	14\n+7	38	21	7
257	15\n+8	38	23	8
258	16\n+9	38	25	9
259	17\n+10	38	27	10
260	9\n+1	39	10	1
261	10\n+2	39	12	2
262	11\n+3	39	14	3
263	12\n+4	39	16	4
264	13\n+5	39	18	5
265	14\n+6	39	20	6
130	6\n+1	26	7	1
266	15\n+7	39	22	7
267	16\n+8	39	24	8
268	17\n+9	39	26	9
269	18\n+10	39	28	10
270	10\n+1	40	11	1
271	11\n+2	40	13	2
272	12\n+3	40	15	3
273	13\n+4	40	17	4
274	14\n+5	40	19	5
275	15\n+6	40	21	6
276	16\n+7	40	23	7
277	17\n+8	40	25	8
278	18\n+9	40	27	9
279	19\n+10	40	29	10
280	11\n+1	41	12	1
281	12\n+2	41	14	2
282	13\n+3	41	16	3
283	14\n+4	41	18	4
284	15\n+5	41	20	5
285	16\n+6	41	22	6
286	17\n+7	41	24	7
287	18\n+8	41	26	8
288	19\n+9	41	28	9
289	20\n+10	41	30	10
290	12\n+1	42	13	1
291	13\n+2	42	15	2
212	6\n+3	34	9	3
213	7\n+4	34	11	4
214	8\n+5	34	13	5
215	9\n+6	34	15	6
216	10\n+7	34	17	7
217	11\n+8	34	19	8
218	12\n+9	34	21	9
219	13\n+10	34	23	10
220	5\n+1	35	6	1
221	6\n+2	35	8	2
222	7\n+3	35	10	3
223	8\n+4	35	12	4
224	9\n+5	35	14	5
225	10\n+6	35	16	6
226	11\n+7	35	18	7
227	12\n+8	35	20	8
228	13\n+9	35	22	9
229	14\n+10	35	24	10
230	6\n+1	36	7	1
231	7\n+2	36	9	2
232	8\n+3	36	11	3
233	9\n+4	36	13	4
234	10\n+5	36	15	5
235	11\n+6	36	17	6
236	12\n+7	36	19	7
237	13\n+8	36	21	8
238	14\n+9	36	23	9
239	15\n+10	36	25	10
321	6\n+2	45	8	2
322	7\n+3	45	10	3
323	8\n+4	45	12	4
324	9\n+5	45	14	5
325	10\n+6	45	16	6
326	11\n+7	45	18	7
327	12\n+8	45	20	8
328	13\n+9	45	22	9
329	14\n+10	45	24	10
330	6\n+1	46	7	1
331	7\n+2	46	9	2
332	8\n+3	46	11	3
333	9\n+4	46	13	4
334	10\n+5	46	15	5
335	11\n+6	46	17	6
336	12\n+7	46	19	7
337	13\n+8	46	21	8
338	14\n+9	46	23	9
339	15\n+10	46	25	10
340	7\n+1	47	8	1
341	8\n+2	47	10	2
342	9\n+3	47	12	3
343	10\n+4	47	14	4
344	11\n+5	47	16	5
345	12\n+6	47	18	6
346	13\n+7	47	20	7
211	5\n+2	34	7	2
347	14\n+8	47	22	8
348	15\n+9	47	24	9
349	16\n+10	47	26	10
350	8\n+1	48	9	1
351	9\n+2	48	11	2
352	10\n+3	48	13	3
353	11\n+4	48	15	4
354	12\n+5	48	17	5
355	13\n+6	48	19	6
356	14\n+7	48	21	7
357	15\n+8	48	23	8
358	16\n+9	48	25	9
359	17\n+10	48	27	10
360	9\n+1	49	10	1
361	10\n+2	49	12	2
362	11\n+3	49	14	3
363	12\n+4	49	16	4
364	13\n+5	49	18	5
365	14\n+6	49	20	6
366	15\n+7	49	22	7
367	16\n+8	49	24	8
368	17\n+9	49	26	9
369	18\n+10	49	28	10
370	10\n+1	50	11	1
371	11\n+2	50	13	2
372	12\n+3	50	15	3
293	15\n+4	42	19	4
294	16\n+5	42	21	5
295	17\n+6	42	23	6
296	18\n+7	42	25	7
297	19\n+8	42	27	8
298	20\n+9	42	29	9
299	21\n+10	42	31	10
300	3\n+1	43	4	1
301	4\n+2	43	6	2
302	5\n+3	43	8	3
303	6\n+4	43	10	4
304	7\n+5	43	12	5
305	8\n+6	43	14	6
306	9\n+7	43	16	7
307	10\n+8	43	18	8
308	11\n+9	43	20	9
309	12\n+10	43	22	10
310	4\n+1	44	5	1
311	5\n+2	44	7	2
312	6\n+3	44	9	3
313	7\n+4	44	11	4
314	8\n+5	44	13	5
315	9\n+6	44	15	6
316	10\n+7	44	17	7
317	11\n+8	44	19	8
318	12\n+9	44	21	9
319	13\n+10	44	23	10
320	5\n+1	45	6	1
374	14\n+5	50	19	5
375	15\n+6	50	21	6
376	16\n+7	50	23	7
377	17\n+8	50	25	8
378	18\n+9	50	27	9
379	19\n+10	50	29	10
380	11\n+1	51	12	1
381	12\n+2	51	14	2
382	13\n+3	51	16	3
383	14\n+4	51	18	4
384	15\n+5	51	20	5
385	16\n+6	51	22	6
386	17\n+7	51	24	7
387	18\n+8	51	26	8
388	19\n+9	51	28	9
389	20\n+10	51	30	10
390	12\n+1	52	13	1
391	13\n+2	52	15	2
392	14\n+3	52	17	3
393	15\n+4	52	19	4
394	16\n+5	52	21	5
395	17\n+6	52	23	6
396	18\n+7	52	25	7
397	19\n+8	52	27	8
398	20\n+9	52	29	9
399	21\n+10	52	31	10
400	3\n4\n5	53	12	1
401	4\n5\n6	53	15	2
402	5\n6\n7	53	18	3
403	6\n7\n8	53	21	4
404	7\n8\n9	53	24	5
405	8\n9\n10	53	27	6
406	9\n10\n11	53	30	7
407	10\n11\n12	53	33	8
408	11\n12\n13	53	36	9
409	12\n13\n14	53	39	10
410	4\n5\n6	54	15	1
411	5\n6\n7	54	18	2
412	6\n7\n8	54	21	3
413	7\n8\n9	54	24	4
414	8\n9\n10	54	27	5
415	9\n10\n11	54	30	6
416	10\n11\n12	54	33	7
417	11\n12\n13	54	36	8
418	12\n13\n14	54	39	9
419	13\n14\n15	54	42	10
420	5\n6\n7	55	18	1
421	6\n7\n8	55	21	2
422	7\n8\n9	55	24	3
423	8\n9\n10	55	27	4
424	9\n10\n11	55	30	5
425	10\n11\n12	55	33	6
426	11\n12\n13	55	36	7
427	12\n13\n14	55	39	8
428	13\n14\n15	55	42	9
429	14\n15\n16	55	45	10
430	6\n7\n8	56	21	1
431	7\n8\n9	56	24	2
432	8\n9\n10	56	27	3
433	9\n10\n11	56	30	4
434	10\n11\n12	56	33	5
435	11\n12\n13	56	36	6
436	12\n13\n14	56	39	7
437	13\n14\n15	56	42	8
438	14\n15\n16	56	45	9
439	15\n16\n17	56	48	10
440	7\n8\n9	57	24	1
441	8\n9\n10	57	27	2
442	9\n10\n11	57	30	3
443	10\n11\n12	57	33	4
444	11\n12\n13	57	36	5
445	12\n13\n14	57	39	6
446	13\n14\n15	57	42	7
447	14\n15\n16	57	45	8
448	15\n16\n17	57	48	9
449	16\n17\n18	57	51	10
450	8\n9\n10	58	27	1
451	9\n10\n11	58	30	2
452	10\n11\n12	58	33	3
453	11\n12\n13	58	36	4
454	12\n13\n14	58	39	5
455	13\n14\n15	58	42	6
456	14\n15\n16	58	45	7
457	15\n16\n17	58	48	8
458	16\n17\n18	58	51	9
460	9\n10\n11	59	30	1
461	10\n11\n12	59	33	2
462	11\n12\n13	59	36	3
463	12\n13\n14	59	39	4
464	13\n14\n15	59	42	5
465	14\n15\n16	59	45	6
466	15\n16\n17	59	48	7
467	16\n17\n18	59	51	8
468	17\n18\n19	59	54	9
469	18\n19\n20	59	57	10
470	10\n11\n12	60	33	1
471	11\n12\n13	60	36	2
472	12\n13\n14	60	39	3
473	13\n14\n15	60	42	4
474	14\n15\n16	60	45	5
475	15\n16\n17	60	48	6
476	16\n17\n18	60	51	7
477	17\n18\n19	60	54	8
478	18\n19\n20	60	57	9
479	19\n20\n21	60	60	10
480	11\n12\n13	61	36	1
481	12\n13\n14	61	39	2
482	13\n14\n15	61	42	3
483	14\n15\n16	61	45	4
484	15\n16\n17	61	48	5
485	16\n17\n18	61	51	6
486	17\n18\n19	61	54	7
487	18\n19\n20	61	57	8
488	19\n20\n21	61	60	9
489	20\n21\n22	61	63	10
490	12\n13\n14	62	39	1
491	13\n14\n15	62	42	2
492	14\n15\n16	62	45	3
493	15\n16\n17	62	48	4
494	16\n17\n18	62	51	5
495	17\n18\n19	62	54	6
496	18\n19\n20	62	57	7
497	19\n20\n21	62	60	8
498	20\n21\n22	62	63	9
499	21\n22\n23	62	66	10
292	14\n+3	42	17	3
500	1\nx2	63	2	1
501	1\nx3	63	3	2
502	1\nx4	63	4	3
503	1\nx5	63	5	4
504	1\nx6	63	6	5
505	1\nx7	63	7	6
506	1\nx8	63	8	7
507	1\nx9	63	9	8
508	1\nx10	63	10	9
509	1\nx11	63	11	10
510	1\nx3	64	3	1
511	1\nx4	64	4	2
512	1\nx5	64	5	3
513	1\nx6	64	6	4
514	1\nx7	64	7	5
515	1\nx8	64	8	6
516	1\nx9	64	9	7
517	1\nx10	64	10	8
518	1\nx11	64	11	9
519	1\nx12	64	12	10
520	1\nx4	65	4	1
521	1\nx5	65	5	2
522	1\nx6	65	6	3
523	1\nx7	65	7	4
524	1\nx8	65	8	5
525	1\nx9	65	9	6
526	1\nx10	65	10	7
527	1\nx11	65	11	8
528	1\nx12	65	12	9
529	1\nx13	65	13	10
530	1\nx5	66	5	1
531	1\nx6	66	6	2
532	1\nx7	66	7	3
533	1\nx8	66	8	4
534	1\nx9	66	9	5
535	1\nx10	66	10	6
536	1\nx11	66	11	7
537	1\nx12	66	12	8
538	1\nx13	66	13	9
539	1\nx14	66	14	10
556	1\nx13	68	13	7
557	1\nx14	68	14	8
558	1\nx15	68	15	9
559	1\nx16	68	16	10
560	1\nx8	69	8	1
561	1\nx9	69	9	2
562	1\nx10	69	10	3
563	1\nx11	69	11	4
564	1\nx12	69	12	5
565	1\nx13	69	13	6
566	1\nx14	69	14	7
590	1\nx11	72	11	1
591	1\nx12	72	12	2
592	1\nx13	72	13	3
593	1\nx14	72	14	4
594	1\nx15	72	15	5
373	13\n+4	50	17	4
567	1\nx15	69	15	8
568	1\nx16	69	16	9
569	1\nx17	69	17	10
570	1\nx9	70	9	1
571	1\nx10	70	10	2
572	1\nx11	70	11	3
573	1\nx12	70	12	4
574	1\nx13	70	13	5
575	1\nx14	70	14	6
576	1\nx15	70	15	7
577	1\nx16	70	16	8
578	1\nx17	70	17	9
579	1\nx18	70	18	10
580	1\nx10	71	10	1
581	1\nx11	71	11	2
582	1\nx12	71	12	3
583	1\nx13	71	13	4
584	1\nx14	71	14	5
585	1\nx15	71	15	6
586	1\nx16	71	16	7
587	1\nx17	71	17	8
588	1\nx18	71	18	9
589	1\nx19	71	19	10
543	1\nx9	67	9	4
544	1\nx10	67	10	5
595	1\nx16	72	16	6
596	1\nx17	72	17	7
597	1\nx18	72	18	8
598	1\nx19	72	19	9
599	1\nx20	72	20	10
600	1\nx2	73	2	1
601	1\nx3	73	3	2
602	1\nx4	73	4	3
603	1\nx5	73	5	4
604	1\nx6	73	6	5
605	1\nx7	73	7	6
606	1\nx8	73	8	7
607	1\nx9	73	9	8
608	1\nx10	73	10	9
609	1\nx11	73	11	10
610	1\nx3	74	3	1
611	1\nx4	74	4	2
612	1\nx5	74	5	3
613	1\nx6	74	6	4
614	1\nx7	74	7	5
615	1\nx8	74	8	6
541	1\nx7	67	7	2
542	1\nx8	67	8	3
545	1\nx11	67	11	6
546	1\nx12	67	12	7
547	1\nx13	67	13	8
548	1\nx14	67	14	9
549	1\nx15	67	15	10
550	1\nx7	68	7	1
551	1\nx8	68	8	2
552	1\nx9	68	9	3
553	1\nx10	68	10	4
554	1\nx11	68	11	5
555	1\nx12	68	12	6
667	1\nx15	79	15	8
668	1\nx16	79	16	9
669	1\nx17	79	17	10
670	1\nx9	80	9	1
671	1\nx10	80	10	2
672	1\nx11	80	11	3
673	1\nx12	80	12	4
674	1\nx13	80	13	5
675	1\nx14	80	14	6
676	1\nx15	80	15	7
677	1\nx16	80	16	8
691	1\nx12	82	12	2
692	1\nx13	82	13	3
693	1\nx14	82	14	4
694	1\nx15	82	15	5
695	1\nx16	82	16	6
616	1\nx9	74	9	7
617	1\nx10	74	10	8
618	1\nx11	74	11	9
619	1\nx12	74	12	10
620	1\nx4	75	4	1
621	1\nx5	75	5	2
622	1\nx6	75	6	3
690	1\nx11	82	11	1
623	1\nx7	75	7	4
624	1\nx8	75	8	5
625	1\nx9	75	9	6
626	1\nx10	75	10	7
627	1\nx11	75	11	8
628	1\nx12	75	12	9
629	1\nx13	75	13	10
630	1\nx5	76	5	1
631	1\nx6	76	6	2
632	1\nx7	76	7	3
633	1\nx8	76	8	4
634	1\nx9	76	9	5
635	1\nx10	76	10	6
636	1\nx11	76	11	7
637	1\nx12	76	12	8
638	1\nx13	76	13	9
639	1\nx14	76	14	10
640	1\nx6	77	6	1
641	1\nx7	77	7	2
642	1\nx8	77	8	3
643	1\nx9	77	9	4
644	1\nx10	77	10	5
645	1\nx11	77	11	6
646	1\nx12	77	12	7
678	1\nx17	80	17	9
679	1\nx18	80	18	10
680	1\nx10	81	10	1
681	1\nx11	81	11	2
682	1\nx12	81	12	3
683	1\nx13	81	13	4
684	1\nx14	81	14	5
685	1\nx15	81	15	6
686	1\nx16	81	16	7
687	1\nx17	81	17	8
688	1\nx18	81	18	9
689	1\nx19	81	19	10
647	1\nx13	77	13	8
648	1\nx14	77	14	9
649	1\nx15	77	15	10
650	1\nx7	78	7	1
651	1\nx8	78	8	2
652	1\nx9	78	9	3
653	1\nx10	78	10	4
654	1\nx11	78	11	5
655	1\nx12	78	12	6
656	1\nx13	78	13	7
657	1\nx14	78	14	8
658	1\nx15	78	15	9
659	1\nx16	78	16	10
660	1\nx8	79	8	1
661	1\nx9	79	9	2
662	1\nx10	79	10	3
663	1\nx11	79	11	4
664	1\nx12	79	12	5
665	1\nx13	79	13	6
666	1\nx14	79	14	7
761	9\n/1	89	9	2
762	10\n/1	89	10	3
763	11\n/1	89	11	4
764	12\n/1	89	12	5
697	1\nx18	82	18	8
698	1\nx19	82	19	9
699	1\nx20	82	20	10
727	11\n/1	85	11	8
728	12\n/1	85	12	9
729	13\n/1	85	13	10
730	5\n/1	86	5	1
731	6\n/1	86	6	2
732	7\n/1	86	7	3
733	8\n/1	86	8	4
734	9\n/1	86	9	5
735	10\n/1	86	10	6
736	11\n/1	86	11	7
737	12\n/1	86	12	8
738	13\n/1	86	13	9
739	14\n/1	86	14	10
740	6\n/1	87	6	1
741	7\n/1	87	7	2
742	8\n/1	87	8	3
743	9\n/1	87	9	4
703	5\n/1	83	5	4
744	10\n/1	87	10	5
745	11\n/1	87	11	6
746	12\n/1	87	12	7
747	13\n/1	87	13	8
748	14\n/1	87	14	9
749	15\n/1	87	15	10
750	7\n/1	88	7	1
751	8\n/1	88	8	2
752	9\n/1	88	9	3
753	10\n/1	88	10	4
772	11\n/1	90	11	3
773	12\n/1	90	12	4
774	13\n/1	90	13	5
775	14\n/1	90	14	6
776	15\n/1	90	15	7
700	2\n/1	83	2	1
701	3\n/1	83	3	2
702	4\n/1	83	4	3
765	13\n/1	89	13	6
766	14\n/1	89	14	7
767	15\n/1	89	15	8
768	16\n/1	89	16	9
769	17\n/1	89	17	10
770	9\n/1	90	9	1
771	10\n/1	90	10	2
704	6\n/1	83	6	5
705	7\n/1	83	7	6
706	8\n/1	83	8	7
707	9\n/1	83	9	8
708	10\n/1	83	10	9
709	11\n/1	83	11	10
710	3\n/1	84	3	1
711	4\n/1	84	4	2
712	5\n/1	84	5	3
713	6\n/1	84	6	4
714	7\n/1	84	7	5
715	8\n/1	84	8	6
716	9\n/1	84	9	7
717	10\n/1	84	10	8
718	11\n/1	84	11	9
719	12\n/1	84	12	10
720	4\n/1	85	4	1
721	5\n/1	85	5	2
722	6\n/1	85	6	3
723	7\n/1	85	7	4
724	8\n/1	85	8	5
725	9\n/1	85	9	6
726	10\n/1	85	10	7
754	11\n/1	88	11	5
755	12\n/1	88	12	6
756	13\n/1	88	13	7
757	14\n/1	88	14	8
758	15\n/1	88	15	9
759	16\n/1	88	16	10
760	8\n/1	89	8	1
802	4\n/1	93	4	3
459	17\n18\n19	58	54	10
803	5\n/1	93	5	4
804	6\n/1	93	6	5
805	7\n/1	93	7	6
834	9\n/1	96	9	5
806	8\n/1	93	8	7
807	9\n/1	93	9	8
808	10\n/1	93	10	9
809	11\n/1	93	11	10
810	3\n/1	94	3	1
811	4\n/1	94	4	2
812	5\n/1	94	5	3
813	6\n/1	94	6	4
814	7\n/1	94	7	5
815	8\n/1	94	8	6
816	9\n/1	94	9	7
817	10\n/1	94	10	8
818	11\n/1	94	11	9
819	12\n/1	94	12	10
820	4\n/1	95	4	1
821	5\n/1	95	5	2
822	6\n/1	95	6	3
823	7\n/1	95	7	4
824	8\n/1	95	8	5
825	9\n/1	95	9	6
826	10\n/1	95	10	7
854	11\n/1	98	11	5
827	11\n/1	95	11	8
828	12\n/1	95	12	9
829	13\n/1	95	13	10
830	5\n/1	96	5	1
831	6\n/1	96	6	2
832	7\n/1	96	7	3
833	8\n/1	96	8	4
849	15\n/1	97	15	10
850	7\n/1	98	7	1
851	8\n/1	98	8	2
852	9\n/1	98	9	3
853	10\n/1	98	10	4
835	10\n/1	96	10	6
836	11\n/1	96	11	7
837	12\n/1	96	12	8
838	13\n/1	96	13	9
839	14\n/1	96	14	10
840	6\n/1	97	6	1
841	7\n/1	97	7	2
842	8\n/1	97	8	3
843	9\n/1	97	9	4
844	10\n/1	97	10	5
845	11\n/1	97	11	6
846	12\n/1	97	12	7
847	13\n/1	97	13	8
848	14\n/1	97	14	9
855	12\n/1	98	12	6
856	13\n/1	98	13	7
857	14\n/1	98	14	8
778	17\n/1	90	17	9
779	18\n/1	90	18	10
780	10\n/1	91	10	1
781	11\n/1	91	11	2
782	12\n/1	91	12	3
783	13\n/1	91	13	4
784	14\n/1	91	14	5
785	15\n/1	91	15	6
786	16\n/1	91	16	7
787	17\n/1	91	17	8
788	18\n/1	91	18	9
789	19\n/1	91	19	10
790	11\n/1	92	11	1
791	12\n/1	92	12	2
792	13\n/1	92	13	3
793	14\n/1	92	14	4
794	15\n/1	92	15	5
795	16\n/1	92	16	6
796	17\n/1	92	17	7
797	18\n/1	92	18	8
798	19\n/1	92	19	9
799	20\n/1	92	20	10
800	2\n/1	93	2	1
801	3\n/1	93	3	2
906	10\n+7	103	17	7
907	11\n+8	103	19	8
908	12\n+9	103	21	9
909	13\n+10	103	23	10
910	5\n+1	104	6	1
911	6\n+2	104	8	2
912	7\n+3	104	10	3
913	8\n+4	104	12	4
914	9\n+5	104	14	5
915	10\n+6	104	16	6
916	11\n+7	104	18	7
917	12\n+8	104	20	8
918	13\n+9	104	22	9
919	14\n+10	104	24	10
920	6\n+1	105	7	1
921	7\n+2	105	9	2
922	8\n+3	105	11	3
923	9\n+4	105	13	4
924	10\n+5	105	15	5
925	11\n+6	105	17	6
926	12\n+7	105	19	7
927	13\n+8	105	21	8
928	14\n+9	105	23	9
929	15\n+10	105	25	10
930	7\n+1	106	8	1
931	8\n+2	106	10	2
880	10\n/1	101	10	1
932	9\n+3	106	12	3
933	10\n+4	106	14	4
934	11\n+5	106	16	5
935	12\n+6	106	18	6
936	13\n+7	106	20	7
937	14\n+8	106	22	8
938	15\n+9	106	24	9
881	11\n/1	101	11	2
882	12\n/1	101	12	3
883	13\n/1	101	13	4
884	14\n/1	101	14	5
885	15\n/1	101	15	6
886	16\n/1	101	16	7
860	8\n/1	99	8	1
861	9\n/1	99	9	2
862	10\n/1	99	10	3
863	11\n/1	99	11	4
864	12\n/1	99	12	5
865	13\n/1	99	13	6
866	14\n/1	99	14	7
867	15\n/1	99	15	8
868	16\n/1	99	16	9
869	17\n/1	99	17	10
870	9\n/1	100	9	1
871	10\n/1	100	10	2
872	11\n/1	100	11	3
873	12\n/1	100	12	4
874	13\n/1	100	13	5
540	1\nx6	67	6	1
887	17\n/1	101	17	8
888	18\n/1	101	18	9
889	19\n/1	101	19	10
890	11\n/1	102	11	1
891	12\n/1	102	12	2
892	13\n/1	102	13	3
893	14\n/1	102	14	4
894	15\n/1	102	15	5
895	16\n/1	102	16	6
896	17\n/1	102	17	7
897	18\n/1	102	18	8
898	19\n/1	102	19	9
875	14\n/1	100	14	6
876	15\n/1	100	15	7
877	16\n/1	100	16	8
878	17\n/1	100	17	9
879	18\n/1	100	18	10
899	20\n/1	102	20	10
859	16\n/1	98	16	10
900	4\n+1	103	5	1
901	5\n+2	103	7	2
902	6\n+3	103	9	3
903	7\n+4	103	11	4
904	8\n+5	103	13	5
905	9\n+6	103	15	6
968	18\n+9	109	27	9
969	19\n+10	109	29	10
970	11\n+1	110	12	1
971	12\n+2	110	14	2
972	13\n+3	110	16	3
973	14\n+4	110	18	4
974	15\n+5	110	20	5
975	16\n+6	110	22	6
976	17\n+7	110	24	7
977	18\n+8	110	26	8
978	19\n+9	110	28	9
979	20\n+10	110	30	10
980	12\n+1	111	13	1
981	13\n+2	111	15	2
982	14\n+3	111	17	3
983	15\n+4	111	19	4
984	16\n+5	111	21	5
985	17\n+6	111	23	6
986	18\n+7	111	25	7
987	19\n+8	111	27	8
988	20\n+9	111	29	9
989	21\n+10	111	31	10
990	13\n+1	112	14	1
991	14\n+2	112	16	2
992	15\n+3	112	18	3
993	16\n+4	112	20	4
940	8\n+1	107	9	1
994	17\n+5	112	22	5
995	18\n+6	112	24	6
996	19\n+7	112	26	7
997	20\n+8	112	28	8
998	21\n+9	112	30	9
999	22\n+10	112	32	10
1000	4\n+1	113	5	1
1001	5\n+2	113	7	2
1002	6\n+3	113	9	3
1003	7\n+4	113	11	4
1004	8\n+5	113	13	5
1005	9\n+6	113	15	6
1006	10\n+7	113	17	7
1007	11\n+8	113	19	8
1008	12\n+9	113	21	9
1009	13\n+10	113	23	10
1010	5\n+1	114	6	1
1011	6\n+2	114	8	2
1012	7\n+3	114	10	3
1013	8\n+4	114	12	4
1014	9\n+5	114	14	5
1015	10\n+6	114	16	6
1016	11\n+7	114	18	7
1017	12\n+8	114	20	8
1018	13\n+9	114	22	9
1019	14\n+10	114	24	10
696	1\nx17	82	17	7
941	9\n+2	107	11	2
942	10\n+3	107	13	3
943	11\n+4	107	15	4
944	12\n+5	107	17	5
945	13\n+6	107	19	6
946	14\n+7	107	21	7
947	15\n+8	107	23	8
948	16\n+9	107	25	9
949	17\n+10	107	27	10
950	9\n+1	108	10	1
951	10\n+2	108	12	2
952	11\n+3	108	14	3
953	12\n+4	108	16	4
954	13\n+5	108	18	5
955	14\n+6	108	20	6
956	15\n+7	108	22	7
957	16\n+8	108	24	8
958	17\n+9	108	26	9
959	18\n+10	108	28	10
960	10\n+1	109	11	1
961	11\n+2	109	13	2
962	12\n+3	109	15	3
963	13\n+4	109	17	4
964	14\n+5	109	19	5
965	15\n+6	109	21	6
966	16\n+7	109	23	7
967	17\n+8	109	25	8
1049	17\n+10	117	27	10
1050	9\n+1	118	10	1
1051	10\n+2	118	12	2
1052	11\n+3	118	14	3
1053	12\n+4	118	16	4
1054	13\n+5	118	18	5
1055	14\n+6	118	20	6
1056	15\n+7	118	22	7
1057	16\n+8	118	24	8
1058	17\n+9	118	26	9
1059	18\n+10	118	28	10
1060	10\n+1	119	11	1
1061	11\n+2	119	13	2
1062	12\n+3	119	15	3
1063	13\n+4	119	17	4
1064	14\n+5	119	19	5
1065	15\n+6	119	21	6
1066	16\n+7	119	23	7
1067	17\n+8	119	25	8
1068	18\n+9	119	27	9
1069	19\n+10	119	29	10
1070	11\n+1	120	12	1
1071	12\n+2	120	14	2
1072	13\n+3	120	16	3
1073	14\n+4	120	18	4
1074	15\n+5	120	20	5
1075	16\n+6	120	22	6
1021	7\n+2	115	9	2
1076	17\n+7	120	24	7
1077	18\n+8	120	26	8
1078	19\n+9	120	28	9
1079	20\n+10	120	30	10
1080	12\n+1	121	13	1
1081	13\n+2	121	15	2
1082	14\n+3	121	17	3
1083	15\n+4	121	19	4
1084	16\n+5	121	21	5
1085	17\n+6	121	23	6
1086	18\n+7	121	25	7
1087	19\n+8	121	27	8
1088	20\n+9	121	29	9
1089	21\n+10	121	31	10
1090	13\n+1	122	14	1
1091	14\n+2	122	16	2
1092	15\n+3	122	18	3
1093	16\n+4	122	20	4
1094	17\n+5	122	22	5
1095	18\n+6	122	24	6
1096	19\n+7	122	26	7
1097	20\n+8	122	28	8
1098	21\n+9	122	30	9
1099	22\n+10	122	32	10
1100	4\n+1	123	5	1
777	16\n/1	90	16	8
1022	8\n+3	115	11	3
1023	9\n+4	115	13	4
1024	10\n+5	115	15	5
1025	11\n+6	115	17	6
1026	12\n+7	115	19	7
1027	13\n+8	115	21	8
1028	14\n+9	115	23	9
1029	15\n+10	115	25	10
1030	7\n+1	116	8	1
1031	8\n+2	116	10	2
1032	9\n+3	116	12	3
1033	10\n+4	116	14	4
1034	11\n+5	116	16	5
1035	12\n+6	116	18	6
1036	13\n+7	116	20	7
1037	14\n+8	116	22	8
1038	15\n+9	116	24	9
1039	16\n+10	116	26	10
1040	8\n+1	117	9	1
1041	9\n+2	117	11	2
1042	10\n+3	117	13	3
1043	11\n+4	117	15	4
1044	12\n+5	117	17	5
1045	13\n+6	117	19	6
1046	14\n+7	117	21	7
1047	15\n+8	117	23	8
1048	16\n+9	117	25	9
1130	7\n+1	126	8	1
1131	8\n+2	126	10	2
1132	9\n+3	126	12	3
1133	10\n+4	126	14	4
1134	11\n+5	126	16	5
1135	12\n+6	126	18	6
1136	13\n+7	126	20	7
1137	14\n+8	126	22	8
1138	15\n+9	126	24	9
1139	16\n+10	126	26	10
1140	8\n+1	127	9	1
1141	9\n+2	127	11	2
1142	10\n+3	127	13	3
1143	11\n+4	127	15	4
1144	12\n+5	127	17	5
1145	13\n+6	127	19	6
1146	14\n+7	127	21	7
1147	15\n+8	127	23	8
1148	16\n+9	127	25	9
1149	17\n+10	127	27	10
1150	9\n+1	128	10	1
1151	10\n+2	128	12	2
1152	11\n+3	128	14	3
1153	12\n+4	128	16	4
1154	13\n+5	128	18	5
1155	14\n+6	128	20	6
1156	15\n+7	128	22	7
1102	6\n+3	123	9	3
1157	16\n+8	128	24	8
1158	17\n+9	128	26	9
1159	18\n+10	128	28	10
1160	10\n+1	129	11	1
1161	11\n+2	129	13	2
1162	12\n+3	129	15	3
1163	13\n+4	129	17	4
1164	14\n+5	129	19	5
1165	15\n+6	129	21	6
1166	16\n+7	129	23	7
1167	17\n+8	129	25	8
1168	18\n+9	129	27	9
1169	19\n+10	129	29	10
1170	11\n+1	130	12	1
1171	12\n+2	130	14	2
1172	13\n+3	130	16	3
1173	14\n+4	130	18	4
1174	15\n+5	130	20	5
1175	16\n+6	130	22	6
1176	17\n+7	130	24	7
1177	18\n+8	130	26	8
1178	19\n+9	130	28	9
1179	20\n+10	130	30	10
1180	12\n+1	131	13	1
1181	13\n+2	131	15	2
858	15\n/1	98	15	9
1103	7\n+4	123	11	4
1104	8\n+5	123	13	5
1105	9\n+6	123	15	6
1106	10\n+7	123	17	7
1107	11\n+8	123	19	8
1108	12\n+9	123	21	9
1109	13\n+10	123	23	10
1110	5\n+1	124	6	1
1111	6\n+2	124	8	2
1112	7\n+3	124	10	3
1113	8\n+4	124	12	4
1114	9\n+5	124	14	5
1115	10\n+6	124	16	6
1116	11\n+7	124	18	7
1117	12\n+8	124	20	8
1118	13\n+9	124	22	9
1119	14\n+10	124	24	10
1120	6\n+1	125	7	1
1121	7\n+2	125	9	2
1122	8\n+3	125	11	3
1123	9\n+4	125	13	4
1124	10\n+5	125	15	5
1125	11\n+6	125	17	6
1126	12\n+7	125	19	7
1127	13\n+8	125	21	8
1128	14\n+9	125	23	9
1129	15\n+10	125	25	10
1183	15\n+4	131	19	4
1184	16\n+5	131	21	5
1185	17\n+6	131	23	6
1186	18\n+7	131	25	7
1187	19\n+8	131	27	8
1188	20\n+9	131	29	9
1189	21\n+10	131	31	10
1190	13\n+1	132	14	1
1191	14\n+2	132	16	2
1192	15\n+3	132	18	3
1193	16\n+4	132	20	4
1194	17\n+5	132	22	5
1195	18\n+6	132	24	6
1196	19\n+7	132	26	7
1197	20\n+8	132	28	8
1198	21\n+9	132	30	9
1199	22\n+10	132	32	10
1200	4\n5\n6	133	15	1
1201	5\n6\n7	133	18	2
1202	6\n7\n8	133	21	3
1203	7\n8\n9	133	24	4
1204	8\n9\n10	133	27	5
1205	9\n10\n11	133	30	6
1206	10\n11\n12	133	33	7
1207	11\n12\n13	133	36	8
1208	12\n13\n14	133	39	9
1209	13\n14\n15	133	42	10
1210	5\n6\n7	134	18	1
1211	6\n7\n8	134	21	2
1212	7\n8\n9	134	24	3
1213	8\n9\n10	134	27	4
1214	9\n10\n11	134	30	5
1215	10\n11\n12	134	33	6
1216	11\n12\n13	134	36	7
1217	12\n13\n14	134	39	8
1218	13\n14\n15	134	42	9
1219	14\n15\n16	134	45	10
1220	6\n7\n8	135	21	1
1221	7\n8\n9	135	24	2
1222	8\n9\n10	135	27	3
1223	9\n10\n11	135	30	4
1224	10\n11\n12	135	33	5
1225	11\n12\n13	135	36	6
1226	12\n13\n14	135	39	7
1227	13\n14\n15	135	42	8
1228	14\n15\n16	135	45	9
1229	15\n16\n17	135	48	10
1230	7\n8\n9	136	24	1
1231	8\n9\n10	136	27	2
1232	9\n10\n11	136	30	3
1233	10\n11\n12	136	33	4
1234	11\n12\n13	136	36	5
1235	12\n13\n14	136	39	6
1236	13\n14\n15	136	42	7
1237	14\n15\n16	136	45	8
1238	15\n16\n17	136	48	9
1239	16\n17\n18	136	51	10
1240	8\n9\n10	137	27	1
1241	9\n10\n11	137	30	2
1242	10\n11\n12	137	33	3
1243	11\n12\n13	137	36	4
1244	12\n13\n14	137	39	5
1245	13\n14\n15	137	42	6
1246	14\n15\n16	137	45	7
1247	15\n16\n17	137	48	8
1248	16\n17\n18	137	51	9
1249	17\n18\n19	137	54	10
1250	9\n10\n11	138	30	1
1251	10\n11\n12	138	33	2
1252	11\n12\n13	138	36	3
1253	12\n13\n14	138	39	4
1254	13\n14\n15	138	42	5
1255	14\n15\n16	138	45	6
1256	15\n16\n17	138	48	7
1257	16\n17\n18	138	51	8
1258	17\n18\n19	138	54	9
1259	18\n19\n20	138	57	10
1260	10\n11\n12	139	33	1
1261	11\n12\n13	139	36	2
1262	12\n13\n14	139	39	3
1263	13\n14\n15	139	42	4
1264	14\n15\n16	139	45	5
1265	15\n16\n17	139	48	6
1266	16\n17\n18	139	51	7
1267	17\n18\n19	139	54	8
1268	18\n19\n20	139	57	9
1270	11\n12\n13	140	36	1
1271	12\n13\n14	140	39	2
1272	13\n14\n15	140	42	3
1273	14\n15\n16	140	45	4
1274	15\n16\n17	140	48	5
1275	16\n17\n18	140	51	6
1276	17\n18\n19	140	54	7
1277	18\n19\n20	140	57	8
1278	19\n20\n21	140	60	9
1279	20\n21\n22	140	63	10
1280	12\n13\n14	141	39	1
1281	13\n14\n15	141	42	2
1282	14\n15\n16	141	45	3
1283	15\n16\n17	141	48	4
1284	16\n17\n18	141	51	5
1285	17\n18\n19	141	54	6
1286	18\n19\n20	141	57	7
1287	19\n20\n21	141	60	8
1288	20\n21\n22	141	63	9
1289	21\n22\n23	141	66	10
1290	13\n14\n15	142	42	1
1291	14\n15\n16	142	45	2
1292	15\n16\n17	142	48	3
1293	16\n17\n18	142	51	4
1294	17\n18\n19	142	54	5
1295	18\n19\n20	142	57	6
1296	19\n20\n21	142	60	7
1297	20\n21\n22	142	63	8
1298	21\n22\n23	142	66	9
1299	22\n23\n24	142	69	10
1338	2\nx13	146	26	9
1334	2\nx9	146	18	5
1335	2\nx10	146	20	6
1336	2\nx11	146	22	7
1337	2\nx12	146	24	8
1339	2\nx14	146	28	10
1340	2\nx6	147	12	1
1341	2\nx7	147	14	2
1342	2\nx8	147	16	3
1343	2\nx9	147	18	4
1344	2\nx10	147	20	5
1345	2\nx11	147	22	6
1346	2\nx12	147	24	7
1347	2\nx13	147	26	8
1348	2\nx14	147	28	9
1300	2\nx2	143	4	1
1301	2\nx3	143	6	2
1302	2\nx4	143	8	3
1303	2\nx5	143	10	4
1304	2\nx6	143	12	5
1305	2\nx7	143	14	6
1306	2\nx8	143	16	7
1307	2\nx9	143	18	8
1308	2\nx10	143	20	9
1309	2\nx11	143	22	10
1310	2\nx3	144	6	1
1311	2\nx4	144	8	2
1312	2\nx5	144	10	3
1313	2\nx6	144	12	4
1314	2\nx7	144	14	5
1315	2\nx8	144	16	6
1316	2\nx9	144	18	7
1317	2\nx10	144	20	8
1318	2\nx11	144	22	9
1319	2\nx12	144	24	10
1320	2\nx4	145	8	1
1321	2\nx5	145	10	2
1322	2\nx6	145	12	3
1323	2\nx7	145	14	4
1324	2\nx8	145	16	5
1325	2\nx9	145	18	6
1326	2\nx10	145	20	7
1327	2\nx11	145	22	8
1328	2\nx12	145	24	9
1329	2\nx13	145	26	10
1330	2\nx5	146	10	1
1331	2\nx6	146	12	2
1332	2\nx7	146	14	3
1333	2\nx8	146	16	4
1362	2\nx10	149	20	3
1363	2\nx11	149	22	4
1364	2\nx12	149	24	5
1365	2\nx13	149	26	6
1366	2\nx14	149	28	7
1367	2\nx15	149	30	8
1368	2\nx16	149	32	9
1369	2\nx17	149	34	10
1370	2\nx9	150	18	1
1371	2\nx10	150	20	2
1372	2\nx11	150	22	3
1373	2\nx12	150	24	4
1398	2\nx19	152	38	9
1399	2\nx20	152	40	10
1400	2\nx2	153	4	1
1401	2\nx3	153	6	2
1402	2\nx4	153	8	3
1374	2\nx13	150	26	5
1375	2\nx14	150	28	6
1376	2\nx15	150	30	7
1377	2\nx16	150	32	8
1378	2\nx17	150	34	9
1379	2\nx18	150	36	10
1380	2\nx10	151	20	1
1381	2\nx11	151	22	2
1382	2\nx12	151	24	3
1383	2\nx13	151	26	4
1384	2\nx14	151	28	5
1385	2\nx15	151	30	6
1386	2\nx16	151	32	7
1387	2\nx17	151	34	8
1388	2\nx18	151	36	9
1389	2\nx19	151	38	10
1390	2\nx11	152	22	1
1391	2\nx12	152	24	2
1392	2\nx13	152	26	3
1393	2\nx14	152	28	4
1394	2\nx15	152	30	5
1395	2\nx16	152	32	6
1396	2\nx17	152	34	7
1397	2\nx18	152	36	8
1403	2\nx5	153	10	4
1404	2\nx6	153	12	5
1405	2\nx7	153	14	6
1406	2\nx8	153	16	7
1407	2\nx9	153	18	8
1408	2\nx10	153	20	9
1409	2\nx11	153	22	10
1410	2\nx3	154	6	1
1411	2\nx4	154	8	2
1412	2\nx5	154	10	3
1413	2\nx6	154	12	4
1414	2\nx7	154	14	5
1415	2\nx8	154	16	6
1416	2\nx9	154	18	7
1417	2\nx10	154	20	8
1418	2\nx11	154	22	9
1419	2\nx12	154	24	10
1420	2\nx4	155	8	1
1421	2\nx5	155	10	2
1422	2\nx6	155	12	3
1423	2\nx7	155	14	4
1424	2\nx8	155	16	5
1425	2\nx9	155	18	6
1350	2\nx7	148	14	1
1351	2\nx8	148	16	2
1352	2\nx9	148	18	3
1353	2\nx10	148	20	4
1354	2\nx11	148	22	5
1355	2\nx12	148	24	6
1356	2\nx13	148	26	7
1357	2\nx14	148	28	8
1358	2\nx15	148	30	9
1359	2\nx16	148	32	10
1360	2\nx8	149	16	1
1361	2\nx9	149	18	2
1495	2\nx16	162	32	6
1496	2\nx17	162	34	7
1497	2\nx18	162	36	8
1498	2\nx19	162	38	9
1499	2\nx20	162	40	10
1500	4\n/2	163	2	1
1501	6\n/2	163	3	2
1502	8\n/2	163	4	3
1503	10\n/2	163	5	4
1504	12\n/2	163	6	5
1505	14\n/2	163	7	6
1473	2\nx12	160	24	4
1474	2\nx13	160	26	5
1475	2\nx14	160	28	6
1476	2\nx15	160	30	7
1477	2\nx16	160	32	8
1478	2\nx17	160	34	9
1427	2\nx11	155	22	8
1428	2\nx12	155	24	9
1429	2\nx13	155	26	10
1430	2\nx5	156	10	1
1431	2\nx6	156	12	2
1450	2\nx7	158	14	1
1432	2\nx7	156	14	3
1433	2\nx8	156	16	4
1434	2\nx9	156	18	5
1435	2\nx10	156	20	6
1436	2\nx11	156	22	7
1437	2\nx12	156	24	8
1438	2\nx13	156	26	9
1439	2\nx14	156	28	10
1440	2\nx6	157	12	1
1441	2\nx7	157	14	2
1442	2\nx8	157	16	3
1443	2\nx9	157	18	4
1444	2\nx10	157	20	5
1445	2\nx11	157	22	6
1446	2\nx12	157	24	7
1447	2\nx13	157	26	8
1448	2\nx14	157	28	9
1449	2\nx15	157	30	10
1479	2\nx18	160	36	10
1480	2\nx10	161	20	1
1481	2\nx11	161	22	2
1482	2\nx12	161	24	3
1483	2\nx13	161	26	4
1484	2\nx14	161	28	5
1485	2\nx15	161	30	6
1486	2\nx16	161	32	7
1487	2\nx17	161	34	8
1488	2\nx18	161	36	9
1489	2\nx19	161	38	10
1490	2\nx11	162	22	1
1491	2\nx12	162	24	2
1492	2\nx13	162	26	3
1493	2\nx14	162	28	4
1494	2\nx15	162	30	5
1451	2\nx8	158	16	2
1452	2\nx9	158	18	3
1453	2\nx10	158	20	4
1454	2\nx11	158	22	5
1455	2\nx12	158	24	6
1456	2\nx13	158	26	7
1457	2\nx14	158	28	8
1458	2\nx15	158	30	9
1459	2\nx16	158	32	10
1460	2\nx8	159	16	1
1461	2\nx9	159	18	2
1462	2\nx10	159	20	3
1463	2\nx11	159	22	4
1464	2\nx12	159	24	5
1465	2\nx13	159	26	6
1466	2\nx14	159	28	7
1467	2\nx15	159	30	8
1468	2\nx16	159	32	9
1469	2\nx17	159	34	10
1470	2\nx9	160	18	1
1471	2\nx10	160	20	2
1472	2\nx11	160	22	3
1533	16\n/2	166	8	4
1534	18\n/2	166	9	5
1563	22\n/2	169	11	4
1564	24\n/2	169	12	5
1565	26\n/2	169	13	6
1566	28\n/2	169	14	7
1535	20\n/2	166	10	6
1536	22\n/2	166	11	7
1537	24\n/2	166	12	8
1538	26\n/2	166	13	9
1539	28\n/2	166	14	10
1540	12\n/2	167	6	1
1541	14\n/2	167	7	2
1542	16\n/2	167	8	3
1543	18\n/2	167	9	4
1544	20\n/2	167	10	5
1545	22\n/2	167	11	6
1546	24\n/2	167	12	7
1547	26\n/2	167	13	8
1548	28\n/2	167	14	9
1549	30\n/2	167	15	10
1550	14\n/2	168	7	1
1551	16\n/2	168	8	2
1552	18\n/2	168	9	3
1553	20\n/2	168	10	4
1554	22\n/2	168	11	5
939	16\n+10	106	26	10
1555	24\n/2	168	12	6
1556	26\n/2	168	13	7
1557	28\n/2	168	14	8
1558	30\n/2	168	15	9
1559	32\n/2	168	16	10
1560	16\n/2	169	8	1
1561	18\n/2	169	9	2
1562	20\n/2	169	10	3
1579	36\n/2	170	18	10
1580	20\n/2	171	10	1
1581	22\n/2	171	11	2
1582	24\n/2	171	12	3
1583	26\n/2	171	13	4
1584	28\n/2	171	14	5
1567	30\n/2	169	15	8
1568	32\n/2	169	16	9
1569	34\n/2	169	17	10
1570	18\n/2	170	9	1
1571	20\n/2	170	10	2
1572	22\n/2	170	11	3
1573	24\n/2	170	12	4
1574	26\n/2	170	13	5
1575	28\n/2	170	14	6
1576	30\n/2	170	15	7
1577	32\n/2	170	16	8
1578	34\n/2	170	17	9
1585	30\n/2	171	15	6
1586	32\n/2	171	16	7
1507	18\n/2	163	9	8
1508	20\n/2	163	10	9
1509	22\n/2	163	11	10
1510	6\n/2	164	3	1
1511	8\n/2	164	4	2
1512	10\n/2	164	5	3
1513	12\n/2	164	6	4
1514	14\n/2	164	7	5
1515	16\n/2	164	8	6
1516	18\n/2	164	9	7
1517	20\n/2	164	10	8
1518	22\n/2	164	11	9
1519	24\n/2	164	12	10
1520	8\n/2	165	4	1
1521	10\n/2	165	5	2
1522	12\n/2	165	6	3
1523	14\n/2	165	7	4
1524	16\n/2	165	8	5
1525	18\n/2	165	9	6
1526	20\n/2	165	10	7
1527	22\n/2	165	11	8
1528	24\n/2	165	12	9
1529	26\n/2	165	13	10
1530	10\n/2	166	5	1
1531	12\n/2	166	6	2
1532	14\n/2	166	7	3
1614	14\n/2	174	7	5
1615	16\n/2	174	8	6
1644	20\n/2	177	10	5
1645	22\n/2	177	11	6
1646	24\n/2	177	12	7
1647	26\n/2	177	13	8
1616	18\n/2	174	9	7
1617	20\n/2	174	10	8
1618	22\n/2	174	11	9
1619	24\n/2	174	12	10
1620	8\n/2	175	4	1
1621	10\n/2	175	5	2
1622	12\n/2	175	6	3
1623	14\n/2	175	7	4
1624	16\n/2	175	8	5
1625	18\n/2	175	9	6
1626	20\n/2	175	10	7
1627	22\n/2	175	11	8
1628	24\n/2	175	12	9
1629	26\n/2	175	13	10
1630	10\n/2	176	5	1
1631	12\n/2	176	6	2
1632	14\n/2	176	7	3
1633	16\n/2	176	8	4
1634	18\n/2	176	9	5
1635	20\n/2	176	10	6
1020	6\n+1	115	7	1
1636	22\n/2	176	11	7
1637	24\n/2	176	12	8
1638	26\n/2	176	13	9
1639	28\n/2	176	14	10
1640	12\n/2	177	6	1
1641	14\n/2	177	7	2
1642	16\n/2	177	8	3
1643	18\n/2	177	9	4
1660	16\n/2	179	8	1
1661	18\n/2	179	9	2
1662	20\n/2	179	10	3
1663	22\n/2	179	11	4
1664	24\n/2	179	12	5
1665	26\n/2	179	13	6
1648	28\n/2	177	14	9
1649	30\n/2	177	15	10
1650	14\n/2	178	7	1
1651	16\n/2	178	8	2
1652	18\n/2	178	9	3
1653	20\n/2	178	10	4
1654	22\n/2	178	11	5
1655	24\n/2	178	12	6
1656	26\n/2	178	13	7
1657	28\n/2	178	14	8
1658	30\n/2	178	15	9
1659	32\n/2	178	16	10
1666	28\n/2	179	14	7
1667	30\n/2	179	15	8
1588	36\n/2	171	18	9
1589	38\n/2	171	19	10
1590	22\n/2	172	11	1
1591	24\n/2	172	12	2
1592	26\n/2	172	13	3
1593	28\n/2	172	14	4
1594	30\n/2	172	15	5
1595	32\n/2	172	16	6
1596	34\n/2	172	17	7
1597	36\n/2	172	18	8
1598	38\n/2	172	19	9
1599	40\n/2	172	20	10
1600	4\n/2	173	2	1
1601	6\n/2	173	3	2
1602	8\n/2	173	4	3
1603	10\n/2	173	5	4
1604	12\n/2	173	6	5
1605	14\n/2	173	7	6
1606	16\n/2	173	8	7
1607	18\n/2	173	9	8
1608	20\n/2	173	10	9
1609	22\n/2	173	11	10
1610	6\n/2	174	3	1
1611	8\n/2	174	4	2
1612	10\n/2	174	5	3
1613	12\n/2	174	6	4
1703	8\n+4	183	12	4
1704	9\n+5	183	14	5
1705	10\n+6	183	16	6
1706	11\n+7	183	18	7
1707	12\n+8	183	20	8
1708	13\n+9	183	22	9
1709	14\n+10	183	24	10
1710	6\n+1	184	7	1
1711	7\n+2	184	9	2
1712	8\n+3	184	11	3
1713	9\n+4	184	13	4
1714	10\n+5	184	15	5
1715	11\n+6	184	17	6
1716	12\n+7	184	19	7
1717	13\n+8	184	21	8
1718	14\n+9	184	23	9
1719	15\n+10	184	25	10
1720	7\n+1	185	8	1
1721	8\n+2	185	10	2
1722	9\n+3	185	12	3
1723	10\n+4	185	14	4
1724	11\n+5	185	16	5
1725	12\n+6	185	18	6
1726	13\n+7	185	20	7
1727	14\n+8	185	22	8
1728	15\n+9	185	24	9
1101	5\n+2	123	7	2
1697	36\n/2	182	18	8
1698	38\n/2	182	19	9
1699	40\n/2	182	20	10
1729	16\n+10	185	26	10
1730	8\n+1	186	9	1
1731	9\n+2	186	11	2
1732	10\n+3	186	13	3
1733	11\n+4	186	15	4
1734	12\n+5	186	17	5
1735	13\n+6	186	19	6
1736	14\n+7	186	21	7
1737	15\n+8	186	23	8
1738	16\n+9	186	25	9
1739	17\n+10	186	27	10
1740	9\n+1	187	10	1
1741	10\n+2	187	12	2
1742	11\n+3	187	14	3
1743	12\n+4	187	16	4
1744	13\n+5	187	18	5
1745	14\n+6	187	20	6
1746	15\n+7	187	22	7
1747	16\n+8	187	24	8
1748	17\n+9	187	26	9
1691	24\n/2	182	12	2
1692	26\n/2	182	13	3
1693	28\n/2	182	14	4
1694	30\n/2	182	15	5
1695	32\n/2	182	16	6
1669	34\n/2	179	17	10
1670	18\n/2	180	9	1
1671	20\n/2	180	10	2
1696	34\n/2	182	17	7
1672	22\n/2	180	11	3
1673	24\n/2	180	12	4
1674	26\n/2	180	13	5
1675	28\n/2	180	14	6
1676	30\n/2	180	15	7
1677	32\n/2	180	16	8
1678	34\n/2	180	17	9
1679	36\n/2	180	18	10
1680	20\n/2	181	10	1
1681	22\n/2	181	11	2
1682	24\n/2	181	12	3
1683	26\n/2	181	13	4
1684	28\n/2	181	14	5
1685	30\n/2	181	15	6
1686	32\n/2	181	16	7
1687	34\n/2	181	17	8
1688	36\n/2	181	18	9
1689	38\n/2	181	19	10
1690	22\n/2	182	11	1
1700	5\n+1	183	6	1
1701	6\n+2	183	8	2
1702	7\n+3	183	10	3
1778	20\n+9	190	29	9
1779	21\n+10	190	31	10
1780	13\n+1	191	14	1
1781	14\n+2	191	16	2
1782	15\n+3	191	18	3
1783	16\n+4	191	20	4
1784	17\n+5	191	22	5
1785	18\n+6	191	24	6
1786	19\n+7	191	26	7
1787	20\n+8	191	28	8
1788	21\n+9	191	30	9
1789	22\n+10	191	32	10
1790	14\n+1	192	15	1
1791	15\n+2	192	17	2
1792	16\n+3	192	19	3
1793	17\n+4	192	21	4
1794	18\n+5	192	23	5
1795	19\n+6	192	25	6
1796	20\n+7	192	27	7
1797	21\n+8	192	29	8
1798	22\n+9	192	31	9
1799	23\n+10	192	33	10
1800	5\n+1	193	6	1
1801	6\n+2	193	8	2
1802	7\n+3	193	10	3
1803	8\n+4	193	12	4
1182	14\n+3	131	17	3
1804	9\n+5	193	14	5
1805	10\n+6	193	16	6
1806	11\n+7	193	18	7
1807	12\n+8	193	20	8
1808	13\n+9	193	22	9
1809	14\n+10	193	24	10
1810	6\n+1	194	7	1
1811	7\n+2	194	9	2
1812	8\n+3	194	11	3
1813	9\n+4	194	13	4
1814	10\n+5	194	15	5
1815	11\n+6	194	17	6
1816	12\n+7	194	19	7
1817	13\n+8	194	21	8
1818	14\n+9	194	23	9
1819	15\n+10	194	25	10
1820	7\n+1	195	8	1
1821	8\n+2	195	10	2
1822	9\n+3	195	12	3
1823	10\n+4	195	14	4
1824	11\n+5	195	16	5
1825	12\n+6	195	18	6
1826	13\n+7	195	20	7
1827	14\n+8	195	22	8
1828	15\n+9	195	24	9
1829	16\n+10	195	26	10
1750	10\n+1	188	11	1
1751	11\n+2	188	13	2
1752	12\n+3	188	15	3
1753	13\n+4	188	17	4
1754	14\n+5	188	19	5
1755	15\n+6	188	21	6
1756	16\n+7	188	23	7
1757	17\n+8	188	25	8
1758	18\n+9	188	27	9
1759	19\n+10	188	29	10
1760	11\n+1	189	12	1
1761	12\n+2	189	14	2
1762	13\n+3	189	16	3
1763	14\n+4	189	18	4
1764	15\n+5	189	20	5
1765	16\n+6	189	22	6
1766	17\n+7	189	24	7
1767	18\n+8	189	26	8
1768	19\n+9	189	28	9
1769	20\n+10	189	30	10
1770	12\n+1	190	13	1
1771	13\n+2	190	15	2
1772	14\n+3	190	17	3
1773	15\n+4	190	19	4
1774	16\n+5	190	21	5
1775	17\n+6	190	23	6
1776	18\n+7	190	25	7
1777	19\n+8	190	27	8
1859	19\n+10	198	29	10
1269	19\n20\n21	139	60	10
1860	11\n+1	199	12	1
1861	12\n+2	199	14	2
1862	13\n+3	199	16	3
1863	14\n+4	199	18	4
1864	15\n+5	199	20	5
1865	16\n+6	199	22	6
1866	17\n+7	199	24	7
1867	18\n+8	199	26	8
1868	19\n+9	199	28	9
1869	20\n+10	199	30	10
1870	12\n+1	200	13	1
1871	13\n+2	200	15	2
1872	14\n+3	200	17	3
1873	15\n+4	200	19	4
1874	16\n+5	200	21	5
1875	17\n+6	200	23	6
1876	18\n+7	200	25	7
1877	19\n+8	200	27	8
1878	20\n+9	200	29	9
1879	21\n+10	200	31	10
1880	13\n+1	201	14	1
1881	14\n+2	201	16	2
1882	15\n+3	201	18	3
1883	16\n+4	201	20	4
1884	17\n+5	201	22	5
1831	9\n+2	196	11	2
1885	18\n+6	201	24	6
1886	19\n+7	201	26	7
1887	20\n+8	201	28	8
1888	21\n+9	201	30	9
1889	22\n+10	201	32	10
1890	14\n+1	202	15	1
1891	15\n+2	202	17	2
1892	16\n+3	202	19	3
1893	17\n+4	202	21	4
1894	18\n+5	202	23	5
1895	19\n+6	202	25	6
1896	20\n+7	202	27	7
1897	21\n+8	202	29	8
1898	22\n+9	202	31	9
1899	23\n+10	202	33	10
1900	5\n+1	203	6	1
1901	6\n+2	203	8	2
1902	7\n+3	203	10	3
1903	8\n+4	203	12	4
1904	9\n+5	203	14	5
1905	10\n+6	203	16	6
1906	11\n+7	203	18	7
1907	12\n+8	203	20	8
1908	13\n+9	203	22	9
1909	14\n+10	203	24	10
1910	6\n+1	204	7	1
1832	10\n+3	196	13	3
1833	11\n+4	196	15	4
1834	12\n+5	196	17	5
1835	13\n+6	196	19	6
1836	14\n+7	196	21	7
1837	15\n+8	196	23	8
1838	16\n+9	196	25	9
1839	17\n+10	196	27	10
1840	9\n+1	197	10	1
1841	10\n+2	197	12	2
1842	11\n+3	197	14	3
1843	12\n+4	197	16	4
1844	13\n+5	197	18	5
1845	14\n+6	197	20	6
1846	15\n+7	197	22	7
1847	16\n+8	197	24	8
1848	17\n+9	197	26	9
1849	18\n+10	197	28	10
1850	10\n+1	198	11	1
1851	11\n+2	198	13	2
1852	12\n+3	198	15	3
1853	13\n+4	198	17	4
1854	14\n+5	198	19	5
1855	15\n+6	198	21	6
1856	16\n+7	198	23	7
1857	17\n+8	198	25	8
1858	18\n+9	198	27	9
1940	9\n+1	207	10	1
1941	10\n+2	207	12	2
1942	11\n+3	207	14	3
1943	12\n+4	207	16	4
1944	13\n+5	207	18	5
1945	14\n+6	207	20	6
1946	15\n+7	207	22	7
1947	16\n+8	207	24	8
1948	17\n+9	207	26	9
1949	18\n+10	207	28	10
1950	10\n+1	208	11	1
1951	11\n+2	208	13	2
1952	12\n+3	208	15	3
1953	13\n+4	208	17	4
1954	14\n+5	208	19	5
1955	15\n+6	208	21	6
1956	16\n+7	208	23	7
1957	17\n+8	208	25	8
1958	18\n+9	208	27	9
1959	19\n+10	208	29	10
1960	11\n+1	209	12	1
1961	12\n+2	209	14	2
1962	13\n+3	209	16	3
1963	14\n+4	209	18	4
1964	15\n+5	209	20	5
1965	16\n+6	209	22	6
1912	8\n+3	204	11	3
1966	17\n+7	209	24	7
1967	18\n+8	209	26	8
1968	19\n+9	209	28	9
1969	20\n+10	209	30	10
1970	12\n+1	210	13	1
1971	13\n+2	210	15	2
1972	14\n+3	210	17	3
1973	15\n+4	210	19	4
1974	16\n+5	210	21	5
1975	17\n+6	210	23	6
1976	18\n+7	210	25	7
1977	19\n+8	210	27	8
1978	20\n+9	210	29	9
1979	21\n+10	210	31	10
1980	13\n+1	211	14	1
1981	14\n+2	211	16	2
1982	15\n+3	211	18	3
1983	16\n+4	211	20	4
1984	17\n+5	211	22	5
1985	18\n+6	211	24	6
1986	19\n+7	211	26	7
1987	20\n+8	211	28	8
1988	21\n+9	211	30	9
1989	22\n+10	211	32	10
1990	14\n+1	212	15	1
1991	15\n+2	212	17	2
1349	2\nx15	147	30	10
1913	9\n+4	204	13	4
1914	10\n+5	204	15	5
1915	11\n+6	204	17	6
1916	12\n+7	204	19	7
1917	13\n+8	204	21	8
1918	14\n+9	204	23	9
1919	15\n+10	204	25	10
1920	7\n+1	205	8	1
1921	8\n+2	205	10	2
1922	9\n+3	205	12	3
1923	10\n+4	205	14	4
1924	11\n+5	205	16	5
1925	12\n+6	205	18	6
1926	13\n+7	205	20	7
1927	14\n+8	205	22	8
1928	15\n+9	205	24	9
1929	16\n+10	205	26	10
1930	8\n+1	206	9	1
1931	9\n+2	206	11	2
1932	10\n+3	206	13	3
1933	11\n+4	206	15	4
1934	12\n+5	206	17	5
1935	13\n+6	206	19	6
1936	14\n+7	206	21	7
1937	15\n+8	206	23	8
1938	16\n+9	206	25	9
1939	17\n+10	206	27	10
1993	17\n+4	212	21	4
1994	18\n+5	212	23	5
1995	19\n+6	212	25	6
1996	20\n+7	212	27	7
1997	21\n+8	212	29	8
1998	22\n+9	212	31	9
1999	23\n+10	212	33	10
2000	5\n6\n7	213	18	1
2001	6\n7\n8	213	21	2
2002	7\n8\n9	213	24	3
2003	8\n9\n10	213	27	4
2004	9\n10\n11	213	30	5
2005	10\n11\n12	213	33	6
2006	11\n12\n13	213	36	7
2007	12\n13\n14	213	39	8
2008	13\n14\n15	213	42	9
2009	14\n15\n16	213	45	10
2010	6\n7\n8	214	21	1
2011	7\n8\n9	214	24	2
2012	8\n9\n10	214	27	3
2013	9\n10\n11	214	30	4
2014	10\n11\n12	214	33	5
2015	11\n12\n13	214	36	6
2016	12\n13\n14	214	39	7
2017	13\n14\n15	214	42	8
2018	14\n15\n16	214	45	9
2019	15\n16\n17	214	48	10
2020	7\n8\n9	215	24	1
2021	8\n9\n10	215	27	2
2022	9\n10\n11	215	30	3
2023	10\n11\n12	215	33	4
2024	11\n12\n13	215	36	5
2025	12\n13\n14	215	39	6
2026	13\n14\n15	215	42	7
2027	14\n15\n16	215	45	8
2028	15\n16\n17	215	48	9
2029	16\n17\n18	215	51	10
2030	8\n9\n10	216	27	1
2031	9\n10\n11	216	30	2
2032	10\n11\n12	216	33	3
2033	11\n12\n13	216	36	4
2034	12\n13\n14	216	39	5
2035	13\n14\n15	216	42	6
2036	14\n15\n16	216	45	7
2037	15\n16\n17	216	48	8
2038	16\n17\n18	216	51	9
2039	17\n18\n19	216	54	10
2040	9\n10\n11	217	30	1
2041	10\n11\n12	217	33	2
2042	11\n12\n13	217	36	3
2043	12\n13\n14	217	39	4
2044	13\n14\n15	217	42	5
2045	14\n15\n16	217	45	6
2046	15\n16\n17	217	48	7
2047	16\n17\n18	217	51	8
2048	17\n18\n19	217	54	9
2049	18\n19\n20	217	57	10
2050	10\n11\n12	218	33	1
2051	11\n12\n13	218	36	2
2052	12\n13\n14	218	39	3
2053	13\n14\n15	218	42	4
2054	14\n15\n16	218	45	5
2055	15\n16\n17	218	48	6
2056	16\n17\n18	218	51	7
2057	17\n18\n19	218	54	8
2058	18\n19\n20	218	57	9
2059	19\n20\n21	218	60	10
2060	11\n12\n13	219	36	1
2061	12\n13\n14	219	39	2
2062	13\n14\n15	219	42	3
2063	14\n15\n16	219	45	4
2064	15\n16\n17	219	48	5
2065	16\n17\n18	219	51	6
2066	17\n18\n19	219	54	7
2067	18\n19\n20	219	57	8
2068	19\n20\n21	219	60	9
2069	20\n21\n22	219	63	10
2070	12\n13\n14	220	39	1
2071	13\n14\n15	220	42	2
2072	14\n15\n16	220	45	3
2073	15\n16\n17	220	48	4
2074	16\n17\n18	220	51	5
2075	17\n18\n19	220	54	6
2076	18\n19\n20	220	57	7
2077	19\n20\n21	220	60	8
2078	20\n21\n22	220	63	9
2079	21\n22\n23	220	66	10
2143	3\nx9	227	27	4
2081	14\n15\n16	221	45	2
2082	15\n16\n17	221	48	3
2083	16\n17\n18	221	51	4
2084	17\n18\n19	221	54	5
2085	18\n19\n20	221	57	6
2086	19\n20\n21	221	60	7
2087	20\n21\n22	221	63	8
2088	21\n22\n23	221	66	9
2089	22\n23\n24	221	69	10
2090	14\n15\n16	222	45	1
2091	15\n16\n17	222	48	2
2092	16\n17\n18	222	51	3
2093	17\n18\n19	222	54	4
2094	18\n19\n20	222	57	5
2095	19\n20\n21	222	60	6
2096	20\n21\n22	222	63	7
2097	21\n22\n23	222	66	8
2098	22\n23\n24	222	69	9
2099	23\n24\n25	222	72	10
2154	3\nx11	228	33	5
2107	3\nx9	223	27	8
2144	3\nx10	227	30	5
2145	3\nx11	227	33	6
2146	3\nx12	227	36	7
2147	3\nx13	227	39	8
2148	3\nx14	227	42	9
2149	3\nx15	227	45	10
2150	3\nx7	228	21	1
2151	3\nx8	228	24	2
2152	3\nx9	228	27	3
2153	3\nx10	228	30	4
2108	3\nx10	223	30	9
2109	3\nx11	223	33	10
2110	3\nx3	224	9	1
2111	3\nx4	224	12	2
2112	3\nx5	224	15	3
2113	3\nx6	224	18	4
2155	3\nx12	228	36	6
2156	3\nx13	228	39	7
2157	3\nx14	228	42	8
2100	3\nx2	223	6	1
2101	3\nx3	223	9	2
2102	3\nx4	223	12	3
2103	3\nx5	223	15	4
2104	3\nx6	223	18	5
2105	3\nx7	223	21	6
2106	3\nx8	223	24	7
2114	3\nx7	224	21	5
2115	3\nx8	224	24	6
2116	3\nx9	224	27	7
2117	3\nx10	224	30	8
2118	3\nx11	224	33	9
2119	3\nx12	224	36	10
2120	3\nx4	225	12	1
2121	3\nx5	225	15	2
2122	3\nx6	225	18	3
2123	3\nx7	225	21	4
2124	3\nx8	225	24	5
2125	3\nx9	225	27	6
2126	3\nx10	225	30	7
2127	3\nx11	225	33	8
2128	3\nx12	225	36	9
2129	3\nx13	225	39	10
2130	3\nx5	226	15	1
2131	3\nx6	226	18	2
2132	3\nx7	226	21	3
2133	3\nx8	226	24	4
2134	3\nx9	226	27	5
2135	3\nx10	226	30	6
2136	3\nx11	226	33	7
2137	3\nx12	226	36	8
2138	3\nx13	226	39	9
2139	3\nx14	226	42	10
2140	3\nx6	227	18	1
2141	3\nx7	227	21	2
2142	3\nx8	227	24	3
2162	3\nx10	229	30	3
2163	3\nx11	229	33	4
2164	3\nx12	229	36	5
2165	3\nx13	229	39	6
2166	3\nx14	229	42	7
2167	3\nx15	229	45	8
2168	3\nx16	229	48	9
2169	3\nx17	229	51	10
2170	3\nx9	230	27	1
2171	3\nx10	230	30	2
2172	3\nx11	230	33	3
2173	3\nx12	230	36	4
2174	3\nx13	230	39	5
2175	3\nx14	230	42	6
2176	3\nx15	230	45	7
2177	3\nx16	230	48	8
2206	3\nx8	233	24	7
2207	3\nx9	233	27	8
2208	3\nx10	233	30	9
2178	3\nx17	230	51	9
2179	3\nx18	230	54	10
2180	3\nx10	231	30	1
2181	3\nx11	231	33	2
2182	3\nx12	231	36	3
2183	3\nx13	231	39	4
2184	3\nx14	231	42	5
2185	3\nx15	231	45	6
2186	3\nx16	231	48	7
2187	3\nx17	231	51	8
2188	3\nx18	231	54	9
2189	3\nx19	231	57	10
2190	3\nx11	232	33	1
2191	3\nx12	232	36	2
2192	3\nx13	232	39	3
2193	3\nx14	232	42	4
2194	3\nx15	232	45	5
2195	3\nx16	232	48	6
2196	3\nx17	232	51	7
2197	3\nx18	232	54	8
2198	3\nx19	232	57	9
2199	3\nx20	232	60	10
2200	3\nx2	233	6	1
2201	3\nx3	233	9	2
2202	3\nx4	233	12	3
2203	3\nx5	233	15	4
2204	3\nx6	233	18	5
2205	3\nx7	233	21	6
2209	3\nx11	233	33	10
2210	3\nx3	234	9	1
2211	3\nx4	234	12	2
2212	3\nx5	234	15	3
2213	3\nx6	234	18	4
2214	3\nx7	234	21	5
2215	3\nx8	234	24	6
2216	3\nx9	234	27	7
2217	3\nx10	234	30	8
2218	3\nx11	234	33	9
2219	3\nx12	234	36	10
2220	3\nx4	235	12	1
2221	3\nx5	235	15	2
2222	3\nx6	235	18	3
2223	3\nx7	235	21	4
2224	3\nx8	235	24	5
2225	3\nx9	235	27	6
2226	3\nx10	235	30	7
2227	3\nx11	235	33	8
2228	3\nx12	235	36	9
2229	3\nx13	235	39	10
2230	3\nx5	236	15	1
2231	3\nx6	236	18	2
2232	3\nx7	236	21	3
2233	3\nx8	236	24	4
2234	3\nx9	236	27	5
2235	3\nx10	236	30	6
2159	3\nx16	228	48	10
2160	3\nx8	229	24	1
2161	3\nx9	229	27	2
2307	27\n/3	243	9	8
2308	30\n/3	243	10	9
2309	33\n/3	243	11	10
2310	9\n/3	244	3	1
2311	12\n/3	244	4	2
2312	15\n/3	244	5	3
2313	18\n/3	244	6	4
2314	21\n/3	244	7	5
2315	24\n/3	244	8	6
2265	3\nx13	239	39	6
2266	3\nx14	239	42	7
2267	3\nx15	239	45	8
2268	3\nx16	239	48	9
2269	3\nx17	239	51	10
2270	3\nx9	240	27	1
2271	3\nx10	240	30	2
2272	3\nx11	240	33	3
2273	3\nx12	240	36	4
2274	3\nx13	240	39	5
2275	3\nx14	240	42	6
2276	3\nx15	240	45	7
2277	3\nx16	240	48	8
2251	3\nx8	238	24	2
2278	3\nx17	240	51	9
2279	3\nx18	240	54	10
2280	3\nx10	241	30	1
2237	3\nx12	236	36	8
2238	3\nx13	236	39	9
2239	3\nx14	236	42	10
2240	3\nx6	237	18	1
2241	3\nx7	237	21	2
2242	3\nx8	237	24	3
2243	3\nx9	237	27	4
2244	3\nx10	237	30	5
2245	3\nx11	237	33	6
2246	3\nx12	237	36	7
2247	3\nx13	237	39	8
2248	3\nx14	237	42	9
2249	3\nx15	237	45	10
2250	3\nx7	238	21	1
2281	3\nx11	241	33	2
2282	3\nx12	241	36	3
2283	3\nx13	241	39	4
2284	3\nx14	241	42	5
2285	3\nx15	241	45	6
2286	3\nx16	241	48	7
2287	3\nx17	241	51	8
2288	3\nx18	241	54	9
2289	3\nx19	241	57	10
2290	3\nx11	242	33	1
2291	3\nx12	242	36	2
2292	3\nx13	242	39	3
2293	3\nx14	242	42	4
2294	3\nx15	242	45	5
2295	3\nx16	242	48	6
2252	3\nx9	238	27	3
2253	3\nx10	238	30	4
2254	3\nx11	238	33	5
2255	3\nx12	238	36	6
2256	3\nx13	238	39	7
2257	3\nx14	238	42	8
2258	3\nx15	238	45	9
2259	3\nx16	238	48	10
2260	3\nx8	239	24	1
2261	3\nx9	239	27	2
2262	3\nx10	239	30	3
2263	3\nx11	239	33	4
2264	3\nx12	239	36	5
2296	3\nx17	242	51	7
2297	3\nx18	242	54	8
2298	3\nx19	242	57	9
2299	3\nx20	242	60	10
2300	6\n/3	243	2	1
2301	9\n/3	243	3	2
2302	12\n/3	243	4	3
2303	15\n/3	243	5	4
2304	18\n/3	243	6	5
2305	21\n/3	243	7	6
2306	24\n/3	243	8	7
2342	24\n/3	247	8	3
2343	27\n/3	247	9	4
2344	30\n/3	247	10	5
2373	36\n/3	250	12	4
2374	39\n/3	250	13	5
1426	2\nx10	155	20	7
2345	33\n/3	247	11	6
2346	36\n/3	247	12	7
2347	39\n/3	247	13	8
2348	42\n/3	247	14	9
2349	45\n/3	247	15	10
2350	21\n/3	248	7	1
2351	24\n/3	248	8	2
2352	27\n/3	248	9	3
2353	30\n/3	248	10	4
2354	33\n/3	248	11	5
2355	36\n/3	248	12	6
2356	39\n/3	248	13	7
2357	42\n/3	248	14	8
2358	45\n/3	248	15	9
2359	48\n/3	248	16	10
2360	24\n/3	249	8	1
2361	27\n/3	249	9	2
2362	30\n/3	249	10	3
2363	33\n/3	249	11	4
2364	36\n/3	249	12	5
2394	45\n/3	252	15	5
2365	39\n/3	249	13	6
2366	42\n/3	249	14	7
2367	45\n/3	249	15	8
2368	48\n/3	249	16	9
2369	51\n/3	249	17	10
2370	27\n/3	250	9	1
2371	30\n/3	250	10	2
2372	33\n/3	250	11	3
2389	57\n/3	251	19	10
2390	33\n/3	252	11	1
2391	36\n/3	252	12	2
2392	39\n/3	252	13	3
2393	42\n/3	252	14	4
2375	42\n/3	250	14	6
2376	45\n/3	250	15	7
2377	48\n/3	250	16	8
2378	51\n/3	250	17	9
2379	54\n/3	250	18	10
2380	30\n/3	251	10	1
2381	33\n/3	251	11	2
2382	36\n/3	251	12	3
2383	39\n/3	251	13	4
2384	42\n/3	251	14	5
2385	45\n/3	251	15	6
2386	48\n/3	251	16	7
2387	51\n/3	251	17	8
2388	54\n/3	251	18	9
2395	48\n/3	252	16	6
2396	51\n/3	252	17	7
2317	30\n/3	244	10	8
2318	33\n/3	244	11	9
2319	36\n/3	244	12	10
2320	12\n/3	245	4	1
2321	15\n/3	245	5	2
2322	18\n/3	245	6	3
2323	21\n/3	245	7	4
2324	24\n/3	245	8	5
2325	27\n/3	245	9	6
2326	30\n/3	245	10	7
2327	33\n/3	245	11	8
2328	36\n/3	245	12	9
2329	39\n/3	245	13	10
2330	15\n/3	246	5	1
2331	18\n/3	246	6	2
2332	21\n/3	246	7	3
2333	24\n/3	246	8	4
2334	27\n/3	246	9	5
2335	30\n/3	246	10	6
2336	33\n/3	246	11	7
2337	36\n/3	246	12	8
2338	39\n/3	246	13	9
2339	42\n/3	246	14	10
2340	18\n/3	247	6	1
2341	21\n/3	247	7	2
2422	18\n/3	255	6	3
2423	21\n/3	255	7	4
2424	24\n/3	255	8	5
2452	27\n/3	258	9	3
2453	30\n/3	258	10	4
2468	48\n/3	259	16	9
2425	27\n/3	255	9	6
2426	30\n/3	255	10	7
2427	33\n/3	255	11	8
2428	36\n/3	255	12	9
2429	39\n/3	255	13	10
2430	15\n/3	256	5	1
2431	18\n/3	256	6	2
2432	21\n/3	256	7	3
2433	24\n/3	256	8	4
2434	27\n/3	256	9	5
2435	30\n/3	256	10	6
2436	33\n/3	256	11	7
2437	36\n/3	256	12	8
2438	39\n/3	256	13	9
2439	42\n/3	256	14	10
2440	18\n/3	257	6	1
2441	21\n/3	257	7	2
2442	24\n/3	257	8	3
2443	27\n/3	257	9	4
2444	30\n/3	257	10	5
2445	33\n/3	257	11	6
2475	42\n/3	260	14	6
2446	36\n/3	257	12	7
2447	39\n/3	257	13	8
2448	42\n/3	257	14	9
2449	45\n/3	257	15	10
2450	21\n/3	258	7	1
2451	24\n/3	258	8	2
2469	51\n/3	259	17	10
2470	27\n/3	260	9	1
2471	30\n/3	260	10	2
2472	33\n/3	260	11	3
2473	36\n/3	260	12	4
2474	39\n/3	260	13	5
2454	33\n/3	258	11	5
2455	36\n/3	258	12	6
2456	39\n/3	258	13	7
2457	42\n/3	258	14	8
2458	45\n/3	258	15	9
2459	48\n/3	258	16	10
2460	24\n/3	259	8	1
2461	27\n/3	259	9	2
2462	30\n/3	259	10	3
2463	33\n/3	259	11	4
2464	36\n/3	259	12	5
2465	39\n/3	259	13	6
2466	42\n/3	259	14	7
2467	45\n/3	259	15	8
2476	45\n/3	260	15	7
2477	48\n/3	260	16	8
1506	16\n/2	163	8	7
2398	57\n/3	252	19	9
2399	60\n/3	252	20	10
2400	6\n/3	253	2	1
2401	9\n/3	253	3	2
2402	12\n/3	253	4	3
2403	15\n/3	253	5	4
2404	18\n/3	253	6	5
2405	21\n/3	253	7	6
2406	24\n/3	253	8	7
2407	27\n/3	253	9	8
2408	30\n/3	253	10	9
2409	33\n/3	253	11	10
2410	9\n/3	254	3	1
2411	12\n/3	254	4	2
2412	15\n/3	254	5	3
2413	18\n/3	254	6	4
2414	21\n/3	254	7	5
2415	24\n/3	254	8	6
2416	27\n/3	254	9	7
2417	30\n/3	254	10	8
2418	33\n/3	254	11	9
2419	36\n/3	254	12	10
2420	12\n/3	255	4	1
2421	15\n/3	255	5	2
2513	10\n+4	264	14	4
2514	11\n+5	264	16	5
2515	12\n+6	264	18	6
2516	13\n+7	264	20	7
2517	14\n+8	264	22	8
2518	15\n+9	264	24	9
2519	16\n+10	264	26	10
2520	8\n+1	265	9	1
2521	9\n+2	265	11	2
2522	10\n+3	265	13	3
2523	11\n+4	265	15	4
2524	12\n+5	265	17	5
2525	13\n+6	265	19	6
2526	14\n+7	265	21	7
2527	15\n+8	265	23	8
2528	16\n+9	265	25	9
2529	17\n+10	265	27	10
2530	9\n+1	266	10	1
2531	10\n+2	266	12	2
2532	11\n+3	266	14	3
2533	12\n+4	266	16	4
2534	13\n+5	266	18	5
2535	14\n+6	266	20	6
2536	15\n+7	266	22	7
2537	16\n+8	266	24	8
2538	17\n+9	266	26	9
2539	18\n+10	266	28	10
2485	45\n/3	261	15	6
2540	10\n+1	267	11	1
2541	11\n+2	267	13	2
2542	12\n+3	267	15	3
2543	13\n+4	267	17	4
2544	14\n+5	267	19	5
2545	15\n+6	267	21	6
2546	16\n+7	267	23	7
2547	17\n+8	267	25	8
2548	18\n+9	267	27	9
2549	19\n+10	267	29	10
2550	11\n+1	268	12	1
2551	12\n+2	268	14	2
2552	13\n+3	268	16	3
2553	14\n+4	268	18	4
2554	15\n+5	268	20	5
2486	48\n/3	261	16	7
2487	51\n/3	261	17	8
2488	54\n/3	261	18	9
2489	57\n/3	261	19	10
2490	33\n/3	262	11	1
2491	36\n/3	262	12	2
2555	16\n+6	268	22	6
2556	17\n+7	268	24	7
2557	18\n+8	268	26	8
2558	19\n+9	268	28	9
1587	34\n/2	171	17	8
2479	54\n/3	260	18	10
2480	30\n/3	261	10	1
2481	33\n/3	261	11	2
2482	36\n/3	261	12	3
2483	39\n/3	261	13	4
2484	42\n/3	261	14	5
2492	39\n/3	262	13	3
2493	42\n/3	262	14	4
2494	45\n/3	262	15	5
2495	48\n/3	262	16	6
2496	51\n/3	262	17	7
2497	54\n/3	262	18	8
2498	57\n/3	262	19	9
2499	60\n/3	262	20	10
2500	6\n+1	263	7	1
2501	7\n+2	263	9	2
2502	8\n+3	263	11	3
2503	9\n+4	263	13	4
2504	10\n+5	263	15	5
2505	11\n+6	263	17	6
2506	12\n+7	263	19	7
2507	13\n+8	263	21	8
2508	14\n+9	263	23	9
2509	15\n+10	263	25	10
2510	7\n+1	264	8	1
2511	8\n+2	264	10	2
2512	9\n+3	264	12	3
2588	22\n+9	271	31	9
2589	23\n+10	271	33	10
2590	15\n+1	272	16	1
2591	16\n+2	272	18	2
2592	17\n+3	272	20	3
2593	18\n+4	272	22	4
2594	19\n+5	272	24	5
2595	20\n+6	272	26	6
2596	21\n+7	272	28	7
2597	22\n+8	272	30	8
2598	23\n+9	272	32	9
2599	24\n+10	272	34	10
2600	6\n+1	273	7	1
2601	7\n+2	273	9	2
2602	8\n+3	273	11	3
2603	9\n+4	273	13	4
2604	10\n+5	273	15	5
2605	11\n+6	273	17	6
2606	12\n+7	273	19	7
2607	13\n+8	273	21	8
2608	14\n+9	273	23	9
2609	15\n+10	273	25	10
2610	7\n+1	274	8	1
2611	8\n+2	274	10	2
2612	9\n+3	274	12	3
2613	10\n+4	274	14	4
2614	11\n+5	274	16	5
2560	12\n+1	269	13	1
2615	12\n+6	274	18	6
2616	13\n+7	274	20	7
2617	14\n+8	274	22	8
2618	15\n+9	274	24	9
2619	16\n+10	274	26	10
2620	8\n+1	275	9	1
2621	9\n+2	275	11	2
2622	10\n+3	275	13	3
2623	11\n+4	275	15	4
2624	12\n+5	275	17	5
2625	13\n+6	275	19	6
2626	14\n+7	275	21	7
2627	15\n+8	275	23	8
2628	16\n+9	275	25	9
2629	17\n+10	275	27	10
2630	9\n+1	276	10	1
2631	10\n+2	276	12	2
2632	11\n+3	276	14	3
2633	12\n+4	276	16	4
2634	13\n+5	276	18	5
2635	14\n+6	276	20	6
2636	15\n+7	276	22	7
2637	16\n+8	276	24	8
2638	17\n+9	276	26	9
2639	18\n+10	276	28	10
1668	32\n/2	179	16	9
2561	13\n+2	269	15	2
2562	14\n+3	269	17	3
2563	15\n+4	269	19	4
2564	16\n+5	269	21	5
2565	17\n+6	269	23	6
2566	18\n+7	269	25	7
2567	19\n+8	269	27	8
2568	20\n+9	269	29	9
2569	21\n+10	269	31	10
2570	13\n+1	270	14	1
2571	14\n+2	270	16	2
2572	15\n+3	270	18	3
2573	16\n+4	270	20	4
2574	17\n+5	270	22	5
2575	18\n+6	270	24	6
2576	19\n+7	270	26	7
2577	20\n+8	270	28	8
2578	21\n+9	270	30	9
2579	22\n+10	270	32	10
2580	14\n+1	271	15	1
2581	15\n+2	271	17	2
2582	16\n+3	271	19	3
2583	17\n+4	271	21	4
2584	18\n+5	271	23	5
2585	19\n+6	271	25	6
2586	20\n+7	271	27	7
2587	21\n+8	271	29	8
2669	21\n+10	279	31	10
2670	13\n+1	280	14	1
2671	14\n+2	280	16	2
2672	15\n+3	280	18	3
2673	16\n+4	280	20	4
2674	17\n+5	280	22	5
2675	18\n+6	280	24	6
2676	19\n+7	280	26	7
2677	20\n+8	280	28	8
2678	21\n+9	280	30	9
2679	22\n+10	280	32	10
2680	14\n+1	281	15	1
2681	15\n+2	281	17	2
2682	16\n+3	281	19	3
2683	17\n+4	281	21	4
2684	18\n+5	281	23	5
2685	19\n+6	281	25	6
2686	20\n+7	281	27	7
2687	21\n+8	281	29	8
2688	22\n+9	281	31	9
2689	23\n+10	281	33	10
2690	15\n+1	282	16	1
2691	16\n+2	282	18	2
2692	17\n+3	282	20	3
2693	18\n+4	282	22	4
2694	19\n+5	282	24	5
1749	18\n+10	187	28	10
2695	20\n+6	282	26	6
2696	21\n+7	282	28	7
2697	22\n+8	282	30	8
2698	23\n+9	282	32	9
2699	24\n+10	282	34	10
2700	6\n+1	283	7	1
2701	7\n+2	283	9	2
2702	8\n+3	283	11	3
2703	9\n+4	283	13	4
2704	10\n+5	283	15	5
2705	11\n+6	283	17	6
2706	12\n+7	283	19	7
2707	13\n+8	283	21	8
2708	14\n+9	283	23	9
2709	15\n+10	283	25	10
2710	7\n+1	284	8	1
2711	8\n+2	284	10	2
2712	9\n+3	284	12	3
2713	10\n+4	284	14	4
2714	11\n+5	284	16	5
2715	12\n+6	284	18	6
2716	13\n+7	284	20	7
2717	14\n+8	284	22	8
2718	15\n+9	284	24	9
2719	16\n+10	284	26	10
2720	8\n+1	285	9	1
2641	11\n+2	277	13	2
2642	12\n+3	277	15	3
2643	13\n+4	277	17	4
2644	14\n+5	277	19	5
2645	15\n+6	277	21	6
2646	16\n+7	277	23	7
2647	17\n+8	277	25	8
2648	18\n+9	277	27	9
2649	19\n+10	277	29	10
2650	11\n+1	278	12	1
2651	12\n+2	278	14	2
2652	13\n+3	278	16	3
2653	14\n+4	278	18	4
2654	15\n+5	278	20	5
2655	16\n+6	278	22	6
2656	17\n+7	278	24	7
2657	18\n+8	278	26	8
2658	19\n+9	278	28	9
2659	20\n+10	278	30	10
2660	12\n+1	279	13	1
2661	13\n+2	279	15	2
2662	14\n+3	279	17	3
2663	15\n+4	279	19	4
2664	16\n+5	279	21	5
2665	17\n+6	279	23	6
2666	18\n+7	279	25	7
2667	19\n+8	279	27	8
2668	20\n+9	279	29	9
2752	13\n+3	288	16	3
2753	14\n+4	288	18	4
2754	15\n+5	288	20	5
2755	16\n+6	288	22	6
2756	17\n+7	288	24	7
2757	18\n+8	288	26	8
2758	19\n+9	288	28	9
2759	20\n+10	288	30	10
2760	12\n+1	289	13	1
2761	13\n+2	289	15	2
2762	14\n+3	289	17	3
2763	15\n+4	289	19	4
2764	16\n+5	289	21	5
2765	17\n+6	289	23	6
2766	18\n+7	289	25	7
2767	19\n+8	289	27	8
2768	20\n+9	289	29	9
2769	21\n+10	289	31	10
2770	13\n+1	290	14	1
2771	14\n+2	290	16	2
2772	15\n+3	290	18	3
2773	16\n+4	290	20	4
2774	17\n+5	290	22	5
2775	18\n+6	290	24	6
1830	8\n+1	196	9	1
2776	19\n+7	290	26	7
2777	20\n+8	290	28	8
2778	21\n+9	290	30	9
2779	22\n+10	290	32	10
2780	14\n+1	291	15	1
2781	15\n+2	291	17	2
2782	16\n+3	291	19	3
2783	17\n+4	291	21	4
2784	18\n+5	291	23	5
2785	19\n+6	291	25	6
2786	20\n+7	291	27	7
2787	21\n+8	291	29	8
2788	22\n+9	291	31	9
2789	23\n+10	291	33	10
2790	15\n+1	292	16	1
2791	16\n+2	292	18	2
2792	17\n+3	292	20	3
2793	18\n+4	292	22	4
2794	19\n+5	292	24	5
2795	20\n+6	292	26	6
2796	21\n+7	292	28	7
2797	22\n+8	292	30	8
2798	23\n+9	292	32	9
2799	24\n+10	292	34	10
2722	10\n+3	285	13	3
2723	11\n+4	285	15	4
2724	12\n+5	285	17	5
2725	13\n+6	285	19	6
2726	14\n+7	285	21	7
2727	15\n+8	285	23	8
2728	16\n+9	285	25	9
2729	17\n+10	285	27	10
2730	9\n+1	286	10	1
2731	10\n+2	286	12	2
2732	11\n+3	286	14	3
2733	12\n+4	286	16	4
2734	13\n+5	286	18	5
2735	14\n+6	286	20	6
2736	15\n+7	286	22	7
2737	16\n+8	286	24	8
2738	17\n+9	286	26	9
2739	18\n+10	286	28	10
2740	10\n+1	287	11	1
2741	11\n+2	287	13	2
2742	12\n+3	287	15	3
2743	13\n+4	287	17	4
2744	14\n+5	287	19	5
2745	15\n+6	287	21	6
2746	16\n+7	287	23	7
2747	17\n+8	287	25	8
2748	18\n+9	287	27	9
2749	19\n+10	287	29	10
2750	11\n+1	288	12	1
2800	6\n7\n8	293	21	1
2801	7\n8\n9	293	24	2
2751	12\n+2	288	14	2
2803	9\n10\n11	293	30	4
2804	10\n11\n12	293	33	5
2805	11\n12\n13	293	36	6
2806	12\n13\n14	293	39	7
2807	13\n14\n15	293	42	8
2808	14\n15\n16	293	45	9
2809	15\n16\n17	293	48	10
2810	7\n8\n9	294	24	1
2811	8\n9\n10	294	27	2
2812	9\n10\n11	294	30	3
2813	10\n11\n12	294	33	4
2814	11\n12\n13	294	36	5
2815	12\n13\n14	294	39	6
2816	13\n14\n15	294	42	7
2817	14\n15\n16	294	45	8
2818	15\n16\n17	294	48	9
2819	16\n17\n18	294	51	10
2820	8\n9\n10	295	27	1
2821	9\n10\n11	295	30	2
2822	10\n11\n12	295	33	3
2823	11\n12\n13	295	36	4
2824	12\n13\n14	295	39	5
2825	13\n14\n15	295	42	6
2826	14\n15\n16	295	45	7
2827	15\n16\n17	295	48	8
2828	16\n17\n18	295	51	9
2829	17\n18\n19	295	54	10
2830	9\n10\n11	296	30	1
2831	10\n11\n12	296	33	2
2832	11\n12\n13	296	36	3
2833	12\n13\n14	296	39	4
2834	13\n14\n15	296	42	5
2835	14\n15\n16	296	45	6
2836	15\n16\n17	296	48	7
2837	16\n17\n18	296	51	8
2838	17\n18\n19	296	54	9
2839	18\n19\n20	296	57	10
2840	10\n11\n12	297	33	1
2841	11\n12\n13	297	36	2
2842	12\n13\n14	297	39	3
2843	13\n14\n15	297	42	4
2844	14\n15\n16	297	45	5
2845	15\n16\n17	297	48	6
2846	16\n17\n18	297	51	7
2847	17\n18\n19	297	54	8
2848	18\n19\n20	297	57	9
2849	19\n20\n21	297	60	10
2850	11\n12\n13	298	36	1
2851	12\n13\n14	298	39	2
2852	13\n14\n15	298	42	3
2853	14\n15\n16	298	45	4
2854	15\n16\n17	298	48	5
2855	16\n17\n18	298	51	6
2856	17\n18\n19	298	54	7
2857	18\n19\n20	298	57	8
2858	19\n20\n21	298	60	9
2859	20\n21\n22	298	63	10
2860	12\n13\n14	299	39	1
2861	13\n14\n15	299	42	2
2862	14\n15\n16	299	45	3
2863	15\n16\n17	299	48	4
2864	16\n17\n18	299	51	5
2865	17\n18\n19	299	54	6
2866	18\n19\n20	299	57	7
2867	19\n20\n21	299	60	8
2868	20\n21\n22	299	63	9
2869	21\n22\n23	299	66	10
2870	13\n14\n15	300	42	1
2871	14\n15\n16	300	45	2
2872	15\n16\n17	300	48	3
2873	16\n17\n18	300	51	4
2874	17\n18\n19	300	54	5
2875	18\n19\n20	300	57	6
2876	19\n20\n21	300	60	7
2877	20\n21\n22	300	63	8
2878	21\n22\n23	300	66	9
2879	22\n23\n24	300	69	10
2880	14\n15\n16	301	45	1
2881	15\n16\n17	301	48	2
2882	16\n17\n18	301	51	3
2883	17\n18\n19	301	54	4
2884	18\n19\n20	301	57	5
2885	19\n20\n21	301	60	6
2886	20\n21\n22	301	63	7
2887	21\n22\n23	301	66	8
2888	22\n23\n24	301	69	9
2889	23\n24\n25	301	72	10
1911	7\n+2	204	9	2
2931	4\nx6	306	24	2
2891	16\n17\n18	302	51	2
2892	17\n18\n19	302	54	3
2893	18\n19\n20	302	57	4
2894	19\n20\n21	302	60	5
2895	20\n21\n22	302	63	6
2896	21\n22\n23	302	66	7
2897	22\n23\n24	302	69	8
2898	23\n24\n25	302	72	9
2899	24\n25\n26	302	75	10
2932	4\nx7	306	28	3
2933	4\nx8	306	32	4
2934	4\nx9	306	36	5
2935	4\nx10	306	40	6
2936	4\nx11	306	44	7
2954	4\nx11	308	44	5
2955	4\nx12	308	48	6
2906	4\nx8	303	32	7
2937	4\nx12	306	48	8
2938	4\nx13	306	52	9
2939	4\nx14	306	56	10
2940	4\nx6	307	24	1
2941	4\nx7	307	28	2
2942	4\nx8	307	32	3
2943	4\nx9	307	36	4
2944	4\nx10	307	40	5
2945	4\nx11	307	44	6
2946	4\nx12	307	48	7
2947	4\nx13	307	52	8
2948	4\nx14	307	56	9
2949	4\nx15	307	60	10
2950	4\nx7	308	28	1
2951	4\nx8	308	32	2
2952	4\nx9	308	36	3
2953	4\nx10	308	40	4
2907	4\nx9	303	36	8
2908	4\nx10	303	40	9
2909	4\nx11	303	44	10
2910	4\nx3	304	12	1
2911	4\nx4	304	16	2
2956	4\nx13	308	52	7
2957	4\nx14	308	56	8
2958	4\nx15	308	60	9
2959	4\nx16	308	64	10
2960	4\nx8	309	32	1
2961	4\nx9	309	36	2
2962	4\nx10	309	40	3
2963	4\nx11	309	44	4
2964	4\nx12	309	48	5
2965	4\nx13	309	52	6
2966	4\nx14	309	56	7
2900	4\nx2	303	8	1
2901	4\nx3	303	12	2
2902	4\nx4	303	16	3
2903	4\nx5	303	20	4
2904	4\nx6	303	24	5
2905	4\nx7	303	28	6
2912	4\nx5	304	20	3
2913	4\nx6	304	24	4
2914	4\nx7	304	28	5
2915	4\nx8	304	32	6
2916	4\nx9	304	36	7
2917	4\nx10	304	40	8
2918	4\nx11	304	44	9
2919	4\nx12	304	48	10
2920	4\nx4	305	16	1
2921	4\nx5	305	20	2
2922	4\nx6	305	24	3
2923	4\nx7	305	28	4
2924	4\nx8	305	32	5
2925	4\nx9	305	36	6
2926	4\nx10	305	40	7
2927	4\nx11	305	44	8
2928	4\nx12	305	48	9
2929	4\nx13	305	52	10
2930	4\nx5	306	20	1
3042	4\nx8	317	32	3
3043	4\nx9	317	36	4
3044	4\nx10	317	40	5
2968	4\nx16	309	64	9
2969	4\nx17	309	68	10
2970	4\nx9	310	36	1
2971	4\nx10	310	40	2
2972	4\nx11	310	44	3
2973	4\nx12	310	48	4
2974	4\nx13	310	52	5
2975	4\nx14	310	56	6
2976	4\nx15	310	60	7
2977	4\nx16	310	64	8
2978	4\nx17	310	68	9
2979	4\nx18	310	72	10
2980	4\nx10	311	40	1
2981	4\nx11	311	44	2
2982	4\nx12	311	48	3
3013	4\nx6	314	24	4
3014	4\nx7	314	28	5
1992	16\n+3	212	19	3
2983	4\nx13	311	52	4
2984	4\nx14	311	56	5
2985	4\nx15	311	60	6
2986	4\nx16	311	64	7
2987	4\nx17	311	68	8
2988	4\nx18	311	72	9
2989	4\nx19	311	76	10
2990	4\nx11	312	44	1
2991	4\nx12	312	48	2
2992	4\nx13	312	52	3
2993	4\nx14	312	56	4
2994	4\nx15	312	60	5
2995	4\nx16	312	64	6
2996	4\nx17	312	68	7
2997	4\nx18	312	72	8
2998	4\nx19	312	76	9
2999	4\nx20	312	80	10
3000	4\nx2	313	8	1
3001	4\nx3	313	12	2
3002	4\nx4	313	16	3
3003	4\nx5	313	20	4
3004	4\nx6	313	24	5
3005	4\nx7	313	28	6
3006	4\nx8	313	32	7
3007	4\nx9	313	36	8
3008	4\nx10	313	40	9
3009	4\nx11	313	44	10
3010	4\nx3	314	12	1
3011	4\nx4	314	16	2
3012	4\nx5	314	20	3
3015	4\nx8	314	32	6
3016	4\nx9	314	36	7
3017	4\nx10	314	40	8
3018	4\nx11	314	44	9
3019	4\nx12	314	48	10
3020	4\nx4	315	16	1
3021	4\nx5	315	20	2
3022	4\nx6	315	24	3
3023	4\nx7	315	28	4
3024	4\nx8	315	32	5
3025	4\nx9	315	36	6
3026	4\nx10	315	40	7
3027	4\nx11	315	44	8
3028	4\nx12	315	48	9
3029	4\nx13	315	52	10
3030	4\nx5	316	20	1
3031	4\nx6	316	24	2
3032	4\nx7	316	28	3
3033	4\nx8	316	32	4
3034	4\nx9	316	36	5
3035	4\nx10	316	40	6
3036	4\nx11	316	44	7
3037	4\nx12	316	48	8
3038	4\nx13	316	52	9
3039	4\nx14	316	56	10
3040	4\nx6	317	24	1
3041	4\nx7	317	28	2
3117	40\n/4	324	10	8
3118	44\n/4	324	11	9
3119	48\n/4	324	12	10
3120	16\n/4	325	4	1
3121	20\n/4	325	5	2
3122	24\n/4	325	6	3
3123	28\n/4	325	7	4
3124	32\n/4	325	8	5
3056	4\nx13	318	52	7
3057	4\nx14	318	56	8
3058	4\nx15	318	60	9
3059	4\nx16	318	64	10
3060	4\nx8	319	32	1
3061	4\nx9	319	36	2
3062	4\nx10	319	40	3
3063	4\nx11	319	44	4
3064	4\nx12	319	48	5
3065	4\nx13	319	52	6
3066	4\nx14	319	56	7
3067	4\nx15	319	60	8
3068	4\nx16	319	64	9
3069	4\nx17	319	68	10
3051	4\nx8	318	32	2
3070	4\nx9	320	36	1
3071	4\nx10	320	40	2
3072	4\nx11	320	44	3
3073	4\nx12	320	48	4
3074	4\nx13	320	52	5
3075	4\nx14	320	56	6
3076	4\nx15	320	60	7
3077	4\nx16	320	64	8
3078	4\nx17	320	68	9
3079	4\nx18	320	72	10
3080	4\nx10	321	40	1
3046	4\nx12	317	48	7
3047	4\nx13	317	52	8
3048	4\nx14	317	56	9
3049	4\nx15	317	60	10
3050	4\nx7	318	28	1
3081	4\nx11	321	44	2
3082	4\nx12	321	48	3
3083	4\nx13	321	52	4
3084	4\nx14	321	56	5
3085	4\nx15	321	60	6
3086	4\nx16	321	64	7
3087	4\nx17	321	68	8
3088	4\nx18	321	72	9
3089	4\nx19	321	76	10
3090	4\nx11	322	44	1
3091	4\nx12	322	48	2
3092	4\nx13	322	52	3
3093	4\nx14	322	56	4
3094	4\nx15	322	60	5
3095	4\nx16	322	64	6
3052	4\nx9	318	36	3
3053	4\nx10	318	40	4
3054	4\nx11	318	44	5
3055	4\nx12	318	48	6
3096	4\nx17	322	68	7
3097	4\nx18	322	72	8
3098	4\nx19	322	76	9
3099	4\nx20	322	80	10
3100	8\n/4	323	2	1
3101	12\n/4	323	3	2
3102	16\n/4	323	4	3
3103	20\n/4	323	5	4
3104	24\n/4	323	6	5
3105	28\n/4	323	7	6
3106	32\n/4	323	8	7
3107	36\n/4	323	9	8
3108	40\n/4	323	10	9
3109	44\n/4	323	11	10
3110	12\n/4	324	3	1
3111	16\n/4	324	4	2
3112	20\n/4	324	5	3
3113	24\n/4	324	6	4
3114	28\n/4	324	7	5
3115	32\n/4	324	8	6
3116	36\n/4	324	9	7
3150	28\n/4	328	7	1
2080	13\n14\n15	221	42	1
3151	32\n/4	328	8	2
3152	36\n/4	328	9	3
3153	40\n/4	328	10	4
3182	48\n/4	331	12	3
3154	44\n/4	328	11	5
3155	48\n/4	328	12	6
3156	52\n/4	328	13	7
3157	56\n/4	328	14	8
3158	60\n/4	328	15	9
3159	64\n/4	328	16	10
3160	32\n/4	329	8	1
3161	36\n/4	329	9	2
3162	40\n/4	329	10	3
3163	44\n/4	329	11	4
3164	48\n/4	329	12	5
3165	52\n/4	329	13	6
3166	56\n/4	329	14	7
3167	60\n/4	329	15	8
3168	64\n/4	329	16	9
3169	68\n/4	329	17	10
3170	36\n/4	330	9	1
3171	40\n/4	330	10	2
3172	44\n/4	330	11	3
3173	48\n/4	330	12	4
3174	52\n/4	330	13	5
3202	16\n/4	333	4	3
3175	56\n/4	330	14	6
3176	60\n/4	330	15	7
3177	64\n/4	330	16	8
3178	68\n/4	330	17	9
3179	72\n/4	330	18	10
3180	40\n/4	331	10	1
3181	44\n/4	331	11	2
3197	72\n/4	332	18	8
3198	76\n/4	332	19	9
3199	80\n/4	332	20	10
3200	8\n/4	333	2	1
3201	12\n/4	333	3	2
3183	52\n/4	331	13	4
3184	56\n/4	331	14	5
3185	60\n/4	331	15	6
3186	64\n/4	331	16	7
3187	68\n/4	331	17	8
3188	72\n/4	331	18	9
3189	76\n/4	331	19	10
3190	44\n/4	332	11	1
3191	48\n/4	332	12	2
3192	52\n/4	332	13	3
3193	56\n/4	332	14	4
3194	60\n/4	332	15	5
3195	64\n/4	332	16	6
3196	68\n/4	332	17	7
3203	20\n/4	333	5	4
3204	24\n/4	333	6	5
3205	28\n/4	333	7	6
3126	40\n/4	325	10	7
3127	44\n/4	325	11	8
3128	48\n/4	325	12	9
3129	52\n/4	325	13	10
3130	20\n/4	326	5	1
3131	24\n/4	326	6	2
3132	28\n/4	326	7	3
3133	32\n/4	326	8	4
3134	36\n/4	326	9	5
3135	40\n/4	326	10	6
3136	44\n/4	326	11	7
3137	48\n/4	326	12	8
3138	52\n/4	326	13	9
3139	56\n/4	326	14	10
3140	24\n/4	327	6	1
3141	28\n/4	327	7	2
3142	32\n/4	327	8	3
3143	36\n/4	327	9	4
3144	40\n/4	327	10	5
3145	44\n/4	327	11	6
3146	48\n/4	327	12	7
3147	52\n/4	327	13	8
3148	56\n/4	327	14	9
3149	60\n/4	327	15	10
3232	28\n/4	336	7	3
3233	32\n/4	336	8	4
3234	36\n/4	336	9	5
3263	44\n/4	339	11	4
3264	48\n/4	339	12	5
2158	3\nx15	228	45	9
3235	40\n/4	336	10	6
3236	44\n/4	336	11	7
3237	48\n/4	336	12	8
3238	52\n/4	336	13	9
3239	56\n/4	336	14	10
3240	24\n/4	337	6	1
3241	28\n/4	337	7	2
3242	32\n/4	337	8	3
3243	36\n/4	337	9	4
3244	40\n/4	337	10	5
3245	44\n/4	337	11	6
3246	48\n/4	337	12	7
3247	52\n/4	337	13	8
3248	56\n/4	337	14	9
3249	60\n/4	337	15	10
3250	28\n/4	338	7	1
3251	32\n/4	338	8	2
3252	36\n/4	338	9	3
3253	40\n/4	338	10	4
3254	44\n/4	338	11	5
3284	56\n/4	341	14	5
3255	48\n/4	338	12	6
3256	52\n/4	338	13	7
3257	56\n/4	338	14	8
3258	60\n/4	338	15	9
3259	64\n/4	338	16	10
3260	32\n/4	339	8	1
3261	36\n/4	339	9	2
3262	40\n/4	339	10	3
3279	72\n/4	340	18	10
3280	40\n/4	341	10	1
3281	44\n/4	341	11	2
3282	48\n/4	341	12	3
3283	52\n/4	341	13	4
3265	52\n/4	339	13	6
3266	56\n/4	339	14	7
3267	60\n/4	339	15	8
3268	64\n/4	339	16	9
3269	68\n/4	339	17	10
3270	36\n/4	340	9	1
3271	40\n/4	340	10	2
3272	44\n/4	340	11	3
3273	48\n/4	340	12	4
3274	52\n/4	340	13	5
3275	56\n/4	340	14	6
3276	60\n/4	340	15	7
3277	64\n/4	340	16	8
3278	68\n/4	340	17	9
3285	60\n/4	341	15	6
3286	64\n/4	341	16	7
3207	36\n/4	333	9	8
3208	40\n/4	333	10	9
3209	44\n/4	333	11	10
3210	12\n/4	334	3	1
3211	16\n/4	334	4	2
3212	20\n/4	334	5	3
3213	24\n/4	334	6	4
3214	28\n/4	334	7	5
3215	32\n/4	334	8	6
3216	36\n/4	334	9	7
3217	40\n/4	334	10	8
3218	44\n/4	334	11	9
3219	48\n/4	334	12	10
3220	16\n/4	335	4	1
3221	20\n/4	335	5	2
3222	24\n/4	335	6	3
3223	28\n/4	335	7	4
3224	32\n/4	335	8	5
3225	36\n/4	335	9	6
3226	40\n/4	335	10	7
3227	44\n/4	335	11	8
3228	48\n/4	335	12	9
3229	52\n/4	335	13	10
3230	20\n/4	336	5	1
3231	24\n/4	336	6	2
3328	17\n+9	345	26	9
3329	18\n+10	345	28	10
3330	10\n+1	346	11	1
3331	11\n+2	346	13	2
3332	12\n+3	346	15	3
3333	13\n+4	346	17	4
3334	14\n+5	346	19	5
3335	15\n+6	346	21	6
3336	16\n+7	346	23	7
3337	17\n+8	346	25	8
3338	18\n+9	346	27	9
3339	19\n+10	346	29	10
3340	11\n+1	347	12	1
3341	12\n+2	347	14	2
3342	13\n+3	347	16	3
3343	14\n+4	347	18	4
3344	15\n+5	347	20	5
3345	16\n+6	347	22	6
3346	17\n+7	347	24	7
3347	18\n+8	347	26	8
3348	19\n+9	347	28	9
3349	20\n+10	347	30	10
3350	12\n+1	348	13	1
3351	13\n+2	348	15	2
3352	14\n+3	348	17	3
3353	15\n+4	348	19	4
3300	7\n+1	343	8	1
3301	8\n+2	343	10	2
3302	9\n+3	343	12	3
3303	10\n+4	343	14	4
3304	11\n+5	343	16	5
3305	12\n+6	343	18	6
3306	13\n+7	343	20	7
3307	14\n+8	343	22	8
3308	15\n+9	343	24	9
3309	16\n+10	343	26	10
3310	8\n+1	344	9	1
3311	9\n+2	344	11	2
3312	10\n+3	344	13	3
3354	16\n+5	348	21	5
3355	17\n+6	348	23	6
3356	18\n+7	348	25	7
3357	19\n+8	348	27	8
3358	20\n+9	348	29	9
3359	21\n+10	348	31	10
3360	13\n+1	349	14	1
3361	14\n+2	349	16	2
3362	15\n+3	349	18	3
3363	16\n+4	349	20	4
3364	17\n+5	349	22	5
3365	18\n+6	349	24	6
3366	19\n+7	349	26	7
3367	20\n+8	349	28	8
2236	3\nx11	236	33	7
3288	72\n/4	341	18	9
3289	76\n/4	341	19	10
3290	44\n/4	342	11	1
3291	48\n/4	342	12	2
3292	52\n/4	342	13	3
3293	56\n/4	342	14	4
3294	60\n/4	342	15	5
3295	64\n/4	342	16	6
3296	68\n/4	342	17	7
3297	72\n/4	342	18	8
3298	76\n/4	342	19	9
3299	80\n/4	342	20	10
3313	11\n+4	344	15	4
3314	12\n+5	344	17	5
3315	13\n+6	344	19	6
3316	14\n+7	344	21	7
3317	15\n+8	344	23	8
3318	16\n+9	344	25	9
3319	17\n+10	344	27	10
3320	9\n+1	345	10	1
3321	10\n+2	345	12	2
3322	11\n+3	345	14	3
3323	12\n+4	345	16	4
3324	13\n+5	345	18	5
3325	14\n+6	345	20	6
3326	15\n+7	345	22	7
3327	16\n+8	345	24	8
3397	23\n+8	352	31	8
3398	24\n+9	352	33	9
3399	25\n+10	352	35	10
3400	7\n+1	353	8	1
3401	8\n+2	353	10	2
3402	9\n+3	353	12	3
3403	10\n+4	353	14	4
3404	11\n+5	353	16	5
3405	12\n+6	353	18	6
3406	13\n+7	353	20	7
3407	14\n+8	353	22	8
3408	15\n+9	353	24	9
3409	16\n+10	353	26	10
3410	8\n+1	354	9	1
3411	9\n+2	354	11	2
3412	10\n+3	354	13	3
3413	11\n+4	354	15	4
3414	12\n+5	354	17	5
3415	13\n+6	354	19	6
3416	14\n+7	354	21	7
3417	15\n+8	354	23	8
3418	16\n+9	354	25	9
3419	17\n+10	354	27	10
3420	9\n+1	355	10	1
3421	10\n+2	355	12	2
3422	11\n+3	355	14	3
3423	12\n+4	355	16	4
3369	22\n+10	349	32	10
3424	13\n+5	355	18	5
3425	14\n+6	355	20	6
3426	15\n+7	355	22	7
3427	16\n+8	355	24	8
3428	17\n+9	355	26	9
3429	18\n+10	355	28	10
3430	10\n+1	356	11	1
3431	11\n+2	356	13	2
3432	12\n+3	356	15	3
3433	13\n+4	356	17	4
3434	14\n+5	356	19	5
3435	15\n+6	356	21	6
3436	16\n+7	356	23	7
3437	17\n+8	356	25	8
3438	18\n+9	356	27	9
3439	19\n+10	356	29	10
3440	11\n+1	357	12	1
3441	12\n+2	357	14	2
3442	13\n+3	357	16	3
3443	14\n+4	357	18	4
3444	15\n+5	357	20	5
3445	16\n+6	357	22	6
3446	17\n+7	357	24	7
3447	18\n+8	357	26	8
3448	19\n+9	357	28	9
2316	27\n/3	244	9	7
3370	14\n+1	350	15	1
3371	15\n+2	350	17	2
3372	16\n+3	350	19	3
3373	17\n+4	350	21	4
3374	18\n+5	350	23	5
3375	19\n+6	350	25	6
3376	20\n+7	350	27	7
3377	21\n+8	350	29	8
3378	22\n+9	350	31	9
3379	23\n+10	350	33	10
3380	15\n+1	351	16	1
3381	16\n+2	351	18	2
3382	17\n+3	351	20	3
3383	18\n+4	351	22	4
3384	19\n+5	351	24	5
3385	20\n+6	351	26	6
3386	21\n+7	351	28	7
3387	22\n+8	351	30	8
3388	23\n+9	351	32	9
3389	24\n+10	351	34	10
3390	16\n+1	352	17	1
3391	17\n+2	352	19	2
3392	18\n+3	352	21	3
3393	19\n+4	352	23	4
3394	20\n+5	352	25	5
3395	21\n+6	352	27	6
3396	22\n+7	352	29	7
3478	22\n+9	360	31	9
3479	23\n+10	360	33	10
3480	15\n+1	361	16	1
3481	16\n+2	361	18	2
3482	17\n+3	361	20	3
3483	18\n+4	361	22	4
3484	19\n+5	361	24	5
3485	20\n+6	361	26	6
3486	21\n+7	361	28	7
3487	22\n+8	361	30	8
3488	23\n+9	361	32	9
3489	24\n+10	361	34	10
3490	16\n+1	362	17	1
3491	17\n+2	362	19	2
3492	18\n+3	362	21	3
3493	19\n+4	362	23	4
3494	20\n+5	362	25	5
3495	21\n+6	362	27	6
3496	22\n+7	362	29	7
3497	23\n+8	362	31	8
3498	24\n+9	362	33	9
3499	25\n+10	362	35	10
3500	7\n+1	363	8	1
3501	8\n+2	363	10	2
3502	9\n+3	363	12	3
3503	10\n+4	363	14	4
3504	11\n+5	363	16	5
3450	12\n+1	358	13	1
3505	12\n+6	363	18	6
3506	13\n+7	363	20	7
3507	14\n+8	363	22	8
3508	15\n+9	363	24	9
3509	16\n+10	363	26	10
3510	8\n+1	364	9	1
3511	9\n+2	364	11	2
3512	10\n+3	364	13	3
3513	11\n+4	364	15	4
3514	12\n+5	364	17	5
3515	13\n+6	364	19	6
3516	14\n+7	364	21	7
3517	15\n+8	364	23	8
3518	16\n+9	364	25	9
3519	17\n+10	364	27	10
3520	9\n+1	365	10	1
3521	10\n+2	365	12	2
3522	11\n+3	365	14	3
3523	12\n+4	365	16	4
3524	13\n+5	365	18	5
3525	14\n+6	365	20	6
3526	15\n+7	365	22	7
3527	16\n+8	365	24	8
3528	17\n+9	365	26	9
3529	18\n+10	365	28	10
2397	54\n/3	252	18	8
3451	13\n+2	358	15	2
3452	14\n+3	358	17	3
3453	15\n+4	358	19	4
3454	16\n+5	358	21	5
3455	17\n+6	358	23	6
3456	18\n+7	358	25	7
3457	19\n+8	358	27	8
3458	20\n+9	358	29	9
3459	21\n+10	358	31	10
3460	13\n+1	359	14	1
3461	14\n+2	359	16	2
3462	15\n+3	359	18	3
3463	16\n+4	359	20	4
3464	17\n+5	359	22	5
3465	18\n+6	359	24	6
3466	19\n+7	359	26	7
3467	20\n+8	359	28	8
3468	21\n+9	359	30	9
3469	22\n+10	359	32	10
3470	14\n+1	360	15	1
3471	15\n+2	360	17	2
3472	16\n+3	360	19	3
3473	17\n+4	360	21	4
3474	18\n+5	360	23	5
3475	19\n+6	360	25	6
3476	20\n+7	360	27	7
3477	21\n+8	360	29	8
3564	17\n+5	369	22	5
3565	18\n+6	369	24	6
3566	19\n+7	369	26	7
3567	20\n+8	369	28	8
3568	21\n+9	369	30	9
3569	22\n+10	369	32	10
3570	14\n+1	370	15	1
3571	15\n+2	370	17	2
3572	16\n+3	370	19	3
3573	17\n+4	370	21	4
3574	18\n+5	370	23	5
3575	19\n+6	370	25	6
3576	20\n+7	370	27	7
3577	21\n+8	370	29	8
3578	22\n+9	370	31	9
3579	23\n+10	370	33	10
3580	15\n+1	371	16	1
3581	16\n+2	371	18	2
3582	17\n+3	371	20	3
3583	18\n+4	371	22	4
3584	19\n+5	371	24	5
3585	20\n+6	371	26	6
3586	21\n+7	371	28	7
3587	22\n+8	371	30	8
3588	23\n+9	371	32	9
3589	24\n+10	371	34	10
3590	16\n+1	372	17	1
3591	17\n+2	372	19	2
3592	18\n+3	372	21	3
3593	19\n+4	372	23	4
3594	20\n+5	372	25	5
3595	21\n+6	372	27	6
3596	22\n+7	372	29	7
3597	23\n+8	372	31	8
3598	24\n+9	372	33	9
3599	25\n+10	372	35	10
3530	10\n+1	366	11	1
3531	11\n+2	366	13	2
3532	12\n+3	366	15	3
3533	13\n+4	366	17	4
3534	14\n+5	366	19	5
3535	15\n+6	366	21	6
3536	16\n+7	366	23	7
3537	17\n+8	366	25	8
3538	18\n+9	366	27	9
3539	19\n+10	366	29	10
3540	11\n+1	367	12	1
3541	12\n+2	367	14	2
3542	13\n+3	367	16	3
3543	14\n+4	367	18	4
3544	15\n+5	367	20	5
3545	16\n+6	367	22	6
3546	17\n+7	367	24	7
3547	18\n+8	367	26	8
3548	19\n+9	367	28	9
3549	20\n+10	367	30	10
3550	12\n+1	368	13	1
3551	13\n+2	368	15	2
3552	14\n+3	368	17	3
3553	15\n+4	368	19	4
3554	16\n+5	368	21	5
3555	17\n+6	368	23	6
3556	18\n+7	368	25	7
3557	19\n+8	368	27	8
3558	20\n+9	368	29	9
3559	21\n+10	368	31	10
3560	13\n+1	369	14	1
3561	14\n+2	369	16	2
3562	15\n+3	369	18	3
3563	16\n+4	369	20	4
3600	7\n8\n9	373	24	1
3601	8\n9\n10	373	27	2
3602	9\n10\n11	373	30	3
3603	10\n11\n12	373	33	4
3604	11\n12\n13	373	36	5
3605	12\n13\n14	373	39	6
3606	13\n14\n15	373	42	7
3607	14\n15\n16	373	45	8
3608	15\n16\n17	373	48	9
3609	16\n17\n18	373	51	10
3610	8\n9\n10	374	27	1
3611	9\n10\n11	374	30	2
3612	10\n11\n12	374	33	3
3613	11\n12\n13	374	36	4
3614	12\n13\n14	374	39	5
3615	13\n14\n15	374	42	6
3616	14\n15\n16	374	45	7
3617	15\n16\n17	374	48	8
3618	16\n17\n18	374	51	9
3619	17\n18\n19	374	54	10
3620	9\n10\n11	375	30	1
3621	10\n11\n12	375	33	2
3622	11\n12\n13	375	36	3
3623	12\n13\n14	375	39	4
3624	13\n14\n15	375	42	5
3625	14\n15\n16	375	45	6
3626	15\n16\n17	375	48	7
3627	16\n17\n18	375	51	8
3628	17\n18\n19	375	54	9
3629	18\n19\n20	375	57	10
3630	10\n11\n12	376	33	1
3631	11\n12\n13	376	36	2
3632	12\n13\n14	376	39	3
3633	13\n14\n15	376	42	4
3634	14\n15\n16	376	45	5
3635	15\n16\n17	376	48	6
3636	16\n17\n18	376	51	7
3637	17\n18\n19	376	54	8
3638	18\n19\n20	376	57	9
3639	19\n20\n21	376	60	10
3640	11\n12\n13	377	36	1
3641	12\n13\n14	377	39	2
3642	13\n14\n15	377	42	3
3643	14\n15\n16	377	45	4
3644	15\n16\n17	377	48	5
3645	16\n17\n18	377	51	6
3646	17\n18\n19	377	54	7
3647	18\n19\n20	377	57	8
3648	19\n20\n21	377	60	9
3649	20\n21\n22	377	63	10
3650	12\n13\n14	378	39	1
3651	13\n14\n15	378	42	2
3652	14\n15\n16	378	45	3
3653	15\n16\n17	378	48	4
3654	16\n17\n18	378	51	5
3655	17\n18\n19	378	54	6
3656	18\n19\n20	378	57	7
3657	19\n20\n21	378	60	8
3658	20\n21\n22	378	63	9
3659	21\n22\n23	378	66	10
3660	13\n14\n15	379	42	1
3661	14\n15\n16	379	45	2
3662	15\n16\n17	379	48	3
3663	16\n17\n18	379	51	4
3664	17\n18\n19	379	54	5
3665	18\n19\n20	379	57	6
3666	19\n20\n21	379	60	7
3667	20\n21\n22	379	63	8
3668	21\n22\n23	379	66	9
3669	22\n23\n24	379	69	10
3670	14\n15\n16	380	45	1
3671	15\n16\n17	380	48	2
3672	16\n17\n18	380	51	3
3673	17\n18\n19	380	54	4
3674	18\n19\n20	380	57	5
3675	19\n20\n21	380	60	6
3676	20\n21\n22	380	63	7
3677	21\n22\n23	380	66	8
3678	22\n23\n24	380	69	9
3679	23\n24\n25	380	72	10
3680	15\n16\n17	381	48	1
3681	16\n17\n18	381	51	2
3682	17\n18\n19	381	54	3
3683	18\n19\n20	381	57	4
3684	19\n20\n21	381	60	5
3685	20\n21\n22	381	63	6
3686	21\n22\n23	381	66	7
3687	22\n23\n24	381	69	8
3688	23\n24\n25	381	72	9
3689	24\n25\n26	381	75	10
3690	16\n17\n18	382	51	1
3691	17\n18\n19	382	54	2
3692	18\n19\n20	382	57	3
3693	19\n20\n21	382	60	4
3694	20\n21\n22	382	63	5
3695	21\n22\n23	382	66	6
3696	22\n23\n24	382	69	7
3697	23\n24\n25	382	72	8
3698	24\n25\n26	382	75	9
3699	25\n26\n27	382	78	10
3718	5\nx11	384	55	9
3719	5\nx12	384	60	10
3720	5\nx4	385	20	1
3721	5\nx5	385	25	2
3722	5\nx6	385	30	3
3723	5\nx7	385	35	4
3724	5\nx8	385	40	5
3725	5\nx9	385	45	6
3726	5\nx10	385	50	7
3727	5\nx11	385	55	8
3728	5\nx12	385	60	9
3752	5\nx9	388	45	3
3753	5\nx10	388	50	4
3754	5\nx11	388	55	5
3703	5\nx5	383	25	4
3729	5\nx13	385	65	10
3730	5\nx5	386	25	1
3731	5\nx6	386	30	2
3732	5\nx7	386	35	3
3733	5\nx8	386	40	4
3734	5\nx9	386	45	5
3735	5\nx10	386	50	6
3736	5\nx11	386	55	7
3737	5\nx12	386	60	8
3738	5\nx13	386	65	9
3739	5\nx14	386	70	10
3740	5\nx6	387	30	1
3741	5\nx7	387	35	2
3742	5\nx8	387	40	3
3743	5\nx9	387	45	4
3744	5\nx10	387	50	5
3745	5\nx11	387	55	6
3746	5\nx12	387	60	7
3747	5\nx13	387	65	8
3748	5\nx14	387	70	9
3749	5\nx15	387	75	10
3750	5\nx7	388	35	1
3751	5\nx8	388	40	2
3704	5\nx6	383	30	5
3755	5\nx12	388	60	6
3756	5\nx13	388	65	7
3757	5\nx14	388	70	8
3758	5\nx15	388	75	9
3759	5\nx16	388	80	10
3760	5\nx8	389	40	1
3761	5\nx9	389	45	2
3762	5\nx10	389	50	3
3763	5\nx11	389	55	4
3764	5\nx12	389	60	5
3765	5\nx13	389	65	6
3766	5\nx14	389	70	7
3767	5\nx15	389	75	8
3768	5\nx16	389	80	9
3769	5\nx17	389	85	10
3770	5\nx9	390	45	1
3771	5\nx10	390	50	2
3772	5\nx11	390	55	3
3773	5\nx12	390	60	4
3774	5\nx13	390	65	5
2478	51\n/3	260	17	9
3701	5\nx3	383	15	2
3702	5\nx4	383	20	3
3705	5\nx7	383	35	6
3706	5\nx8	383	40	7
3707	5\nx9	383	45	8
3708	5\nx10	383	50	9
3709	5\nx11	383	55	10
3710	5\nx3	384	15	1
3711	5\nx4	384	20	2
3712	5\nx5	384	25	3
3713	5\nx6	384	30	4
3714	5\nx7	384	35	5
3715	5\nx8	384	40	6
3716	5\nx9	384	45	7
3717	5\nx10	384	50	8
3842	5\nx8	397	40	3
3843	5\nx9	397	45	4
3844	5\nx10	397	50	5
3845	5\nx11	397	55	6
3846	5\nx12	397	60	7
3847	5\nx13	397	65	8
3848	5\nx14	397	70	9
3849	5\nx15	397	75	10
3850	5\nx7	398	35	1
3851	5\nx8	398	40	2
3852	5\nx9	398	45	3
3853	5\nx10	398	50	4
3776	5\nx15	390	75	7
3777	5\nx16	390	80	8
3778	5\nx17	390	85	9
3779	5\nx18	390	90	10
3780	5\nx10	391	50	1
3781	5\nx11	391	55	2
3782	5\nx12	391	60	3
3783	5\nx13	391	65	4
3816	5\nx9	394	45	7
3784	5\nx14	391	70	5
3785	5\nx15	391	75	6
3786	5\nx16	391	80	7
3787	5\nx17	391	85	8
3788	5\nx18	391	90	9
3789	5\nx19	391	95	10
3790	5\nx11	392	55	1
3791	5\nx12	392	60	2
3792	5\nx13	392	65	3
3793	5\nx14	392	70	4
3794	5\nx15	392	75	5
3795	5\nx16	392	80	6
3796	5\nx17	392	85	7
3797	5\nx18	392	90	8
3798	5\nx19	392	95	9
3799	5\nx20	392	100	10
3800	5\nx2	393	10	1
3801	5\nx3	393	15	2
3802	5\nx4	393	20	3
3803	5\nx5	393	25	4
3804	5\nx6	393	30	5
3805	5\nx7	393	35	6
3806	5\nx8	393	40	7
3807	5\nx9	393	45	8
3808	5\nx10	393	50	9
3809	5\nx11	393	55	10
3810	5\nx3	394	15	1
3811	5\nx4	394	20	2
3812	5\nx5	394	25	3
3813	5\nx6	394	30	4
3814	5\nx7	394	35	5
3815	5\nx8	394	40	6
3817	5\nx10	394	50	8
3818	5\nx11	394	55	9
3819	5\nx12	394	60	10
3820	5\nx4	395	20	1
3821	5\nx5	395	25	2
3822	5\nx6	395	30	3
3823	5\nx7	395	35	4
3824	5\nx8	395	40	5
3825	5\nx9	395	45	6
3826	5\nx10	395	50	7
3827	5\nx11	395	55	8
3828	5\nx12	395	60	9
3829	5\nx13	395	65	10
3830	5\nx5	396	25	1
3831	5\nx6	396	30	2
3832	5\nx7	396	35	3
3833	5\nx8	396	40	4
3834	5\nx9	396	45	5
3835	5\nx10	396	50	6
3836	5\nx11	396	55	7
3837	5\nx12	396	60	8
3838	5\nx13	396	65	9
3839	5\nx14	396	70	10
3840	5\nx6	397	30	1
3841	5\nx7	397	35	2
3923	35\n/5	405	7	4
3924	40\n/5	405	8	5
3925	45\n/5	405	9	6
3926	50\n/5	405	10	7
3927	55\n/5	405	11	8
3928	60\n/5	405	12	9
3929	65\n/5	405	13	10
3930	25\n/5	406	5	1
3931	30\n/5	406	6	2
3932	35\n/5	406	7	3
3933	40\n/5	406	8	4
3854	5\nx11	398	55	5
3855	5\nx12	398	60	6
3856	5\nx13	398	65	7
3857	5\nx14	398	70	8
3858	5\nx15	398	75	9
3859	5\nx16	398	80	10
3860	5\nx8	399	40	1
3861	5\nx9	399	45	2
3862	5\nx10	399	50	3
3863	5\nx11	399	55	4
3864	5\nx12	399	60	5
3865	5\nx13	399	65	6
3866	5\nx14	399	70	7
3867	5\nx15	399	75	8
3868	5\nx16	399	80	9
3869	5\nx17	399	85	10
3870	5\nx9	400	45	1
3871	5\nx10	400	50	2
3872	5\nx11	400	55	3
3873	5\nx12	400	60	4
3874	5\nx13	400	65	5
3875	5\nx14	400	70	6
3876	5\nx15	400	75	7
3877	5\nx16	400	80	8
3878	5\nx17	400	85	9
3879	5\nx18	400	90	10
3880	5\nx10	401	50	1
3881	5\nx11	401	55	2
3882	5\nx12	401	60	3
3883	5\nx13	401	65	4
3884	5\nx14	401	70	5
3885	5\nx15	401	75	6
3886	5\nx16	401	80	7
3887	5\nx17	401	85	8
3888	5\nx18	401	90	9
3889	5\nx19	401	95	10
3890	5\nx11	402	55	1
3891	5\nx12	402	60	2
3892	5\nx13	402	65	3
3893	5\nx14	402	70	4
3894	5\nx15	402	75	5
3895	5\nx16	402	80	6
3896	5\nx17	402	85	7
3897	5\nx18	402	90	8
3898	5\nx19	402	95	9
3899	5\nx20	402	100	10
3900	10\n/5	403	2	1
3901	15\n/5	403	3	2
3902	20\n/5	403	4	3
3903	25\n/5	403	5	4
3904	30\n/5	403	6	5
3905	35\n/5	403	7	6
3906	40\n/5	403	8	7
3907	45\n/5	403	9	8
3908	50\n/5	403	10	9
3909	55\n/5	403	11	10
3910	15\n/5	404	3	1
3911	20\n/5	404	4	2
3912	25\n/5	404	5	3
3913	30\n/5	404	6	4
3914	35\n/5	404	7	5
3915	40\n/5	404	8	6
3916	45\n/5	404	9	7
3917	50\n/5	404	10	8
3918	55\n/5	404	11	9
3919	60\n/5	404	12	10
3920	20\n/5	405	4	1
3921	25\n/5	405	5	2
3922	30\n/5	405	6	3
3959	80\n/5	408	16	10
3960	40\n/5	409	8	1
3961	45\n/5	409	9	2
3962	50\n/5	409	10	3
3991	60\n/5	412	12	2
3963	55\n/5	409	11	4
3964	60\n/5	409	12	5
3965	65\n/5	409	13	6
3966	70\n/5	409	14	7
3967	75\n/5	409	15	8
3968	80\n/5	409	16	9
3969	85\n/5	409	17	10
3970	45\n/5	410	9	1
3971	50\n/5	410	10	2
3972	55\n/5	410	11	3
3973	60\n/5	410	12	4
3974	65\n/5	410	13	5
3975	70\n/5	410	14	6
3976	75\n/5	410	15	7
3977	80\n/5	410	16	8
3978	85\n/5	410	17	9
3979	90\n/5	410	18	10
3980	50\n/5	411	10	1
3981	55\n/5	411	11	2
3982	60\n/5	411	12	3
3983	65\n/5	411	13	4
2559	20\n+10	268	30	10
3984	70\n/5	411	14	5
3985	75\n/5	411	15	6
3986	80\n/5	411	16	7
3987	85\n/5	411	17	8
3988	90\n/5	411	18	9
3989	95\n/5	411	19	10
3990	55\n/5	412	11	1
4006	40\n/5	413	8	7
4007	45\n/5	413	9	8
4008	50\n/5	413	10	9
4009	55\n/5	413	11	10
4010	15\n/5	414	3	1
3992	65\n/5	412	13	3
3993	70\n/5	412	14	4
3994	75\n/5	412	15	5
3995	80\n/5	412	16	6
3996	85\n/5	412	17	7
3997	90\n/5	412	18	8
3998	95\n/5	412	19	9
3999	100\n/5	412	20	10
4000	10\n/5	413	2	1
4001	15\n/5	413	3	2
4002	20\n/5	413	4	3
4003	25\n/5	413	5	4
4004	30\n/5	413	6	5
4005	35\n/5	413	7	6
4011	20\n/5	414	4	2
4012	25\n/5	414	5	3
4013	30\n/5	414	6	4
4014	35\n/5	414	7	5
3935	50\n/5	406	10	6
3936	55\n/5	406	11	7
3937	60\n/5	406	12	8
3938	65\n/5	406	13	9
3939	70\n/5	406	14	10
3940	30\n/5	407	6	1
3941	35\n/5	407	7	2
3942	40\n/5	407	8	3
3943	45\n/5	407	9	4
3944	50\n/5	407	10	5
3945	55\n/5	407	11	6
3946	60\n/5	407	12	7
3947	65\n/5	407	13	8
3948	70\n/5	407	14	9
3949	75\n/5	407	15	10
3950	35\n/5	408	7	1
3951	40\n/5	408	8	2
3952	45\n/5	408	9	3
3953	50\n/5	408	10	4
3954	55\n/5	408	11	5
3955	60\n/5	408	12	6
3956	65\n/5	408	13	7
3957	70\n/5	408	14	8
3958	75\n/5	408	15	9
4042	40\n/5	417	8	3
4043	45\n/5	417	9	4
4072	55\n/5	420	11	3
4073	60\n/5	420	12	4
4074	65\n/5	420	13	5
4075	70\n/5	420	14	6
4044	50\n/5	417	10	5
4045	55\n/5	417	11	6
4046	60\n/5	417	12	7
4047	65\n/5	417	13	8
4048	70\n/5	417	14	9
4049	75\n/5	417	15	10
4050	35\n/5	418	7	1
4051	40\n/5	418	8	2
4052	45\n/5	418	9	3
4053	50\n/5	418	10	4
4054	55\n/5	418	11	5
4055	60\n/5	418	12	6
4056	65\n/5	418	13	7
4057	70\n/5	418	14	8
4058	75\n/5	418	15	9
4059	80\n/5	418	16	10
4060	40\n/5	419	8	1
4061	45\n/5	419	9	2
4062	50\n/5	419	10	3
4063	55\n/5	419	11	4
2640	10\n+1	277	11	1
4064	60\n/5	419	12	5
4065	65\n/5	419	13	6
4066	70\n/5	419	14	7
4067	75\n/5	419	15	8
4068	80\n/5	419	16	9
4069	85\n/5	419	17	10
4070	45\n/5	420	9	1
4071	50\n/5	420	10	2
4088	90\n/5	421	18	9
4089	95\n/5	421	19	10
4090	55\n/5	422	11	1
4091	60\n/5	422	12	2
4092	65\n/5	422	13	3
4093	70\n/5	422	14	4
4076	75\n/5	420	15	7
4077	80\n/5	420	16	8
4078	85\n/5	420	17	9
4079	90\n/5	420	18	10
4080	50\n/5	421	10	1
4081	55\n/5	421	11	2
4082	60\n/5	421	12	3
4083	65\n/5	421	13	4
4084	70\n/5	421	14	5
4085	75\n/5	421	15	6
4086	80\n/5	421	16	7
4087	85\n/5	421	17	8
4094	75\n/5	422	15	5
4095	80\n/5	422	16	6
4016	45\n/5	414	9	7
4017	50\n/5	414	10	8
4018	55\n/5	414	11	9
4019	60\n/5	414	12	10
4020	20\n/5	415	4	1
4021	25\n/5	415	5	2
4022	30\n/5	415	6	3
4023	35\n/5	415	7	4
4024	40\n/5	415	8	5
4025	45\n/5	415	9	6
4026	50\n/5	415	10	7
4027	55\n/5	415	11	8
4028	60\n/5	415	12	9
4029	65\n/5	415	13	10
4030	25\n/5	416	5	1
4031	30\n/5	416	6	2
4032	35\n/5	416	7	3
4033	40\n/5	416	8	4
4034	45\n/5	416	9	5
4035	50\n/5	416	10	6
4036	55\n/5	416	11	7
4037	60\n/5	416	12	8
4038	65\n/5	416	13	9
4039	70\n/5	416	14	10
4040	30\n/5	417	6	1
4041	35\n/5	417	7	2
4128	18\n+9	425	27	9
4129	19\n+10	425	29	10
4130	11\n+1	426	12	1
4131	12\n+2	426	14	2
4132	13\n+3	426	16	3
4133	14\n+4	426	18	4
4134	15\n+5	426	20	5
4135	16\n+6	426	22	6
4136	17\n+7	426	24	7
4137	18\n+8	426	26	8
4138	19\n+9	426	28	9
4139	20\n+10	426	30	10
4140	12\n+1	427	13	1
4141	13\n+2	427	15	2
4142	14\n+3	427	17	3
4143	15\n+4	427	19	4
4144	16\n+5	427	21	5
4145	17\n+6	427	23	6
4146	18\n+7	427	25	7
4147	19\n+8	427	27	8
4148	20\n+9	427	29	9
4149	21\n+10	427	31	10
4150	13\n+1	428	14	1
4151	14\n+2	428	16	2
4152	15\n+3	428	18	3
4153	16\n+4	428	20	4
2721	9\n+2	285	11	2
4100	8\n+1	423	9	1
4101	9\n+2	423	11	2
4102	10\n+3	423	13	3
4154	17\n+5	428	22	5
4155	18\n+6	428	24	6
4156	19\n+7	428	26	7
4157	20\n+8	428	28	8
4158	21\n+9	428	30	9
4159	22\n+10	428	32	10
4160	14\n+1	429	15	1
4161	15\n+2	429	17	2
4162	16\n+3	429	19	3
4163	17\n+4	429	21	4
4164	18\n+5	429	23	5
4165	19\n+6	429	25	6
4166	20\n+7	429	27	7
4167	21\n+8	429	29	8
4168	22\n+9	429	31	9
4169	23\n+10	429	33	10
4170	15\n+1	430	16	1
4171	16\n+2	430	18	2
4172	17\n+3	430	20	3
4173	18\n+4	430	22	4
4174	19\n+5	430	24	5
4175	20\n+6	430	26	6
4176	21\n+7	430	28	7
4097	90\n/5	422	18	8
4098	95\n/5	422	19	9
4099	100\n/5	422	20	10
4103	11\n+4	423	15	4
4104	12\n+5	423	17	5
4105	13\n+6	423	19	6
4106	14\n+7	423	21	7
4107	15\n+8	423	23	8
4108	16\n+9	423	25	9
4109	17\n+10	423	27	10
4110	9\n+1	424	10	1
4111	10\n+2	424	12	2
4112	11\n+3	424	14	3
4113	12\n+4	424	16	4
4114	13\n+5	424	18	5
4115	14\n+6	424	20	6
4116	15\n+7	424	22	7
4117	16\n+8	424	24	8
4118	17\n+9	424	26	9
4119	18\n+10	424	28	10
4120	10\n+1	425	11	1
4121	11\n+2	425	13	2
4122	12\n+3	425	15	3
4123	13\n+4	425	17	4
4124	14\n+5	425	19	5
4125	15\n+6	425	21	6
4126	16\n+7	425	23	7
4127	17\n+8	425	25	8
4208	16\n+9	433	25	9
2802	8\n9\n10	293	27	3
4209	17\n+10	433	27	10
4210	9\n+1	434	10	1
4211	10\n+2	434	12	2
4212	11\n+3	434	14	3
4213	12\n+4	434	16	4
4214	13\n+5	434	18	5
4215	14\n+6	434	20	6
4216	15\n+7	434	22	7
4217	16\n+8	434	24	8
4218	17\n+9	434	26	9
4219	18\n+10	434	28	10
4220	10\n+1	435	11	1
4221	11\n+2	435	13	2
4222	12\n+3	435	15	3
4223	13\n+4	435	17	4
4224	14\n+5	435	19	5
4225	15\n+6	435	21	6
4226	16\n+7	435	23	7
4227	17\n+8	435	25	8
4228	18\n+9	435	27	9
4229	19\n+10	435	29	10
4230	11\n+1	436	12	1
4231	12\n+2	436	14	2
4232	13\n+3	436	16	3
4178	23\n+9	430	32	9
4233	14\n+4	436	18	4
4234	15\n+5	436	20	5
4235	16\n+6	436	22	6
4236	17\n+7	436	24	7
4237	18\n+8	436	26	8
4238	19\n+9	436	28	9
4239	20\n+10	436	30	10
4240	12\n+1	437	13	1
4241	13\n+2	437	15	2
4242	14\n+3	437	17	3
4243	15\n+4	437	19	4
4244	16\n+5	437	21	5
4245	17\n+6	437	23	6
4246	18\n+7	437	25	7
4247	19\n+8	437	27	8
4248	20\n+9	437	29	9
4249	21\n+10	437	31	10
4250	13\n+1	438	14	1
4251	14\n+2	438	16	2
4252	15\n+3	438	18	3
4253	16\n+4	438	20	4
4254	17\n+5	438	22	5
4255	18\n+6	438	24	6
4256	19\n+7	438	26	7
4257	20\n+8	438	28	8
4179	24\n+10	430	34	10
4180	16\n+1	431	17	1
4181	17\n+2	431	19	2
4182	18\n+3	431	21	3
4183	19\n+4	431	23	4
4184	20\n+5	431	25	5
4185	21\n+6	431	27	6
4186	22\n+7	431	29	7
4187	23\n+8	431	31	8
4188	24\n+9	431	33	9
4189	25\n+10	431	35	10
4190	17\n+1	432	18	1
4191	18\n+2	432	20	2
4192	19\n+3	432	22	3
4193	20\n+4	432	24	4
4194	21\n+5	432	26	5
4195	22\n+6	432	28	6
4196	23\n+7	432	30	7
4197	24\n+8	432	32	8
4198	25\n+9	432	34	9
4199	26\n+10	432	36	10
4200	8\n+1	433	9	1
4201	9\n+2	433	11	2
4202	10\n+3	433	13	3
4203	11\n+4	433	15	4
4204	12\n+5	433	17	5
4205	13\n+6	433	19	6
4206	14\n+7	433	21	7
4207	15\n+8	433	23	8
4287	23\n+8	441	31	8
2890	15\n16\n17	302	48	1
4288	24\n+9	441	33	9
4289	25\n+10	441	35	10
4290	17\n+1	442	18	1
4291	18\n+2	442	20	2
4292	19\n+3	442	22	3
4293	20\n+4	442	24	4
4294	21\n+5	442	26	5
4295	22\n+6	442	28	6
4296	23\n+7	442	30	7
4297	24\n+8	442	32	8
4298	25\n+9	442	34	9
4299	26\n+10	442	36	10
4300	8\n+1	443	9	1
4301	9\n+2	443	11	2
4302	10\n+3	443	13	3
4303	11\n+4	443	15	4
4304	12\n+5	443	17	5
4305	13\n+6	443	19	6
4306	14\n+7	443	21	7
4307	15\n+8	443	23	8
4308	16\n+9	443	25	9
4309	17\n+10	443	27	10
4310	9\n+1	444	10	1
4311	10\n+2	444	12	2
4312	11\n+3	444	14	3
4259	22\n+10	438	32	10
4313	12\n+4	444	16	4
4314	13\n+5	444	18	5
4315	14\n+6	444	20	6
4316	15\n+7	444	22	7
4317	16\n+8	444	24	8
4318	17\n+9	444	26	9
4319	18\n+10	444	28	10
4320	10\n+1	445	11	1
4321	11\n+2	445	13	2
4322	12\n+3	445	15	3
4323	13\n+4	445	17	4
4324	14\n+5	445	19	5
4325	15\n+6	445	21	6
4326	16\n+7	445	23	7
4327	17\n+8	445	25	8
4328	18\n+9	445	27	9
4329	19\n+10	445	29	10
4330	11\n+1	446	12	1
4331	12\n+2	446	14	2
4332	13\n+3	446	16	3
4333	14\n+4	446	18	4
4334	15\n+5	446	20	5
4335	16\n+6	446	22	6
4336	17\n+7	446	24	7
4337	18\n+8	446	26	8
4338	19\n+9	446	28	9
4260	14\n+1	439	15	1
4261	15\n+2	439	17	2
4262	16\n+3	439	19	3
4263	17\n+4	439	21	4
4264	18\n+5	439	23	5
4265	19\n+6	439	25	6
4266	20\n+7	439	27	7
4267	21\n+8	439	29	8
4268	22\n+9	439	31	9
4269	23\n+10	439	33	10
4270	15\n+1	440	16	1
4271	16\n+2	440	18	2
4272	17\n+3	440	20	3
4273	18\n+4	440	22	4
4274	19\n+5	440	24	5
4275	20\n+6	440	26	6
4276	21\n+7	440	28	7
4277	22\n+8	440	30	8
4278	23\n+9	440	32	9
4279	24\n+10	440	34	10
4280	16\n+1	441	17	1
4281	17\n+2	441	19	2
4282	18\n+3	441	21	3
4283	19\n+4	441	23	4
4284	20\n+5	441	25	5
4285	21\n+6	441	27	6
4286	22\n+7	441	29	7
4381	17\n+2	451	19	2
4382	18\n+3	451	21	3
4383	19\n+4	451	23	4
4384	20\n+5	451	25	5
4385	21\n+6	451	27	6
4386	22\n+7	451	29	7
4387	23\n+8	451	31	8
4388	24\n+9	451	33	9
4389	25\n+10	451	35	10
4390	17\n+1	452	18	1
4340	12\n+1	447	13	1
4391	18\n+2	452	20	2
4392	19\n+3	452	22	3
4393	20\n+4	452	24	4
4394	21\n+5	452	26	5
4395	22\n+6	452	28	6
4396	23\n+7	452	30	7
4397	24\n+8	452	32	8
4398	25\n+9	452	34	9
4399	26\n+10	452	36	10
4341	13\n+2	447	15	2
4342	14\n+3	447	17	3
4343	15\n+4	447	19	4
4344	16\n+5	447	21	5
4345	17\n+6	447	23	6
4346	18\n+7	447	25	7
4347	19\n+8	447	27	8
4348	20\n+9	447	29	9
4349	21\n+10	447	31	10
4350	13\n+1	448	14	1
4351	14\n+2	448	16	2
4352	15\n+3	448	18	3
4353	16\n+4	448	20	4
4354	17\n+5	448	22	5
4355	18\n+6	448	24	6
4356	19\n+7	448	26	7
4357	20\n+8	448	28	8
4358	21\n+9	448	30	9
4359	22\n+10	448	32	10
4360	14\n+1	449	15	1
4361	15\n+2	449	17	2
4362	16\n+3	449	19	3
4363	17\n+4	449	21	4
4364	18\n+5	449	23	5
4365	19\n+6	449	25	6
4366	20\n+7	449	27	7
4367	21\n+8	449	29	8
4368	22\n+9	449	31	9
4369	23\n+10	449	33	10
4370	15\n+1	450	16	1
4371	16\n+2	450	18	2
4372	17\n+3	450	20	3
4373	18\n+4	450	22	4
4374	19\n+5	450	24	5
4375	20\n+6	450	26	6
4376	21\n+7	450	28	7
4377	22\n+8	450	30	8
4378	23\n+9	450	32	9
4379	24\n+10	450	34	10
4380	16\n+1	451	17	1
4400	8\n9\n10	453	27	1
4401	9\n10\n11	453	30	2
4402	10\n11\n12	453	33	3
4403	11\n12\n13	453	36	4
4404	12\n13\n14	453	39	5
4405	13\n14\n15	453	42	6
4406	14\n15\n16	453	45	7
4407	15\n16\n17	453	48	8
4408	16\n17\n18	453	51	9
4409	17\n18\n19	453	54	10
4410	9\n10\n11	454	30	1
4411	10\n11\n12	454	33	2
4412	11\n12\n13	454	36	3
4413	12\n13\n14	454	39	4
4414	13\n14\n15	454	42	5
4415	14\n15\n16	454	45	6
4416	15\n16\n17	454	48	7
4417	16\n17\n18	454	51	8
4418	17\n18\n19	454	54	9
4419	18\n19\n20	454	57	10
4420	10\n11\n12	455	33	1
4421	11\n12\n13	455	36	2
4423	13\n14\n15	455	42	4
4424	14\n15\n16	455	45	5
4425	15\n16\n17	455	48	6
4426	16\n17\n18	455	51	7
4427	17\n18\n19	455	54	8
4428	18\n19\n20	455	57	9
4429	19\n20\n21	455	60	10
4430	11\n12\n13	456	36	1
4431	12\n13\n14	456	39	2
4432	13\n14\n15	456	42	3
4433	14\n15\n16	456	45	4
4434	15\n16\n17	456	48	5
4435	16\n17\n18	456	51	6
4436	17\n18\n19	456	54	7
4437	18\n19\n20	456	57	8
4438	19\n20\n21	456	60	9
4439	20\n21\n22	456	63	10
4440	12\n13\n14	457	39	1
4441	13\n14\n15	457	42	2
4442	14\n15\n16	457	45	3
4443	15\n16\n17	457	48	4
4444	16\n17\n18	457	51	5
4445	17\n18\n19	457	54	6
4446	18\n19\n20	457	57	7
4447	19\n20\n21	457	60	8
4448	20\n21\n22	457	63	9
4449	21\n22\n23	457	66	10
4450	13\n14\n15	458	42	1
4451	14\n15\n16	458	45	2
4452	15\n16\n17	458	48	3
4453	16\n17\n18	458	51	4
4454	17\n18\n19	458	54	5
4455	18\n19\n20	458	57	6
4456	19\n20\n21	458	60	7
4457	20\n21\n22	458	63	8
4458	21\n22\n23	458	66	9
4459	22\n23\n24	458	69	10
4460	14\n15\n16	459	45	1
4461	15\n16\n17	459	48	2
4462	16\n17\n18	459	51	3
4463	17\n18\n19	459	54	4
4464	18\n19\n20	459	57	5
4465	19\n20\n21	459	60	6
4466	20\n21\n22	459	63	7
4467	21\n22\n23	459	66	8
4468	22\n23\n24	459	69	9
4469	23\n24\n25	459	72	10
4470	15\n16\n17	460	48	1
4471	16\n17\n18	460	51	2
4472	17\n18\n19	460	54	3
4473	18\n19\n20	460	57	4
4474	19\n20\n21	460	60	5
4475	20\n21\n22	460	63	6
4476	21\n22\n23	460	66	7
4477	22\n23\n24	460	69	8
4478	23\n24\n25	460	72	9
4479	24\n25\n26	460	75	10
4480	16\n17\n18	461	51	1
4481	17\n18\n19	461	54	2
4482	18\n19\n20	461	57	3
4483	19\n20\n21	461	60	4
4484	20\n21\n22	461	63	5
4485	21\n22\n23	461	66	6
4486	22\n23\n24	461	69	7
4487	23\n24\n25	461	72	8
4488	24\n25\n26	461	75	9
4489	25\n26\n27	461	78	10
4490	17\n18\n19	462	54	1
4491	18\n19\n20	462	57	2
4492	19\n20\n21	462	60	3
4493	20\n21\n22	462	63	4
4494	21\n22\n23	462	66	5
4495	22\n23\n24	462	69	6
4496	23\n24\n25	462	72	7
4497	24\n25\n26	462	75	8
4498	25\n26\n27	462	78	9
4499	26\n27\n28	462	81	10
4500	6\nx2	463	12	1
4501	6\nx3	463	18	2
4502	6\nx4	463	24	3
4503	6\nx5	463	30	4
4504	6\nx6	463	36	5
4505	6\nx7	463	42	6
4506	6\nx8	463	48	7
4507	6\nx9	463	54	8
4508	6\nx10	463	60	9
4528	6\nx12	465	72	9
4529	6\nx13	465	78	10
4530	6\nx5	466	30	1
4531	6\nx6	466	36	2
4532	6\nx7	466	42	3
4533	6\nx8	466	48	4
4534	6\nx9	466	54	5
4535	6\nx10	466	60	6
4536	6\nx11	466	66	7
4537	6\nx12	466	72	8
4560	6\nx8	469	48	1
4561	6\nx9	469	54	2
4562	6\nx10	469	60	3
4563	6\nx11	469	66	4
4512	6\nx5	464	30	3
4538	6\nx13	466	78	9
4539	6\nx14	466	84	10
4540	6\nx6	467	36	1
4541	6\nx7	467	42	2
4542	6\nx8	467	48	3
4543	6\nx9	467	54	4
4544	6\nx10	467	60	5
4545	6\nx11	467	66	6
4546	6\nx12	467	72	7
4547	6\nx13	467	78	8
4548	6\nx14	467	84	9
4549	6\nx15	467	90	10
4550	6\nx7	468	42	1
4551	6\nx8	468	48	2
4552	6\nx9	468	54	3
4553	6\nx10	468	60	4
4554	6\nx11	468	66	5
4555	6\nx12	468	72	6
4556	6\nx13	468	78	7
4557	6\nx14	468	84	8
4558	6\nx15	468	90	9
4559	6\nx16	468	96	10
4513	6\nx6	464	36	4
4564	6\nx12	469	72	5
4565	6\nx13	469	78	6
4566	6\nx14	469	84	7
4567	6\nx15	469	90	8
4568	6\nx16	469	96	9
4569	6\nx17	469	102	10
4570	6\nx9	470	54	1
4571	6\nx10	470	60	2
4572	6\nx11	470	66	3
4573	6\nx12	470	72	4
4574	6\nx13	470	78	5
4575	6\nx14	470	84	6
4576	6\nx15	470	90	7
4577	6\nx16	470	96	8
4578	6\nx17	470	102	9
4579	6\nx18	470	108	10
4580	6\nx10	471	60	1
4581	6\nx11	471	66	2
4582	6\nx12	471	72	3
4583	6\nx13	471	78	4
2967	4\nx15	309	60	8
4510	6\nx3	464	18	1
4511	6\nx4	464	24	2
4514	6\nx7	464	42	5
4515	6\nx8	464	48	6
4516	6\nx9	464	54	7
4517	6\nx10	464	60	8
4518	6\nx11	464	66	9
4519	6\nx12	464	72	10
4520	6\nx4	465	24	1
4521	6\nx5	465	30	2
4522	6\nx6	465	36	3
4523	6\nx7	465	42	4
4524	6\nx8	465	48	5
4525	6\nx9	465	54	6
4526	6\nx10	465	60	7
4527	6\nx11	465	66	8
4642	6\nx8	477	48	3
4643	6\nx9	477	54	4
4644	6\nx10	477	60	5
4645	6\nx11	477	66	6
4646	6\nx12	477	72	7
4647	6\nx13	477	78	8
4648	6\nx14	477	84	9
4649	6\nx15	477	90	10
4650	6\nx7	478	42	1
4651	6\nx8	478	48	2
4652	6\nx9	478	54	3
3045	4\nx11	317	44	6
4585	6\nx15	471	90	6
4586	6\nx16	471	96	7
4587	6\nx17	471	102	8
4588	6\nx18	471	108	9
4589	6\nx19	471	114	10
4590	6\nx11	472	66	1
4591	6\nx12	472	72	2
4592	6\nx13	472	78	3
4593	6\nx14	472	84	4
4662	6\nx10	479	60	3
4619	6\nx12	474	72	10
4594	6\nx15	472	90	5
4595	6\nx16	472	96	6
4596	6\nx17	472	102	7
4597	6\nx18	472	108	8
4598	6\nx19	472	114	9
4599	6\nx20	472	120	10
4600	6\nx2	473	12	1
4601	6\nx3	473	18	2
4602	6\nx4	473	24	3
4603	6\nx5	473	30	4
4604	6\nx6	473	36	5
4605	6\nx7	473	42	6
4606	6\nx8	473	48	7
4607	6\nx9	473	54	8
4608	6\nx10	473	60	9
4609	6\nx11	473	66	10
4610	6\nx3	474	18	1
4611	6\nx4	474	24	2
4612	6\nx5	474	30	3
4613	6\nx6	474	36	4
4614	6\nx7	474	42	5
4615	6\nx8	474	48	6
4616	6\nx9	474	54	7
4617	6\nx10	474	60	8
4618	6\nx11	474	66	9
4653	6\nx10	478	60	4
4654	6\nx11	478	66	5
4655	6\nx12	478	72	6
4656	6\nx13	478	78	7
4657	6\nx14	478	84	8
4658	6\nx15	478	90	9
4659	6\nx16	478	96	10
4660	6\nx8	479	48	1
4661	6\nx9	479	54	2
4620	6\nx4	475	24	1
4621	6\nx5	475	30	2
4622	6\nx6	475	36	3
4623	6\nx7	475	42	4
4624	6\nx8	475	48	5
4625	6\nx9	475	54	6
4626	6\nx10	475	60	7
4627	6\nx11	475	66	8
4628	6\nx12	475	72	9
4629	6\nx13	475	78	10
4630	6\nx5	476	30	1
4631	6\nx6	476	36	2
4632	6\nx7	476	42	3
4633	6\nx8	476	48	4
4634	6\nx9	476	54	5
4635	6\nx10	476	60	6
4636	6\nx11	476	66	7
4637	6\nx12	476	72	8
4638	6\nx13	476	78	9
4639	6\nx14	476	84	10
4640	6\nx6	477	36	1
4641	6\nx7	477	42	2
4720	24\n/6	485	4	1
4721	30\n/6	485	5	2
4722	36\n/6	485	6	3
4723	42\n/6	485	7	4
4724	48\n/6	485	8	5
4725	54\n/6	485	9	6
4726	60\n/6	485	10	7
4727	66\n/6	485	11	8
4728	72\n/6	485	12	9
4729	78\n/6	485	13	10
4730	30\n/6	486	5	1
4663	6\nx11	479	66	4
4664	6\nx12	479	72	5
4665	6\nx13	479	78	6
4666	6\nx14	479	84	7
4667	6\nx15	479	90	8
4668	6\nx16	479	96	9
4669	6\nx17	479	102	10
4670	6\nx9	480	54	1
4671	6\nx10	480	60	2
4672	6\nx11	480	66	3
4673	6\nx12	480	72	4
4674	6\nx13	480	78	5
4675	6\nx14	480	84	6
4676	6\nx15	480	90	7
4677	6\nx16	480	96	8
4678	6\nx17	480	102	9
4679	6\nx18	480	108	10
4680	6\nx10	481	60	1
4681	6\nx11	481	66	2
4682	6\nx12	481	72	3
4683	6\nx13	481	78	4
4684	6\nx14	481	84	5
4685	6\nx15	481	90	6
4686	6\nx16	481	96	7
4687	6\nx17	481	102	8
4688	6\nx18	481	108	9
4689	6\nx19	481	114	10
4690	6\nx11	482	66	1
4691	6\nx12	482	72	2
4692	6\nx13	482	78	3
4693	6\nx14	482	84	4
4731	36\n/6	486	6	2
4732	42\n/6	486	7	3
4733	48\n/6	486	8	4
4734	54\n/6	486	9	5
4735	60\n/6	486	10	6
4736	66\n/6	486	11	7
4694	6\nx15	482	90	5
4695	6\nx16	482	96	6
4696	6\nx17	482	102	7
4697	6\nx18	482	108	8
4698	6\nx19	482	114	9
4699	6\nx20	482	120	10
4737	72\n/6	486	12	8
4738	78\n/6	486	13	9
4739	84\n/6	486	14	10
4740	36\n/6	487	6	1
4741	42\n/6	487	7	2
4742	48\n/6	487	8	3
4700	12\n/6	483	2	1
4701	18\n/6	483	3	2
4702	24\n/6	483	4	3
4703	30\n/6	483	5	4
4704	36\n/6	483	6	5
4705	42\n/6	483	7	6
4706	48\n/6	483	8	7
4707	54\n/6	483	9	8
4708	60\n/6	483	10	9
4709	66\n/6	483	11	10
4710	18\n/6	484	3	1
4711	24\n/6	484	4	2
4712	30\n/6	484	5	3
4713	36\n/6	484	6	4
4714	42\n/6	484	7	5
4715	48\n/6	484	8	6
4716	54\n/6	484	9	7
4717	60\n/6	484	10	8
4718	66\n/6	484	11	9
4719	72\n/6	484	12	10
4762	60\n/6	489	10	3
4807	54\n/6	493	9	8
4808	60\n/6	493	10	9
4809	66\n/6	493	11	10
4810	18\n/6	494	3	1
4811	24\n/6	494	4	2
4812	30\n/6	494	5	3
4771	60\n/6	490	10	2
4772	66\n/6	490	11	3
4773	72\n/6	490	12	4
4774	78\n/6	490	13	5
4775	84\n/6	490	14	6
4776	90\n/6	490	15	7
4777	96\n/6	490	16	8
4778	102\n/6	490	17	9
4779	108\n/6	490	18	10
4780	60\n/6	491	10	1
4781	66\n/6	491	11	2
4782	72\n/6	491	12	3
4783	78\n/6	491	13	4
4784	84\n/6	491	14	5
4785	90\n/6	491	15	6
4786	96\n/6	491	16	7
4787	102\n/6	491	17	8
4788	108\n/6	491	18	9
4789	114\n/6	491	19	10
4790	66\n/6	492	11	1
4815	48\n/6	494	8	6
4791	72\n/6	492	12	2
4792	78\n/6	492	13	3
4793	84\n/6	492	14	4
4794	90\n/6	492	15	5
4795	96\n/6	492	16	6
4796	102\n/6	492	17	7
4797	108\n/6	492	18	8
4813	36\n/6	494	6	4
4814	42\n/6	494	7	5
4763	66\n/6	489	11	4
4764	72\n/6	489	12	5
4765	78\n/6	489	13	6
4766	84\n/6	489	14	7
4767	90\n/6	489	15	8
4768	96\n/6	489	16	9
4769	102\n/6	489	17	10
4770	54\n/6	490	9	1
4798	114\n/6	492	19	9
4799	120\n/6	492	20	10
4800	12\n/6	493	2	1
4801	18\n/6	493	3	2
4802	24\n/6	493	4	3
4803	30\n/6	493	5	4
4804	36\n/6	493	6	5
4805	42\n/6	493	7	6
4806	48\n/6	493	8	7
4816	54\n/6	494	9	7
4817	60\n/6	494	10	8
4818	66\n/6	494	11	9
4819	72\n/6	494	12	10
4820	24\n/6	495	4	1
4821	30\n/6	495	5	2
4822	36\n/6	495	6	3
4823	42\n/6	495	7	4
3125	36\n/4	325	9	6
4744	60\n/6	487	10	5
4745	66\n/6	487	11	6
4746	72\n/6	487	12	7
4747	78\n/6	487	13	8
4748	84\n/6	487	14	9
4749	90\n/6	487	15	10
4750	42\n/6	488	7	1
4751	48\n/6	488	8	2
4752	54\n/6	488	9	3
4753	60\n/6	488	10	4
4754	66\n/6	488	11	5
4755	72\n/6	488	12	6
4756	78\n/6	488	13	7
4757	84\n/6	488	14	8
4758	90\n/6	488	15	9
4759	96\n/6	488	16	10
4760	48\n/6	489	8	1
4761	54\n/6	489	9	2
4883	78\n/6	501	13	4
4884	84\n/6	501	14	5
4885	90\n/6	501	15	6
4886	96\n/6	501	16	7
4852	54\n/6	498	9	3
4853	60\n/6	498	10	4
4854	66\n/6	498	11	5
4855	72\n/6	498	12	6
4856	78\n/6	498	13	7
4857	84\n/6	498	14	8
4858	90\n/6	498	15	9
4859	96\n/6	498	16	10
4860	48\n/6	499	8	1
4861	54\n/6	499	9	2
4862	60\n/6	499	10	3
4863	66\n/6	499	11	4
4864	72\n/6	499	12	5
4865	78\n/6	499	13	6
4866	84\n/6	499	14	7
4867	90\n/6	499	15	8
4868	96\n/6	499	16	9
4869	102\n/6	499	17	10
4870	54\n/6	500	9	1
4871	60\n/6	500	10	2
4872	66\n/6	500	11	3
4873	72\n/6	500	12	4
4874	78\n/6	500	13	5
4828	72\n/6	495	12	9
4875	84\n/6	500	14	6
4876	90\n/6	500	15	7
4877	96\n/6	500	16	8
4878	102\n/6	500	17	9
4895	96\n/6	502	16	6
4896	102\n/6	502	17	7
4897	108\n/6	502	18	8
4898	114\n/6	502	19	9
4899	120\n/6	502	20	10
3206	32\n/4	333	8	7
4825	54\n/6	495	9	6
4826	60\n/6	495	10	7
4827	66\n/6	495	11	8
4887	102\n/6	501	17	8
4888	108\n/6	501	18	9
4889	114\n/6	501	19	10
4890	66\n/6	502	11	1
4891	72\n/6	502	12	2
4892	78\n/6	502	13	3
4893	84\n/6	502	14	4
4900	9\n+1	503	10	1
4901	10\n+2	503	12	2
4902	11\n+3	503	14	3
4903	12\n+4	503	16	4
4904	13\n+5	503	18	5
4894	90\n/6	502	15	5
4829	78\n/6	495	13	10
4830	30\n/6	496	5	1
4831	36\n/6	496	6	2
4832	42\n/6	496	7	3
4833	48\n/6	496	8	4
4834	54\n/6	496	9	5
4835	60\n/6	496	10	6
4836	66\n/6	496	11	7
4837	72\n/6	496	12	8
4838	78\n/6	496	13	9
4839	84\n/6	496	14	10
4840	36\n/6	497	6	1
4841	42\n/6	497	7	2
4842	48\n/6	497	8	3
4843	54\n/6	497	9	4
4844	60\n/6	497	10	5
4845	66\n/6	497	11	6
4846	72\n/6	497	12	7
4847	78\n/6	497	13	8
4848	84\n/6	497	14	9
4849	90\n/6	497	15	10
4850	42\n/6	498	7	1
4851	48\n/6	498	8	2
4879	108\n/6	500	18	10
4880	60\n/6	501	10	1
4881	66\n/6	501	11	2
4882	72\n/6	501	12	3
4934	16\n+5	506	21	5
4935	17\n+6	506	23	6
4936	18\n+7	506	25	7
4937	19\n+8	506	27	8
4938	20\n+9	506	29	9
4939	21\n+10	506	31	10
4940	13\n+1	507	14	1
4941	14\n+2	507	16	2
4942	15\n+3	507	18	3
4943	16\n+4	507	20	4
4944	17\n+5	507	22	5
4945	18\n+6	507	24	6
4946	19\n+7	507	26	7
4947	20\n+8	507	28	8
4948	21\n+9	507	30	9
4949	22\n+10	507	32	10
4950	14\n+1	508	15	1
4951	15\n+2	508	17	2
4952	16\n+3	508	19	3
4953	17\n+4	508	21	4
4954	18\n+5	508	23	5
4955	19\n+6	508	25	6
4956	20\n+7	508	27	7
4957	21\n+8	508	29	8
4958	22\n+9	508	31	9
4959	23\n+10	508	33	10
4960	15\n+1	509	16	1
4906	15\n+7	503	22	7
4961	16\n+2	509	18	2
4962	17\n+3	509	20	3
4963	18\n+4	509	22	4
4964	19\n+5	509	24	5
4965	20\n+6	509	26	6
4966	21\n+7	509	28	7
4967	22\n+8	509	30	8
4968	23\n+9	509	32	9
4969	24\n+10	509	34	10
4970	16\n+1	510	17	1
4971	17\n+2	510	19	2
4972	18\n+3	510	21	3
4973	19\n+4	510	23	4
4974	20\n+5	510	25	5
4975	21\n+6	510	27	6
4976	22\n+7	510	29	7
4977	23\n+8	510	31	8
4978	24\n+9	510	33	9
4979	25\n+10	510	35	10
4980	17\n+1	511	18	1
4981	18\n+2	511	20	2
4982	19\n+3	511	22	3
4983	20\n+4	511	24	4
4984	21\n+5	511	26	5
4985	22\n+6	511	28	6
3287	68\n/4	341	17	8
4907	16\n+8	503	24	8
4908	17\n+9	503	26	9
4909	18\n+10	503	28	10
4910	10\n+1	504	11	1
4911	11\n+2	504	13	2
4912	12\n+3	504	15	3
4913	13\n+4	504	17	4
4914	14\n+5	504	19	5
4915	15\n+6	504	21	6
4916	16\n+7	504	23	7
4917	17\n+8	504	25	8
4918	18\n+9	504	27	9
4919	19\n+10	504	29	10
4920	11\n+1	505	12	1
4921	12\n+2	505	14	2
4922	13\n+3	505	16	3
4923	14\n+4	505	18	4
4924	15\n+5	505	20	5
4925	16\n+6	505	22	6
4926	17\n+7	505	24	7
4927	18\n+8	505	26	8
4928	19\n+9	505	28	9
4929	20\n+10	505	30	10
4930	12\n+1	506	13	1
4931	13\n+2	506	15	2
4932	14\n+3	506	17	3
4933	15\n+4	506	19	4
5015	15\n+6	514	21	6
5016	16\n+7	514	23	7
5017	17\n+8	514	25	8
5018	18\n+9	514	27	9
5019	19\n+10	514	29	10
5020	11\n+1	515	12	1
5021	12\n+2	515	14	2
5022	13\n+3	515	16	3
5023	14\n+4	515	18	4
5024	15\n+5	515	20	5
5025	16\n+6	515	22	6
5026	17\n+7	515	24	7
5027	18\n+8	515	26	8
5028	19\n+9	515	28	9
5029	20\n+10	515	30	10
5030	12\n+1	516	13	1
5031	13\n+2	516	15	2
5032	14\n+3	516	17	3
5033	15\n+4	516	19	4
5034	16\n+5	516	21	5
5035	17\n+6	516	23	6
5036	18\n+7	516	25	7
5037	19\n+8	516	27	8
5038	20\n+9	516	29	9
5039	21\n+10	516	31	10
5040	13\n+1	517	14	1
3368	21\n+9	349	30	9
5041	14\n+2	517	16	2
5042	15\n+3	517	18	3
5043	16\n+4	517	20	4
5044	17\n+5	517	22	5
5045	18\n+6	517	24	6
5046	19\n+7	517	26	7
5047	20\n+8	517	28	8
5048	21\n+9	517	30	9
5049	22\n+10	517	32	10
5050	14\n+1	518	15	1
5051	15\n+2	518	17	2
5052	16\n+3	518	19	3
5053	17\n+4	518	21	4
5054	18\n+5	518	23	5
5055	19\n+6	518	25	6
5056	20\n+7	518	27	7
5057	21\n+8	518	29	8
5058	22\n+9	518	31	9
5059	23\n+10	518	33	10
5060	15\n+1	519	16	1
5061	16\n+2	519	18	2
5062	17\n+3	519	20	3
5063	18\n+4	519	22	4
5064	19\n+5	519	24	5
5065	20\n+6	519	26	6
5066	21\n+7	519	28	7
4987	24\n+8	511	32	8
4988	25\n+9	511	34	9
4989	26\n+10	511	36	10
4990	18\n+1	512	19	1
4991	19\n+2	512	21	2
4992	20\n+3	512	23	3
4993	21\n+4	512	25	4
4994	22\n+5	512	27	5
4995	23\n+6	512	29	6
4996	24\n+7	512	31	7
4997	25\n+8	512	33	8
4998	26\n+9	512	35	9
4999	27\n+10	512	37	10
5000	9\n+1	513	10	1
5001	10\n+2	513	12	2
5002	11\n+3	513	14	3
5003	12\n+4	513	16	4
5004	13\n+5	513	18	5
5005	14\n+6	513	20	6
5006	15\n+7	513	22	7
5007	16\n+8	513	24	8
5008	17\n+9	513	26	9
5009	18\n+10	513	28	10
5010	10\n+1	514	11	1
5011	11\n+2	514	13	2
5012	12\n+3	514	15	3
5013	13\n+4	514	17	4
5014	14\n+5	514	19	5
5096	24\n+7	522	31	7
5097	25\n+8	522	33	8
5098	26\n+9	522	35	9
5099	27\n+10	522	37	10
5100	9\n+1	523	10	1
5101	10\n+2	523	12	2
5102	11\n+3	523	14	3
5103	12\n+4	523	16	4
5104	13\n+5	523	18	5
5105	14\n+6	523	20	6
5106	15\n+7	523	22	7
5107	16\n+8	523	24	8
5108	17\n+9	523	26	9
5109	18\n+10	523	28	10
5110	10\n+1	524	11	1
5111	11\n+2	524	13	2
5112	12\n+3	524	15	3
5113	13\n+4	524	17	4
5114	14\n+5	524	19	5
5115	15\n+6	524	21	6
5116	16\n+7	524	23	7
5117	17\n+8	524	25	8
5118	18\n+9	524	27	9
5119	19\n+10	524	29	10
5120	11\n+1	525	12	1
5121	12\n+2	525	14	2
3449	20\n+10	357	30	10
5122	13\n+3	525	16	3
5123	14\n+4	525	18	4
5124	15\n+5	525	20	5
5125	16\n+6	525	22	6
5126	17\n+7	525	24	7
5127	18\n+8	525	26	8
5128	19\n+9	525	28	9
5129	20\n+10	525	30	10
5130	12\n+1	526	13	1
5131	13\n+2	526	15	2
5132	14\n+3	526	17	3
5133	15\n+4	526	19	4
5134	16\n+5	526	21	5
5135	17\n+6	526	23	6
5136	18\n+7	526	25	7
5137	19\n+8	526	27	8
5138	20\n+9	526	29	9
5139	21\n+10	526	31	10
5140	13\n+1	527	14	1
5141	14\n+2	527	16	2
5142	15\n+3	527	18	3
5143	16\n+4	527	20	4
5144	17\n+5	527	22	5
5145	18\n+6	527	24	6
5146	19\n+7	527	26	7
5147	20\n+8	527	28	8
5068	23\n+9	519	32	9
5069	24\n+10	519	34	10
5070	16\n+1	520	17	1
5071	17\n+2	520	19	2
5072	18\n+3	520	21	3
5073	19\n+4	520	23	4
5074	20\n+5	520	25	5
5075	21\n+6	520	27	6
5076	22\n+7	520	29	7
5077	23\n+8	520	31	8
5078	24\n+9	520	33	9
5079	25\n+10	520	35	10
5080	17\n+1	521	18	1
5081	18\n+2	521	20	2
5082	19\n+3	521	22	3
5083	20\n+4	521	24	4
5084	21\n+5	521	26	5
5085	22\n+6	521	28	6
5086	23\n+7	521	30	7
5087	24\n+8	521	32	8
5088	25\n+9	521	34	9
5089	26\n+10	521	36	10
5090	18\n+1	522	19	1
5091	19\n+2	522	21	2
5092	20\n+3	522	23	3
5093	21\n+4	522	25	4
5094	22\n+5	522	27	5
5095	23\n+6	522	29	6
5194	22\n+5	532	27	5
5195	23\n+6	532	29	6
5196	24\n+7	532	31	7
5149	22\n+10	527	32	10
5197	25\n+8	532	33	8
5198	26\n+9	532	35	9
5199	27\n+10	532	37	10
5150	14\n+1	528	15	1
5151	15\n+2	528	17	2
5152	16\n+3	528	19	3
5153	17\n+4	528	21	4
5154	18\n+5	528	23	5
5155	19\n+6	528	25	6
5156	20\n+7	528	27	7
5157	21\n+8	528	29	8
5158	22\n+9	528	31	9
5159	23\n+10	528	33	10
5160	15\n+1	529	16	1
5161	16\n+2	529	18	2
5162	17\n+3	529	20	3
5163	18\n+4	529	22	4
5164	19\n+5	529	24	5
5165	20\n+6	529	26	6
5166	21\n+7	529	28	7
5167	22\n+8	529	30	8
5168	23\n+9	529	32	9
5169	24\n+10	529	34	10
5170	16\n+1	530	17	1
5171	17\n+2	530	19	2
5172	18\n+3	530	21	3
5173	19\n+4	530	23	4
5174	20\n+5	530	25	5
5175	21\n+6	530	27	6
5176	22\n+7	530	29	7
5177	23\n+8	530	31	8
5178	24\n+9	530	33	9
5179	25\n+10	530	35	10
5180	17\n+1	531	18	1
5181	18\n+2	531	20	2
5182	19\n+3	531	22	3
5183	20\n+4	531	24	4
5184	21\n+5	531	26	5
5185	22\n+6	531	28	6
5186	23\n+7	531	30	7
5187	24\n+8	531	32	8
5188	25\n+9	531	34	9
5189	26\n+10	531	36	10
5190	18\n+1	532	19	1
5191	19\n+2	532	21	2
5192	20\n+3	532	23	3
5193	21\n+4	532	25	4
5200	9\n10\n11	533	30	1
5201	10\n11\n12	533	33	2
5202	11\n12\n13	533	36	3
5203	12\n13\n14	533	39	4
5204	13\n14\n15	533	42	5
5205	14\n15\n16	533	45	6
5206	15\n16\n17	533	48	7
5207	16\n17\n18	533	51	8
5208	17\n18\n19	533	54	9
5209	18\n19\n20	533	57	10
5210	10\n11\n12	534	33	1
5211	11\n12\n13	534	36	2
5212	12\n13\n14	534	39	3
5213	13\n14\n15	534	42	4
5214	14\n15\n16	534	45	5
5215	15\n16\n17	534	48	6
5216	16\n17\n18	534	51	7
5217	17\n18\n19	534	54	8
5218	18\n19\n20	534	57	9
5219	19\n20\n21	534	60	10
5220	11\n12\n13	535	36	1
5221	12\n13\n14	535	39	2
5222	13\n14\n15	535	42	3
5223	14\n15\n16	535	45	4
5224	15\n16\n17	535	48	5
5225	16\n17\n18	535	51	6
5226	17\n18\n19	535	54	7
5227	18\n19\n20	535	57	8
5228	19\n20\n21	535	60	9
5229	20\n21\n22	535	63	10
5230	12\n13\n14	536	39	1
5231	13\n14\n15	536	42	2
5233	15\n16\n17	536	48	4
5234	16\n17\n18	536	51	5
5235	17\n18\n19	536	54	6
5236	18\n19\n20	536	57	7
5237	19\n20\n21	536	60	8
5238	20\n21\n22	536	63	9
5239	21\n22\n23	536	66	10
5240	13\n14\n15	537	42	1
5241	14\n15\n16	537	45	2
5242	15\n16\n17	537	48	3
5243	16\n17\n18	537	51	4
5244	17\n18\n19	537	54	5
5245	18\n19\n20	537	57	6
5246	19\n20\n21	537	60	7
5247	20\n21\n22	537	63	8
5248	21\n22\n23	537	66	9
5249	22\n23\n24	537	69	10
5250	14\n15\n16	538	45	1
5251	15\n16\n17	538	48	2
5252	16\n17\n18	538	51	3
5253	17\n18\n19	538	54	4
5254	18\n19\n20	538	57	5
5255	19\n20\n21	538	60	6
5256	20\n21\n22	538	63	7
5257	21\n22\n23	538	66	8
5258	22\n23\n24	538	69	9
5259	23\n24\n25	538	72	10
5260	15\n16\n17	539	48	1
5261	16\n17\n18	539	51	2
5262	17\n18\n19	539	54	3
5263	18\n19\n20	539	57	4
5264	19\n20\n21	539	60	5
5265	20\n21\n22	539	63	6
5266	21\n22\n23	539	66	7
5267	22\n23\n24	539	69	8
5268	23\n24\n25	539	72	9
5269	24\n25\n26	539	75	10
5270	16\n17\n18	540	51	1
5271	17\n18\n19	540	54	2
5272	18\n19\n20	540	57	3
5273	19\n20\n21	540	60	4
5274	20\n21\n22	540	63	5
5275	21\n22\n23	540	66	6
5276	22\n23\n24	540	69	7
5277	23\n24\n25	540	72	8
5278	24\n25\n26	540	75	9
5279	25\n26\n27	540	78	10
5280	17\n18\n19	541	54	1
5281	18\n19\n20	541	57	2
5282	19\n20\n21	541	60	3
5283	20\n21\n22	541	63	4
5284	21\n22\n23	541	66	5
5285	22\n23\n24	541	69	6
5286	23\n24\n25	541	72	7
5287	24\n25\n26	541	75	8
5288	25\n26\n27	541	78	9
5289	26\n27\n28	541	81	10
5290	18\n19\n20	542	57	1
5291	19\n20\n21	542	60	2
5292	20\n21\n22	542	63	3
5293	21\n22\n23	542	66	4
5294	22\n23\n24	542	69	5
5295	23\n24\n25	542	72	6
5296	24\n25\n26	542	75	7
5297	25\n26\n27	542	78	8
5298	26\n27\n28	542	81	9
5299	27\n28\n29	542	84	10
5301	7\nx3	543	21	2
3700	5\nx2	383	10	1
5300	7\nx2	543	14	1
5302	7\nx4	543	28	3
5303	7\nx5	543	35	4
5304	7\nx6	543	42	5
5305	7\nx7	543	49	6
5306	7\nx8	543	56	7
5307	7\nx9	543	63	8
5308	7\nx10	543	70	9
5309	7\nx11	543	77	10
5310	7\nx3	544	21	1
5311	7\nx4	544	28	2
5312	7\nx5	544	35	3
5313	7\nx6	544	42	4
5314	7\nx7	544	49	5
5315	7\nx8	544	56	6
5316	7\nx9	544	63	7
5336	7\nx11	546	77	7
5337	7\nx12	546	84	8
5338	7\nx13	546	91	9
5339	7\nx14	546	98	10
5340	7\nx6	547	42	1
5341	7\nx7	547	49	2
5342	7\nx8	547	56	3
5343	7\nx9	547	63	4
5344	7\nx10	547	70	5
5345	7\nx11	547	77	6
5368	7\nx16	549	112	9
5369	7\nx17	549	119	10
5370	7\nx9	550	63	1
5371	7\nx10	550	70	2
5320	7\nx4	545	28	1
5346	7\nx12	547	84	7
5347	7\nx13	547	91	8
5348	7\nx14	547	98	9
5349	7\nx15	547	105	10
5350	7\nx7	548	49	1
5351	7\nx8	548	56	2
5352	7\nx9	548	63	3
5353	7\nx10	548	70	4
5354	7\nx11	548	77	5
5355	7\nx12	548	84	6
5356	7\nx13	548	91	7
5357	7\nx14	548	98	8
5358	7\nx15	548	105	9
5359	7\nx16	548	112	10
5360	7\nx8	549	56	1
5361	7\nx9	549	63	2
5362	7\nx10	549	70	3
5363	7\nx11	549	77	4
5364	7\nx12	549	84	5
5365	7\nx13	549	91	6
5366	7\nx14	549	98	7
5367	7\nx15	549	105	8
5321	7\nx5	545	35	2
5372	7\nx11	550	77	3
5373	7\nx12	550	84	4
5374	7\nx13	550	91	5
5375	7\nx14	550	98	6
5376	7\nx15	550	105	7
5377	7\nx16	550	112	8
5378	7\nx17	550	119	9
5379	7\nx18	550	126	10
5380	7\nx10	551	70	1
5381	7\nx11	551	77	2
5382	7\nx12	551	84	3
5383	7\nx13	551	91	4
5384	7\nx14	551	98	5
5385	7\nx15	551	105	6
5386	7\nx16	551	112	7
5387	7\nx17	551	119	8
5388	7\nx18	551	126	9
5389	7\nx19	551	133	10
5390	7\nx11	552	77	1
5391	7\nx12	552	84	2
3775	5\nx14	390	70	6
5318	7\nx11	544	77	9
5319	7\nx12	544	84	10
5322	7\nx6	545	42	3
5323	7\nx7	545	49	4
5324	7\nx8	545	56	5
5325	7\nx9	545	63	6
5326	7\nx10	545	70	7
5327	7\nx11	545	77	8
5328	7\nx12	545	84	9
5329	7\nx13	545	91	10
5330	7\nx5	546	35	1
5331	7\nx6	546	42	2
5332	7\nx7	546	49	3
5333	7\nx8	546	56	4
5334	7\nx9	546	63	5
5335	7\nx10	546	70	6
5449	7\nx15	557	105	10
5450	7\nx7	558	49	1
5451	7\nx8	558	56	2
5452	7\nx9	558	63	3
5453	7\nx10	558	70	4
5454	7\nx11	558	77	5
5455	7\nx12	558	84	6
5456	7\nx13	558	91	7
5457	7\nx14	558	98	8
5458	7\nx15	558	105	9
5471	7\nx10	560	70	2
5393	7\nx14	552	98	4
5394	7\nx15	552	105	5
5395	7\nx16	552	112	6
5396	7\nx17	552	119	7
5397	7\nx18	552	126	8
5398	7\nx19	552	133	9
5399	7\nx20	552	140	10
5400	7\nx2	553	14	1
5401	7\nx3	553	21	2
5402	7\nx4	553	28	3
5470	7\nx9	560	63	1
5426	7\nx10	555	70	7
5403	7\nx5	553	35	4
5404	7\nx6	553	42	5
5405	7\nx7	553	49	6
5406	7\nx8	553	56	7
5407	7\nx9	553	63	8
5408	7\nx10	553	70	9
5409	7\nx11	553	77	10
5410	7\nx3	554	21	1
5411	7\nx4	554	28	2
5412	7\nx5	554	35	3
5413	7\nx6	554	42	4
5414	7\nx7	554	49	5
5415	7\nx8	554	56	6
5416	7\nx9	554	63	7
5417	7\nx10	554	70	8
5418	7\nx11	554	77	9
5419	7\nx12	554	84	10
5420	7\nx4	555	28	1
5421	7\nx5	555	35	2
5422	7\nx6	555	42	3
5423	7\nx7	555	49	4
5424	7\nx8	555	56	5
5425	7\nx9	555	63	6
5459	7\nx16	558	112	10
5460	7\nx8	559	56	1
5461	7\nx9	559	63	2
5462	7\nx10	559	70	3
5463	7\nx11	559	77	4
5464	7\nx12	559	84	5
5465	7\nx13	559	91	6
5466	7\nx14	559	98	7
5467	7\nx15	559	105	8
5468	7\nx16	559	112	9
5469	7\nx17	559	119	10
5427	7\nx11	555	77	8
5428	7\nx12	555	84	9
5429	7\nx13	555	91	10
5430	7\nx5	556	35	1
5431	7\nx6	556	42	2
5432	7\nx7	556	49	3
5433	7\nx8	556	56	4
5434	7\nx9	556	63	5
5435	7\nx10	556	70	6
5436	7\nx11	556	77	7
5437	7\nx12	556	84	8
5438	7\nx13	556	91	9
5439	7\nx14	556	98	10
5440	7\nx6	557	42	1
5441	7\nx7	557	49	2
5442	7\nx8	557	56	3
5443	7\nx9	557	63	4
5444	7\nx10	557	70	5
5445	7\nx11	557	77	6
5446	7\nx12	557	84	7
5447	7\nx13	557	91	8
5448	7\nx14	557	98	9
5516	63\n/7	564	9	7
5517	70\n/7	564	10	8
5518	77\n/7	564	11	9
5533	56\n/7	566	8	4
5534	63\n/7	566	9	5
5535	70\n/7	566	10	6
5536	77\n/7	566	11	7
5537	84\n/7	566	12	8
5538	91\n/7	566	13	9
5473	7\nx12	560	84	4
5474	7\nx13	560	91	5
5475	7\nx14	560	98	6
5476	7\nx15	560	105	7
5477	7\nx16	560	112	8
5478	7\nx17	560	119	9
5479	7\nx18	560	126	10
5480	7\nx10	561	70	1
5481	7\nx11	561	77	2
5482	7\nx12	561	84	3
5483	7\nx13	561	91	4
5484	7\nx14	561	98	5
5485	7\nx15	561	105	6
5486	7\nx16	561	112	7
5487	7\nx17	561	119	8
5542	56\n/7	567	8	3
5488	7\nx18	561	126	9
5489	7\nx19	561	133	10
5490	7\nx11	562	77	1
5491	7\nx12	562	84	2
5492	7\nx13	562	91	3
5493	7\nx14	562	98	4
5494	7\nx15	562	105	5
5495	7\nx16	562	112	6
5496	7\nx17	562	119	7
5497	7\nx18	562	126	8
5498	7\nx19	562	133	9
5519	84\n/7	564	12	10
5520	28\n/7	565	4	1
5521	35\n/7	565	5	2
5522	42\n/7	565	6	3
5523	49\n/7	565	7	4
5524	56\n/7	565	8	5
5525	63\n/7	565	9	6
5526	70\n/7	565	10	7
5527	77\n/7	565	11	8
5528	84\n/7	565	12	9
5529	91\n/7	565	13	10
5530	35\n/7	566	5	1
5531	42\n/7	566	6	2
5499	7\nx20	562	140	10
5539	98\n/7	566	14	10
5540	42\n/7	567	6	1
5541	49\n/7	567	7	2
5532	49\n/7	566	7	3
5543	63\n/7	567	9	4
5544	70\n/7	567	10	5
5545	77\n/7	567	11	6
5546	84\n/7	567	12	7
5547	91\n/7	567	13	8
5548	98\n/7	567	14	9
5549	105\n/7	567	15	10
5550	49\n/7	568	7	1
5551	56\n/7	568	8	2
3934	45\n/5	406	9	5
5500	14\n/7	563	2	1
5501	21\n/7	563	3	2
5502	28\n/7	563	4	3
5503	35\n/7	563	5	4
5504	42\n/7	563	6	5
5505	49\n/7	563	7	6
5506	56\n/7	563	8	7
5507	63\n/7	563	9	8
5508	70\n/7	563	10	9
5509	77\n/7	563	11	10
5510	21\n/7	564	3	1
5511	28\n/7	564	4	2
5512	35\n/7	564	5	3
5513	42\n/7	564	6	4
5514	49\n/7	564	7	5
5515	56\n/7	564	8	6
5612	35\n/7	574	5	3
5613	42\n/7	574	6	4
5614	49\n/7	574	7	5
5615	56\n/7	574	8	6
5616	63\n/7	574	9	7
5617	70\n/7	574	10	8
5618	77\n/7	574	11	9
5619	84\n/7	574	12	10
5579	126\n/7	570	18	10
5580	70\n/7	571	10	1
5581	77\n/7	571	11	2
5582	84\n/7	571	12	3
5583	91\n/7	571	13	4
5584	98\n/7	571	14	5
5585	105\n/7	571	15	6
5586	112\n/7	571	16	7
5587	119\n/7	571	17	8
5588	126\n/7	571	18	9
5589	133\n/7	571	19	10
5590	77\n/7	572	11	1
5591	84\n/7	572	12	2
5592	91\n/7	572	13	3
5593	98\n/7	572	14	4
5594	105\n/7	572	15	5
5595	112\n/7	572	16	6
5596	119\n/7	572	17	7
5597	126\n/7	572	18	8
5620	28\n/7	575	4	1
5598	133\n/7	572	19	9
5599	140\n/7	572	20	10
5600	14\n/7	573	2	1
5601	21\n/7	573	3	2
5602	28\n/7	573	4	3
5603	35\n/7	573	5	4
5604	42\n/7	573	6	5
5565	91\n/7	569	13	6
5566	98\n/7	569	14	7
5567	105\n/7	569	15	8
5568	112\n/7	569	16	9
5569	119\n/7	569	17	10
5570	63\n/7	570	9	1
5571	70\n/7	570	10	2
5572	77\n/7	570	11	3
5573	84\n/7	570	12	4
5574	91\n/7	570	13	5
5575	98\n/7	570	14	6
5576	105\n/7	570	15	7
5577	112\n/7	570	16	8
5578	119\n/7	570	17	9
5605	49\n/7	573	7	6
5606	56\n/7	573	8	7
5607	63\n/7	573	9	8
5608	70\n/7	573	10	9
5609	77\n/7	573	11	10
5621	35\n/7	575	5	2
5622	42\n/7	575	6	3
5623	49\n/7	575	7	4
5624	56\n/7	575	8	5
5625	63\n/7	575	9	6
5626	70\n/7	575	10	7
5627	77\n/7	575	11	8
5628	84\n/7	575	12	9
5629	91\n/7	575	13	10
5630	35\n/7	576	5	1
5631	42\n/7	576	6	2
5632	49\n/7	576	7	3
4015	40\n/5	414	8	6
5553	70\n/7	568	10	4
5554	77\n/7	568	11	5
5555	84\n/7	568	12	6
5556	91\n/7	568	13	7
5557	98\n/7	568	14	8
5558	105\n/7	568	15	9
5559	112\n/7	568	16	10
5560	56\n/7	569	8	1
5561	63\n/7	569	9	2
5562	70\n/7	569	10	3
5563	77\n/7	569	11	4
5564	84\n/7	569	12	5
5610	21\n/7	574	3	1
5611	28\n/7	574	4	2
5667	105\n/7	579	15	8
5668	112\n/7	579	16	9
5669	119\n/7	579	17	10
5670	63\n/7	580	9	1
5671	70\n/7	580	10	2
5672	77\n/7	580	11	3
5673	84\n/7	580	12	4
5674	91\n/7	580	13	5
5675	98\n/7	580	14	6
5676	105\n/7	580	15	7
5677	112\n/7	580	16	8
5678	119\n/7	580	17	9
5679	126\n/7	580	18	10
5680	70\n/7	581	10	1
5681	77\n/7	581	11	2
5682	84\n/7	581	12	3
5683	91\n/7	581	13	4
5684	98\n/7	581	14	5
5685	105\n/7	581	15	6
5686	112\n/7	581	16	7
5687	119\n/7	581	17	8
4096	85\n/5	422	17	7
5634	63\n/7	576	9	5
5635	70\n/7	576	10	6
5636	77\n/7	576	11	7
5637	84\n/7	576	12	8
5638	91\n/7	576	13	9
5663	77\n/7	579	11	4
5639	98\n/7	576	14	10
5640	42\n/7	577	6	1
5641	49\n/7	577	7	2
5642	56\n/7	577	8	3
5643	63\n/7	577	9	4
5644	70\n/7	577	10	5
5645	77\n/7	577	11	6
5646	84\n/7	577	12	7
5647	91\n/7	577	13	8
5648	98\n/7	577	14	9
5700	10\n+1	583	11	1
5701	11\n+2	583	13	2
5702	12\n+3	583	15	3
5703	13\n+4	583	17	4
5704	14\n+5	583	19	5
5705	15\n+6	583	21	6
5706	16\n+7	583	23	7
5707	17\n+8	583	25	8
5708	18\n+9	583	27	9
5709	19\n+10	583	29	10
5710	11\n+1	584	12	1
5711	12\n+2	584	14	2
5712	13\n+3	584	16	3
5713	14\n+4	584	18	4
5661	63\n/7	579	9	2
5662	70\n/7	579	10	3
5664	84\n/7	579	12	5
5649	105\n/7	577	15	10
5650	49\n/7	578	7	1
5651	56\n/7	578	8	2
5652	63\n/7	578	9	3
5653	70\n/7	578	10	4
5654	77\n/7	578	11	5
5655	84\n/7	578	12	6
5656	91\n/7	578	13	7
5657	98\n/7	578	14	8
5658	105\n/7	578	15	9
5659	112\n/7	578	16	10
5660	56\n/7	579	8	1
5688	126\n/7	581	18	9
5689	133\n/7	581	19	10
5690	77\n/7	582	11	1
5691	84\n/7	582	12	2
5692	91\n/7	582	13	3
5693	98\n/7	582	14	4
5694	105\n/7	582	15	5
5695	112\n/7	582	16	6
5696	119\n/7	582	17	7
5697	126\n/7	582	18	8
5698	133\n/7	582	19	9
5699	140\n/7	582	20	10
5665	91\n/7	579	13	6
5666	98\n/7	579	14	7
5743	17\n+4	587	21	4
5744	18\n+5	587	23	5
5745	19\n+6	587	25	6
5746	20\n+7	587	27	7
5747	21\n+8	587	29	8
5748	22\n+9	587	31	9
5749	23\n+10	587	33	10
5750	15\n+1	588	16	1
5751	16\n+2	588	18	2
5752	17\n+3	588	20	3
5753	18\n+4	588	22	4
5754	19\n+5	588	24	5
5755	20\n+6	588	26	6
5756	21\n+7	588	28	7
5757	22\n+8	588	30	8
5758	23\n+9	588	32	9
5759	24\n+10	588	34	10
5760	16\n+1	589	17	1
5761	17\n+2	589	19	2
5762	18\n+3	589	21	3
5763	19\n+4	589	23	4
5764	20\n+5	589	25	5
5765	21\n+6	589	27	6
5766	22\n+7	589	29	7
5767	23\n+8	589	31	8
5768	24\n+9	589	33	9
4177	22\n+8	430	30	8
5769	25\n+10	589	35	10
5770	17\n+1	590	18	1
5771	18\n+2	590	20	2
5772	19\n+3	590	22	3
5773	20\n+4	590	24	4
5774	21\n+5	590	26	5
5775	22\n+6	590	28	6
5776	23\n+7	590	30	7
5777	24\n+8	590	32	8
5778	25\n+9	590	34	9
5779	26\n+10	590	36	10
5780	18\n+1	591	19	1
5781	19\n+2	591	21	2
5782	20\n+3	591	23	3
5783	21\n+4	591	25	4
5784	22\n+5	591	27	5
5785	23\n+6	591	29	6
5786	24\n+7	591	31	7
5787	25\n+8	591	33	8
5788	26\n+9	591	35	9
5789	27\n+10	591	37	10
5790	19\n+1	592	20	1
5791	20\n+2	592	22	2
5792	21\n+3	592	24	3
5793	22\n+4	592	26	4
5794	23\n+5	592	28	5
5715	16\n+6	584	22	6
5716	17\n+7	584	24	7
5717	18\n+8	584	26	8
5718	19\n+9	584	28	9
5719	20\n+10	584	30	10
5720	12\n+1	585	13	1
5721	13\n+2	585	15	2
5722	14\n+3	585	17	3
5723	15\n+4	585	19	4
5724	16\n+5	585	21	5
5725	17\n+6	585	23	6
5726	18\n+7	585	25	7
5727	19\n+8	585	27	8
5728	20\n+9	585	29	9
5729	21\n+10	585	31	10
5730	13\n+1	586	14	1
5731	14\n+2	586	16	2
5732	15\n+3	586	18	3
5733	16\n+4	586	20	4
5734	17\n+5	586	22	5
5735	18\n+6	586	24	6
5736	19\n+7	586	26	7
5737	20\n+8	586	28	8
5738	21\n+9	586	30	9
5739	22\n+10	586	32	10
5740	14\n+1	587	15	1
5741	15\n+2	587	17	2
5742	16\n+3	587	19	3
5824	16\n+5	595	21	5
5825	17\n+6	595	23	6
5826	18\n+7	595	25	7
5827	19\n+8	595	27	8
5828	20\n+9	595	29	9
5829	21\n+10	595	31	10
5830	13\n+1	596	14	1
5831	14\n+2	596	16	2
5832	15\n+3	596	18	3
5833	16\n+4	596	20	4
5834	17\n+5	596	22	5
5835	18\n+6	596	24	6
5836	19\n+7	596	26	7
5837	20\n+8	596	28	8
5838	21\n+9	596	30	9
5839	22\n+10	596	32	10
5840	14\n+1	597	15	1
5841	15\n+2	597	17	2
5842	16\n+3	597	19	3
5843	17\n+4	597	21	4
5844	18\n+5	597	23	5
5845	19\n+6	597	25	6
5846	20\n+7	597	27	7
5847	21\n+8	597	29	8
5848	22\n+9	597	31	9
5849	23\n+10	597	33	10
4258	21\n+9	438	30	9
5850	15\n+1	598	16	1
5851	16\n+2	598	18	2
5852	17\n+3	598	20	3
5853	18\n+4	598	22	4
5854	19\n+5	598	24	5
5855	20\n+6	598	26	6
5856	21\n+7	598	28	7
5857	22\n+8	598	30	8
5858	23\n+9	598	32	9
5859	24\n+10	598	34	10
5860	16\n+1	599	17	1
5861	17\n+2	599	19	2
5862	18\n+3	599	21	3
5863	19\n+4	599	23	4
5864	20\n+5	599	25	5
5865	21\n+6	599	27	6
5866	22\n+7	599	29	7
5867	23\n+8	599	31	8
5868	24\n+9	599	33	9
5869	25\n+10	599	35	10
5870	17\n+1	600	18	1
5871	18\n+2	600	20	2
5872	19\n+3	600	22	3
5873	20\n+4	600	24	4
5874	21\n+5	600	26	5
5875	22\n+6	600	28	6
5796	25\n+7	592	32	7
5797	26\n+8	592	34	8
5798	27\n+9	592	36	9
5799	28\n+10	592	38	10
5800	10\n+1	593	11	1
5801	11\n+2	593	13	2
5802	12\n+3	593	15	3
5803	13\n+4	593	17	4
5804	14\n+5	593	19	5
5805	15\n+6	593	21	6
5806	16\n+7	593	23	7
5807	17\n+8	593	25	8
5808	18\n+9	593	27	9
5809	19\n+10	593	29	10
5810	11\n+1	594	12	1
5811	12\n+2	594	14	2
5812	13\n+3	594	16	3
5813	14\n+4	594	18	4
5814	15\n+5	594	20	5
5815	16\n+6	594	22	6
5816	17\n+7	594	24	7
5817	18\n+8	594	26	8
5818	19\n+9	594	28	9
5819	20\n+10	594	30	10
5820	12\n+1	595	13	1
5821	13\n+2	595	15	2
5822	14\n+3	595	17	3
5823	15\n+4	595	19	4
5905	15\n+6	603	21	6
5906	16\n+7	603	23	7
5907	17\n+8	603	25	8
5908	18\n+9	603	27	9
5909	19\n+10	603	29	10
5910	11\n+1	604	12	1
5911	12\n+2	604	14	2
5912	13\n+3	604	16	3
5913	14\n+4	604	18	4
5914	15\n+5	604	20	5
5915	16\n+6	604	22	6
5916	17\n+7	604	24	7
5917	18\n+8	604	26	8
5918	19\n+9	604	28	9
5919	20\n+10	604	30	10
5920	12\n+1	605	13	1
5921	13\n+2	605	15	2
5922	14\n+3	605	17	3
5923	15\n+4	605	19	4
5924	16\n+5	605	21	5
5925	17\n+6	605	23	6
5926	18\n+7	605	25	7
5927	19\n+8	605	27	8
5928	20\n+9	605	29	9
5929	21\n+10	605	31	10
5930	13\n+1	606	14	1
4339	20\n+10	446	30	10
5931	14\n+2	606	16	2
5932	15\n+3	606	18	3
5933	16\n+4	606	20	4
5934	17\n+5	606	22	5
5935	18\n+6	606	24	6
5936	19\n+7	606	26	7
5937	20\n+8	606	28	8
5938	21\n+9	606	30	9
5939	22\n+10	606	32	10
5940	14\n+1	607	15	1
5941	15\n+2	607	17	2
5942	16\n+3	607	19	3
5943	17\n+4	607	21	4
5944	18\n+5	607	23	5
5945	19\n+6	607	25	6
5946	20\n+7	607	27	7
5947	21\n+8	607	29	8
5948	22\n+9	607	31	9
5949	23\n+10	607	33	10
5950	15\n+1	608	16	1
5951	16\n+2	608	18	2
5952	17\n+3	608	20	3
5953	18\n+4	608	22	4
5954	19\n+5	608	24	5
5955	20\n+6	608	26	6
5956	21\n+7	608	28	7
5877	24\n+8	600	32	8
5878	25\n+9	600	34	9
5879	26\n+10	600	36	10
5880	18\n+1	601	19	1
5881	19\n+2	601	21	2
5882	20\n+3	601	23	3
5883	21\n+4	601	25	4
5884	22\n+5	601	27	5
5885	23\n+6	601	29	6
5886	24\n+7	601	31	7
5887	25\n+8	601	33	8
5888	26\n+9	601	35	9
5889	27\n+10	601	37	10
5890	19\n+1	602	20	1
5891	20\n+2	602	22	2
5892	21\n+3	602	24	3
5893	22\n+4	602	26	4
5894	23\n+5	602	28	5
5895	24\n+6	602	30	6
5896	25\n+7	602	32	7
5897	26\n+8	602	34	8
5898	27\n+9	602	36	9
5899	28\n+10	602	38	10
5900	10\n+1	603	11	1
5901	11\n+2	603	13	2
5902	12\n+3	603	15	3
5903	13\n+4	603	17	4
5904	14\n+5	603	19	5
5958	23\n+9	608	32	9
5959	24\n+10	608	34	10
5960	16\n+1	609	17	1
5961	17\n+2	609	19	2
5962	18\n+3	609	21	3
5963	19\n+4	609	23	4
5964	20\n+5	609	25	5
5965	21\n+6	609	27	6
5966	22\n+7	609	29	7
5967	23\n+8	609	31	8
5968	24\n+9	609	33	9
5969	25\n+10	609	35	10
5970	17\n+1	610	18	1
5971	18\n+2	610	20	2
5972	19\n+3	610	22	3
5973	20\n+4	610	24	4
5974	21\n+5	610	26	5
5975	22\n+6	610	28	6
5976	23\n+7	610	30	7
5977	24\n+8	610	32	8
5978	25\n+9	610	34	9
5979	26\n+10	610	36	10
5980	18\n+1	611	19	1
5981	19\n+2	611	21	2
5982	20\n+3	611	23	3
5983	21\n+4	611	25	4
5984	22\n+5	611	27	5
5985	23\n+6	611	29	6
5986	24\n+7	611	31	7
5987	25\n+8	611	33	8
5988	26\n+9	611	35	9
5989	27\n+10	611	37	10
5990	19\n+1	612	20	1
5991	20\n+2	612	22	2
5992	21\n+3	612	24	3
5993	22\n+4	612	26	4
5994	23\n+5	612	28	5
5995	24\n+6	612	30	6
5996	25\n+7	612	32	7
5997	26\n+8	612	34	8
5998	27\n+9	612	36	9
5999	28\n+10	612	38	10
6000	10\n11\n12	613	33	1
6001	11\n12\n13	613	36	2
6002	12\n13\n14	613	39	3
6003	13\n14\n15	613	42	4
6004	14\n15\n16	613	45	5
6005	15\n16\n17	613	48	6
6006	16\n17\n18	613	51	7
6007	17\n18\n19	613	54	8
6008	18\n19\n20	613	57	9
6009	19\n20\n21	613	60	10
6010	11\n12\n13	614	36	1
6011	12\n13\n14	614	39	2
6012	13\n14\n15	614	42	3
6013	14\n15\n16	614	45	4
6014	15\n16\n17	614	48	5
6015	16\n17\n18	614	51	6
6016	17\n18\n19	614	54	7
6017	18\n19\n20	614	57	8
6018	19\n20\n21	614	60	9
6019	20\n21\n22	614	63	10
6020	12\n13\n14	615	39	1
6021	13\n14\n15	615	42	2
6022	14\n15\n16	615	45	3
6023	15\n16\n17	615	48	4
6024	16\n17\n18	615	51	5
6025	17\n18\n19	615	54	6
6026	18\n19\n20	615	57	7
6027	19\n20\n21	615	60	8
6028	20\n21\n22	615	63	9
6029	21\n22\n23	615	66	10
6030	13\n14\n15	616	42	1
6031	14\n15\n16	616	45	2
6032	15\n16\n17	616	48	3
6033	16\n17\n18	616	51	4
6034	17\n18\n19	616	54	5
6035	18\n19\n20	616	57	6
6036	19\n20\n21	616	60	7
6037	20\n21\n22	616	63	8
6038	21\n22\n23	616	66	9
6039	22\n23\n24	616	69	10
6040	14\n15\n16	617	45	1
6041	15\n16\n17	617	48	2
6043	17\n18\n19	617	54	4
6044	18\n19\n20	617	57	5
6045	19\n20\n21	617	60	6
6046	20\n21\n22	617	63	7
6047	21\n22\n23	617	66	8
6048	22\n23\n24	617	69	9
6049	23\n24\n25	617	72	10
6050	15\n16\n17	618	48	1
6051	16\n17\n18	618	51	2
6052	17\n18\n19	618	54	3
6053	18\n19\n20	618	57	4
6054	19\n20\n21	618	60	5
6055	20\n21\n22	618	63	6
6056	21\n22\n23	618	66	7
6057	22\n23\n24	618	69	8
6058	23\n24\n25	618	72	9
6059	24\n25\n26	618	75	10
6060	16\n17\n18	619	51	1
6061	17\n18\n19	619	54	2
6062	18\n19\n20	619	57	3
6063	19\n20\n21	619	60	4
6064	20\n21\n22	619	63	5
6065	21\n22\n23	619	66	6
6066	22\n23\n24	619	69	7
6067	23\n24\n25	619	72	8
6068	24\n25\n26	619	75	9
6069	25\n26\n27	619	78	10
6070	17\n18\n19	620	54	1
6071	18\n19\n20	620	57	2
6072	19\n20\n21	620	60	3
6073	20\n21\n22	620	63	4
6074	21\n22\n23	620	66	5
6075	22\n23\n24	620	69	6
6076	23\n24\n25	620	72	7
6077	24\n25\n26	620	75	8
6078	25\n26\n27	620	78	9
6079	26\n27\n28	620	81	10
6080	18\n19\n20	621	57	1
6081	19\n20\n21	621	60	2
6082	20\n21\n22	621	63	3
6083	21\n22\n23	621	66	4
6084	22\n23\n24	621	69	5
6085	23\n24\n25	621	72	6
6086	24\n25\n26	621	75	7
6087	25\n26\n27	621	78	8
6088	26\n27\n28	621	81	9
6089	27\n28\n29	621	84	10
6090	19\n20\n21	622	60	1
6091	20\n21\n22	622	63	2
6092	21\n22\n23	622	66	3
6093	22\n23\n24	622	69	4
6094	23\n24\n25	622	72	5
6095	24\n25\n26	622	75	6
6096	25\n26\n27	622	78	7
6097	26\n27\n28	622	81	8
6098	27\n28\n29	622	84	9
6099	28\n29\n30	622	87	10
6108	8\nx10	623	80	9
6109	8\nx11	623	88	10
6110	8\nx3	624	24	1
6111	8\nx4	624	32	2
6112	8\nx5	624	40	3
6113	8\nx6	624	48	4
6114	8\nx7	624	56	5
6115	8\nx8	624	64	6
6100	8\nx2	623	16	1
6101	8\nx3	623	24	2
6102	8\nx4	623	32	3
6103	8\nx5	623	40	4
6104	8\nx6	623	48	5
6105	8\nx7	623	56	6
6106	8\nx8	623	64	7
6107	8\nx9	623	72	8
6116	8\nx9	624	72	7
6117	8\nx10	624	80	8
6118	8\nx11	624	88	9
6119	8\nx12	624	96	10
6120	8\nx4	625	32	1
6121	8\nx5	625	40	2
6122	8\nx6	625	48	3
6123	8\nx7	625	56	4
6124	8\nx8	625	64	5
6125	8\nx9	625	72	6
6147	8\nx13	627	104	8
4422	12\n13\n14	455	39	3
6148	8\nx14	627	112	9
6149	8\nx15	627	120	10
6150	8\nx7	628	56	1
6151	8\nx8	628	64	2
6152	8\nx9	628	72	3
6153	8\nx10	628	80	4
6154	8\nx11	628	88	5
6155	8\nx12	628	96	6
6156	8\nx13	628	104	7
6179	8\nx18	630	144	10
6180	8\nx10	631	80	1
6181	8\nx11	631	88	2
6130	8\nx5	626	40	1
6157	8\nx14	628	112	8
6158	8\nx15	628	120	9
6159	8\nx16	628	128	10
6160	8\nx8	629	64	1
6161	8\nx9	629	72	2
6162	8\nx10	629	80	3
6163	8\nx11	629	88	4
6164	8\nx12	629	96	5
6165	8\nx13	629	104	6
6166	8\nx14	629	112	7
6167	8\nx15	629	120	8
6168	8\nx16	629	128	9
6169	8\nx17	629	136	10
6170	8\nx9	630	72	1
6171	8\nx10	630	80	2
6172	8\nx11	630	88	3
6173	8\nx12	630	96	4
6174	8\nx13	630	104	5
6175	8\nx14	630	112	6
6176	8\nx15	630	120	7
6177	8\nx16	630	128	8
6178	8\nx17	630	136	9
6131	8\nx6	626	48	2
6132	8\nx7	626	56	3
6182	8\nx12	631	96	3
6183	8\nx13	631	104	4
6184	8\nx14	631	112	5
6185	8\nx15	631	120	6
6186	8\nx16	631	128	7
6187	8\nx17	631	136	8
6188	8\nx18	631	144	9
6189	8\nx19	631	152	10
6190	8\nx11	632	88	1
6191	8\nx12	632	96	2
6192	8\nx13	632	104	3
6193	8\nx14	632	112	4
6194	8\nx15	632	120	5
6195	8\nx16	632	128	6
6196	8\nx17	632	136	7
6197	8\nx18	632	144	8
6198	8\nx19	632	152	9
6199	8\nx20	632	160	10
6200	8\nx2	633	16	1
6127	8\nx11	625	88	8
6128	8\nx12	625	96	9
6129	8\nx13	625	104	10
6133	8\nx8	626	64	4
6134	8\nx9	626	72	5
6135	8\nx10	626	80	6
6136	8\nx11	626	88	7
6137	8\nx12	626	96	8
6138	8\nx13	626	104	9
6139	8\nx14	626	112	10
6140	8\nx6	627	48	1
6141	8\nx7	627	56	2
6142	8\nx8	627	64	3
6143	8\nx9	627	72	4
6144	8\nx10	627	80	5
6145	8\nx11	627	88	6
6146	8\nx12	627	96	7
6251	8\nx8	638	64	2
6252	8\nx9	638	72	3
6253	8\nx10	638	80	4
6254	8\nx11	638	88	5
6255	8\nx12	638	96	6
6256	8\nx13	638	104	7
6257	8\nx14	638	112	8
6258	8\nx15	638	120	9
6259	8\nx16	638	128	10
6275	8\nx14	640	112	6
6276	8\nx15	640	120	7
6277	8\nx16	640	128	8
6278	8\nx17	640	136	9
6279	8\nx18	640	144	10
6280	8\nx10	641	80	1
6281	8\nx11	641	88	2
6202	8\nx4	633	32	3
6203	8\nx5	633	40	4
6204	8\nx6	633	48	5
6205	8\nx7	633	56	6
6206	8\nx8	633	64	7
6207	8\nx9	633	72	8
6208	8\nx10	633	80	9
6274	8\nx13	640	104	5
6231	8\nx6	636	48	2
6209	8\nx11	633	88	10
6210	8\nx3	634	24	1
6211	8\nx4	634	32	2
6212	8\nx5	634	40	3
6213	8\nx6	634	48	4
6214	8\nx7	634	56	5
6215	8\nx8	634	64	6
6216	8\nx9	634	72	7
6217	8\nx10	634	80	8
6218	8\nx11	634	88	9
6219	8\nx12	634	96	10
6220	8\nx4	635	32	1
6221	8\nx5	635	40	2
6222	8\nx6	635	48	3
6223	8\nx7	635	56	4
6224	8\nx8	635	64	5
6225	8\nx9	635	72	6
6226	8\nx10	635	80	7
6227	8\nx11	635	88	8
6228	8\nx12	635	96	9
6229	8\nx13	635	104	10
6230	8\nx5	636	40	1
6260	8\nx8	639	64	1
6261	8\nx9	639	72	2
6262	8\nx10	639	80	3
6263	8\nx11	639	88	4
6264	8\nx12	639	96	5
6265	8\nx13	639	104	6
6266	8\nx14	639	112	7
6267	8\nx15	639	120	8
6268	8\nx16	639	128	9
6269	8\nx17	639	136	10
6270	8\nx9	640	72	1
6271	8\nx10	640	80	2
6272	8\nx11	640	88	3
6273	8\nx12	640	96	4
6232	8\nx7	636	56	3
6233	8\nx8	636	64	4
6234	8\nx9	636	72	5
6235	8\nx10	636	80	6
6236	8\nx11	636	88	7
6237	8\nx12	636	96	8
6238	8\nx13	636	104	9
6239	8\nx14	636	112	10
6240	8\nx6	637	48	1
6241	8\nx7	637	56	2
6242	8\nx8	637	64	3
6243	8\nx9	637	72	4
6244	8\nx10	637	80	5
6245	8\nx11	637	88	6
6246	8\nx12	637	96	7
6247	8\nx13	637	104	8
6248	8\nx14	637	112	9
6249	8\nx15	637	120	10
6250	8\nx7	638	56	1
6354	88\n/8	648	11	5
6355	96\n/8	648	12	6
6356	104\n/8	648	13	7
6357	112\n/8	648	14	8
6358	120\n/8	648	15	9
6359	128\n/8	648	16	10
6360	64\n/8	649	8	1
6361	72\n/8	649	9	2
6297	8\nx18	642	144	8
6298	8\nx19	642	152	9
6299	8\nx20	642	160	10
6327	88\n/8	645	11	8
6328	96\n/8	645	12	9
6329	104\n/8	645	13	10
6330	40\n/8	646	5	1
6331	48\n/8	646	6	2
6332	56\n/8	646	7	3
6333	64\n/8	646	8	4
6334	72\n/8	646	9	5
6335	80\n/8	646	10	6
6336	88\n/8	646	11	7
6337	96\n/8	646	12	8
6338	104\n/8	646	13	9
6339	112\n/8	646	14	10
6290	8\nx11	642	88	1
6340	48\n/8	647	6	1
6341	56\n/8	647	7	2
6342	64\n/8	647	8	3
6343	72\n/8	647	9	4
6344	80\n/8	647	10	5
6345	88\n/8	647	11	6
6346	96\n/8	647	12	7
6347	104\n/8	647	13	8
6348	112\n/8	647	14	9
6349	120\n/8	647	15	10
6350	56\n/8	648	7	1
6351	64\n/8	648	8	2
6352	72\n/8	648	9	3
6353	80\n/8	648	10	4
6300	16\n/8	643	2	1
6301	24\n/8	643	3	2
6302	32\n/8	643	4	3
6303	40\n/8	643	5	4
6304	48\n/8	643	6	5
4509	6\nx11	463	66	10
6283	8\nx13	641	104	4
6284	8\nx14	641	112	5
6285	8\nx15	641	120	6
6286	8\nx16	641	128	7
6287	8\nx17	641	136	8
6288	8\nx18	641	144	9
6289	8\nx19	641	152	10
6291	8\nx12	642	96	2
6292	8\nx13	642	104	3
6293	8\nx14	642	112	4
6294	8\nx15	642	120	5
6295	8\nx16	642	128	6
6296	8\nx17	642	136	7
6305	56\n/8	643	7	6
6306	64\n/8	643	8	7
6307	72\n/8	643	9	8
6308	80\n/8	643	10	9
6309	88\n/8	643	11	10
6310	24\n/8	644	3	1
6311	32\n/8	644	4	2
6312	40\n/8	644	5	3
6313	48\n/8	644	6	4
6314	56\n/8	644	7	5
6315	64\n/8	644	8	6
6316	72\n/8	644	9	7
6317	80\n/8	644	10	8
6318	88\n/8	644	11	9
6319	96\n/8	644	12	10
6320	32\n/8	645	4	1
6321	40\n/8	645	5	2
6322	48\n/8	645	6	3
6323	56\n/8	645	7	4
6324	64\n/8	645	8	5
6325	72\n/8	645	9	6
6326	80\n/8	645	10	7
6419	96\n/8	654	12	10
6420	32\n/8	655	4	1
6421	40\n/8	655	5	2
6422	48\n/8	655	6	3
6423	56\n/8	655	7	4
6424	64\n/8	655	8	5
6425	72\n/8	655	9	6
6426	80\n/8	655	10	7
6427	88\n/8	655	11	8
6428	96\n/8	655	12	9
4584	6\nx14	471	84	5
6389	152\n/8	651	19	10
6390	88\n/8	652	11	1
6391	96\n/8	652	12	2
6392	104\n/8	652	13	3
6393	112\n/8	652	14	4
6394	120\n/8	652	15	5
6395	128\n/8	652	16	6
6396	136\n/8	652	17	7
6397	144\n/8	652	18	8
6398	152\n/8	652	19	9
6399	160\n/8	652	20	10
6400	16\n/8	653	2	1
6401	24\n/8	653	3	2
6402	32\n/8	653	4	3
6403	40\n/8	653	5	4
6411	32\n/8	654	4	2
6404	48\n/8	653	6	5
6405	56\n/8	653	7	6
6406	64\n/8	653	8	7
6407	72\n/8	653	9	8
6408	80\n/8	653	10	9
6409	88\n/8	653	11	10
6410	24\n/8	654	3	1
6367	120\n/8	649	15	8
6368	128\n/8	649	16	9
6369	136\n/8	649	17	10
6370	72\n/8	650	9	1
6371	80\n/8	650	10	2
6372	88\n/8	650	11	3
6373	96\n/8	650	12	4
6374	104\n/8	650	13	5
6375	112\n/8	650	14	6
6376	120\n/8	650	15	7
6377	128\n/8	650	16	8
6378	136\n/8	650	17	9
6379	144\n/8	650	18	10
6380	80\n/8	651	10	1
6381	88\n/8	651	11	2
6382	96\n/8	651	12	3
6383	104\n/8	651	13	4
6384	112\n/8	651	14	5
6385	120\n/8	651	15	6
6386	128\n/8	651	16	7
6412	40\n/8	654	5	3
6413	48\n/8	654	6	4
6414	56\n/8	654	7	5
6429	104\n/8	655	13	10
6430	40\n/8	656	5	1
6431	48\n/8	656	6	2
6432	56\n/8	656	7	3
6433	64\n/8	656	8	4
6434	72\n/8	656	9	5
6435	80\n/8	656	10	6
6436	88\n/8	656	11	7
6437	96\n/8	656	12	8
6438	104\n/8	656	13	9
6439	112\n/8	656	14	10
6440	48\n/8	657	6	1
6441	56\n/8	657	7	2
6442	64\n/8	657	8	3
6363	88\n/8	649	11	4
6364	96\n/8	649	12	5
6365	104\n/8	649	13	6
6366	112\n/8	649	14	7
6387	136\n/8	651	17	8
6388	144\n/8	651	18	9
6415	64\n/8	654	8	6
6416	72\n/8	654	9	7
6417	80\n/8	654	10	8
6418	88\n/8	654	11	9
6453	80\n/8	658	10	4
6454	88\n/8	658	11	5
6455	96\n/8	658	12	6
6456	104\n/8	658	13	7
6457	112\n/8	658	14	8
6458	120\n/8	658	15	9
6459	128\n/8	658	16	10
6460	64\n/8	659	8	1
6461	72\n/8	659	9	2
6462	80\n/8	659	10	3
6463	88\n/8	659	11	4
6464	96\n/8	659	12	5
6465	104\n/8	659	13	6
6466	112\n/8	659	14	7
6467	120\n/8	659	15	8
6468	128\n/8	659	16	9
6500	11\n+1	663	12	1
6501	12\n+2	663	14	2
6502	13\n+3	663	16	3
6503	14\n+4	663	18	4
6504	15\n+5	663	20	5
6505	16\n+6	663	22	6
6506	17\n+7	663	24	7
6507	18\n+8	663	26	8
6508	19\n+9	663	28	9
6509	20\n+10	663	30	10
6510	12\n+1	664	13	1
6481	88\n/8	661	11	2
6511	13\n+2	664	15	2
6512	14\n+3	664	17	3
6513	15\n+4	664	19	4
6514	16\n+5	664	21	5
6515	17\n+6	664	23	6
6516	18\n+7	664	25	7
6517	19\n+8	664	27	8
6518	20\n+9	664	29	9
6519	21\n+10	664	31	10
6520	13\n+1	665	14	1
6521	14\n+2	665	16	2
6522	15\n+3	665	18	3
6523	16\n+4	665	20	4
6470	72\n/8	660	9	1
6482	96\n/8	661	12	3
6483	104\n/8	661	13	4
6484	112\n/8	661	14	5
6485	120\n/8	661	15	6
6486	128\n/8	661	16	7
6487	136\n/8	661	17	8
6488	144\n/8	661	18	9
6489	152\n/8	661	19	10
6490	88\n/8	662	11	1
6491	96\n/8	662	12	2
6497	144\n/8	662	18	8
6498	152\n/8	662	19	9
6471	80\n/8	660	10	2
6472	88\n/8	660	11	3
6473	96\n/8	660	12	4
6474	104\n/8	660	13	5
6475	112\n/8	660	14	6
6476	120\n/8	660	15	7
6477	128\n/8	660	16	8
6478	136\n/8	660	17	9
6479	144\n/8	660	18	10
6480	80\n/8	661	10	1
6469	136\n/8	659	17	10
6496	136\n/8	662	17	7
6499	160\n/8	662	20	10
6492	104\n/8	662	13	3
6493	112\n/8	662	14	4
6494	120\n/8	662	15	5
6495	128\n/8	662	16	6
4743	54\n/6	487	9	4
6444	80\n/8	657	10	5
6445	88\n/8	657	11	6
6446	96\n/8	657	12	7
6447	104\n/8	657	13	8
6448	112\n/8	657	14	9
6449	120\n/8	657	15	10
6450	56\n/8	658	7	1
6451	64\n/8	658	8	2
6452	72\n/8	658	9	3
6553	19\n+4	668	23	4
6554	20\n+5	668	25	5
6555	21\n+6	668	27	6
6556	22\n+7	668	29	7
6557	23\n+8	668	31	8
6558	24\n+9	668	33	9
6559	25\n+10	668	35	10
6560	17\n+1	669	18	1
6561	18\n+2	669	20	2
6562	19\n+3	669	22	3
6563	20\n+4	669	24	4
6564	21\n+5	669	26	5
6565	22\n+6	669	28	6
6566	23\n+7	669	30	7
6567	24\n+8	669	32	8
6568	25\n+9	669	34	9
6569	26\n+10	669	36	10
6570	18\n+1	670	19	1
6571	19\n+2	670	21	2
6572	20\n+3	670	23	3
6573	21\n+4	670	25	4
6574	22\n+5	670	27	5
6575	23\n+6	670	29	6
6576	24\n+7	670	31	7
6577	25\n+8	670	33	8
6578	26\n+9	670	35	9
6579	27\n+10	670	37	10
6525	18\n+6	665	24	6
6580	19\n+1	671	20	1
6581	20\n+2	671	22	2
6582	21\n+3	671	24	3
6583	22\n+4	671	26	4
6584	23\n+5	671	28	5
6585	24\n+6	671	30	6
6586	25\n+7	671	32	7
6587	26\n+8	671	34	8
6588	27\n+9	671	36	9
6589	28\n+10	671	38	10
6590	20\n+1	672	21	1
6591	21\n+2	672	23	2
6592	22\n+3	672	25	3
6593	23\n+4	672	27	4
6594	24\n+5	672	29	5
6595	25\n+6	672	31	6
6596	26\n+7	672	33	7
6597	27\n+8	672	35	8
6598	28\n+9	672	37	9
6599	29\n+10	672	39	10
6600	11\n+1	673	12	1
6601	12\n+2	673	14	2
6602	13\n+3	673	16	3
6603	14\n+4	673	18	4
6604	15\n+5	673	20	5
4824	48\n/6	495	8	5
6526	19\n+7	665	26	7
6527	20\n+8	665	28	8
6528	21\n+9	665	30	9
6529	22\n+10	665	32	10
6530	14\n+1	666	15	1
6531	15\n+2	666	17	2
6532	16\n+3	666	19	3
6533	17\n+4	666	21	4
6534	18\n+5	666	23	5
6535	19\n+6	666	25	6
6536	20\n+7	666	27	7
6537	21\n+8	666	29	8
6538	22\n+9	666	31	9
6539	23\n+10	666	33	10
6540	15\n+1	667	16	1
6541	16\n+2	667	18	2
6542	17\n+3	667	20	3
6543	18\n+4	667	22	4
6544	19\n+5	667	24	5
6545	20\n+6	667	26	6
6546	21\n+7	667	28	7
6547	22\n+8	667	30	8
6548	23\n+9	667	32	9
6549	24\n+10	667	34	10
6550	16\n+1	668	17	1
6551	17\n+2	668	19	2
6552	18\n+3	668	21	3
6634	18\n+5	676	23	5
6635	19\n+6	676	25	6
6636	20\n+7	676	27	7
6637	21\n+8	676	29	8
6638	22\n+9	676	31	9
6639	23\n+10	676	33	10
6640	15\n+1	677	16	1
6641	16\n+2	677	18	2
6642	17\n+3	677	20	3
6643	18\n+4	677	22	4
6644	19\n+5	677	24	5
6645	20\n+6	677	26	6
6646	21\n+7	677	28	7
6647	22\n+8	677	30	8
6648	23\n+9	677	32	9
6649	24\n+10	677	34	10
6650	16\n+1	678	17	1
6651	17\n+2	678	19	2
6652	18\n+3	678	21	3
6653	19\n+4	678	23	4
6654	20\n+5	678	25	5
6655	21\n+6	678	27	6
6656	22\n+7	678	29	7
6657	23\n+8	678	31	8
6658	24\n+9	678	33	9
6659	25\n+10	678	35	10
4905	14\n+6	503	20	6
6660	17\n+1	679	18	1
6661	18\n+2	679	20	2
6662	19\n+3	679	22	3
6663	20\n+4	679	24	4
6664	21\n+5	679	26	5
6665	22\n+6	679	28	6
6666	23\n+7	679	30	7
6667	24\n+8	679	32	8
6668	25\n+9	679	34	9
6669	26\n+10	679	36	10
6670	18\n+1	680	19	1
6671	19\n+2	680	21	2
6672	20\n+3	680	23	3
6673	21\n+4	680	25	4
6674	22\n+5	680	27	5
6675	23\n+6	680	29	6
6676	24\n+7	680	31	7
6677	25\n+8	680	33	8
6678	26\n+9	680	35	9
6679	27\n+10	680	37	10
6680	19\n+1	681	20	1
6681	20\n+2	681	22	2
6682	21\n+3	681	24	3
6683	22\n+4	681	26	4
6684	23\n+5	681	28	5
6685	24\n+6	681	30	6
6606	17\n+7	673	24	7
6607	18\n+8	673	26	8
6608	19\n+9	673	28	9
6609	20\n+10	673	30	10
6610	12\n+1	674	13	1
6611	13\n+2	674	15	2
6612	14\n+3	674	17	3
6613	15\n+4	674	19	4
6614	16\n+5	674	21	5
6615	17\n+6	674	23	6
6616	18\n+7	674	25	7
6617	19\n+8	674	27	8
6618	20\n+9	674	29	9
6619	21\n+10	674	31	10
6620	13\n+1	675	14	1
6621	14\n+2	675	16	2
6622	15\n+3	675	18	3
6623	16\n+4	675	20	4
6624	17\n+5	675	22	5
6625	18\n+6	675	24	6
6626	19\n+7	675	26	7
6627	20\n+8	675	28	8
6628	21\n+9	675	30	9
6629	22\n+10	675	32	10
6630	14\n+1	676	15	1
6631	15\n+2	676	17	2
6632	16\n+3	676	19	3
6633	17\n+4	676	21	4
6715	17\n+6	684	23	6
6716	18\n+7	684	25	7
6717	19\n+8	684	27	8
6718	20\n+9	684	29	9
6719	21\n+10	684	31	10
6720	13\n+1	685	14	1
6721	14\n+2	685	16	2
6722	15\n+3	685	18	3
6723	16\n+4	685	20	4
6724	17\n+5	685	22	5
6725	18\n+6	685	24	6
6726	19\n+7	685	26	7
6727	20\n+8	685	28	8
6728	21\n+9	685	30	9
6729	22\n+10	685	32	10
6730	14\n+1	686	15	1
6731	15\n+2	686	17	2
6732	16\n+3	686	19	3
6733	17\n+4	686	21	4
6734	18\n+5	686	23	5
6735	19\n+6	686	25	6
6736	20\n+7	686	27	7
6737	21\n+8	686	29	8
6738	22\n+9	686	31	9
6739	23\n+10	686	33	10
6740	15\n+1	687	16	1
4986	23\n+7	511	30	7
6741	16\n+2	687	18	2
6742	17\n+3	687	20	3
6743	18\n+4	687	22	4
6744	19\n+5	687	24	5
6745	20\n+6	687	26	6
6746	21\n+7	687	28	7
6747	22\n+8	687	30	8
6748	23\n+9	687	32	9
6749	24\n+10	687	34	10
6750	16\n+1	688	17	1
6751	17\n+2	688	19	2
6752	18\n+3	688	21	3
6753	19\n+4	688	23	4
6754	20\n+5	688	25	5
6755	21\n+6	688	27	6
6756	22\n+7	688	29	7
6757	23\n+8	688	31	8
6758	24\n+9	688	33	9
6759	25\n+10	688	35	10
6760	17\n+1	689	18	1
6761	18\n+2	689	20	2
6762	19\n+3	689	22	3
6763	20\n+4	689	24	4
6764	21\n+5	689	26	5
6765	22\n+6	689	28	6
6766	23\n+7	689	30	7
6687	26\n+8	681	34	8
6688	27\n+9	681	36	9
6689	28\n+10	681	38	10
6690	20\n+1	682	21	1
6691	21\n+2	682	23	2
6692	22\n+3	682	25	3
6693	23\n+4	682	27	4
6694	24\n+5	682	29	5
6695	25\n+6	682	31	6
6696	26\n+7	682	33	7
6697	27\n+8	682	35	8
6698	28\n+9	682	37	9
6699	29\n+10	682	39	10
6700	11\n+1	683	12	1
6701	12\n+2	683	14	2
6702	13\n+3	683	16	3
6703	14\n+4	683	18	4
6704	15\n+5	683	20	5
6705	16\n+6	683	22	6
6706	17\n+7	683	24	7
6707	18\n+8	683	26	8
6708	19\n+9	683	28	9
6709	20\n+10	683	30	10
6710	12\n+1	684	13	1
6711	13\n+2	684	15	2
6712	14\n+3	684	17	3
6713	15\n+4	684	19	4
6714	16\n+5	684	21	5
5067	22\n+8	519	30	8
6768	25\n+9	689	34	9
6769	26\n+10	689	36	10
6770	18\n+1	690	19	1
6771	19\n+2	690	21	2
6772	20\n+3	690	23	3
6773	21\n+4	690	25	4
6774	22\n+5	690	27	5
6775	23\n+6	690	29	6
6776	24\n+7	690	31	7
6777	25\n+8	690	33	8
6778	26\n+9	690	35	9
6779	27\n+10	690	37	10
6780	19\n+1	691	20	1
6781	20\n+2	691	22	2
6782	21\n+3	691	24	3
6783	22\n+4	691	26	4
6784	23\n+5	691	28	5
6785	24\n+6	691	30	6
6786	25\n+7	691	32	7
6787	26\n+8	691	34	8
6788	27\n+9	691	36	9
6789	28\n+10	691	38	10
6790	20\n+1	692	21	1
6791	21\n+2	692	23	2
6792	22\n+3	692	25	3
6793	23\n+4	692	27	4
6794	24\n+5	692	29	5
6795	25\n+6	692	31	6
6796	26\n+7	692	33	7
6797	27\n+8	692	35	8
6798	28\n+9	692	37	9
6800	11\n12\n13	693	36	1
6801	12\n13\n14	693	39	2
6802	13\n14\n15	693	42	3
6803	14\n15\n16	693	45	4
6804	15\n16\n17	693	48	5
6805	16\n17\n18	693	51	6
6806	17\n18\n19	693	54	7
6807	18\n19\n20	693	57	8
6808	19\n20\n21	693	60	9
6809	20\n21\n22	693	63	10
6810	12\n13\n14	694	39	1
6811	13\n14\n15	694	42	2
6812	14\n15\n16	694	45	3
6813	15\n16\n17	694	48	4
6814	16\n17\n18	694	51	5
6815	17\n18\n19	694	54	6
6816	18\n19\n20	694	57	7
6817	19\n20\n21	694	60	8
6818	20\n21\n22	694	63	9
6819	21\n22\n23	694	66	10
6820	13\n14\n15	695	42	1
6821	14\n15\n16	695	45	2
6822	15\n16\n17	695	48	3
6823	16\n17\n18	695	51	4
6824	17\n18\n19	695	54	5
6825	18\n19\n20	695	57	6
6826	19\n20\n21	695	60	7
6827	20\n21\n22	695	63	8
6828	21\n22\n23	695	66	9
6829	22\n23\n24	695	69	10
6830	14\n15\n16	696	45	1
6831	15\n16\n17	696	48	2
6832	16\n17\n18	696	51	3
6833	17\n18\n19	696	54	4
6834	18\n19\n20	696	57	5
6835	19\n20\n21	696	60	6
6836	20\n21\n22	696	63	7
6837	21\n22\n23	696	66	8
6838	22\n23\n24	696	69	9
6839	23\n24\n25	696	72	10
6840	15\n16\n17	697	48	1
6841	16\n17\n18	697	51	2
6842	17\n18\n19	697	54	3
6843	18\n19\n20	697	57	4
6844	19\n20\n21	697	60	5
6845	20\n21\n22	697	63	6
6846	21\n22\n23	697	66	7
6847	22\n23\n24	697	69	8
6848	23\n24\n25	697	72	9
6849	24\n25\n26	697	75	10
6850	16\n17\n18	698	51	1
6851	17\n18\n19	698	54	2
6799	29\n+10	692	39	10
6853	19\n20\n21	698	60	4
6854	20\n21\n22	698	63	5
6855	21\n22\n23	698	66	6
6856	22\n23\n24	698	69	7
6857	23\n24\n25	698	72	8
6858	24\n25\n26	698	75	9
6859	25\n26\n27	698	78	10
6860	17\n18\n19	699	54	1
6861	18\n19\n20	699	57	2
6862	19\n20\n21	699	60	3
6863	20\n21\n22	699	63	4
6864	21\n22\n23	699	66	5
6865	22\n23\n24	699	69	6
6866	23\n24\n25	699	72	7
6867	24\n25\n26	699	75	8
6868	25\n26\n27	699	78	9
6869	26\n27\n28	699	81	10
6870	18\n19\n20	700	57	1
6871	19\n20\n21	700	60	2
6872	20\n21\n22	700	63	3
6873	21\n22\n23	700	66	4
6874	22\n23\n24	700	69	5
6875	23\n24\n25	700	72	6
6876	24\n25\n26	700	75	7
6877	25\n26\n27	700	78	8
6878	26\n27\n28	700	81	9
6879	27\n28\n29	700	84	10
6880	19\n20\n21	701	60	1
6881	20\n21\n22	701	63	2
6882	21\n22\n23	701	66	3
6883	22\n23\n24	701	69	4
6884	23\n24\n25	701	72	5
6885	24\n25\n26	701	75	6
6886	25\n26\n27	701	78	7
6887	26\n27\n28	701	81	8
6888	27\n28\n29	701	84	9
6889	28\n29\n30	701	87	10
6890	20\n21\n22	702	63	1
6891	21\n22\n23	702	66	2
6892	22\n23\n24	702	69	3
6893	23\n24\n25	702	72	4
6894	24\n25\n26	702	75	5
6895	25\n26\n27	702	78	6
6896	26\n27\n28	702	81	7
6897	27\n28\n29	702	84	8
6898	28\n29\n30	702	87	9
6899	29\n30\n31	702	90	10
5148	21\n+9	527	30	9
6919	9\nx12	704	108	10
6920	9\nx4	705	36	1
6921	9\nx5	705	45	2
6922	9\nx6	705	54	3
6923	9\nx7	705	63	4
6924	9\nx8	705	72	5
6925	9\nx9	705	81	6
6926	9\nx10	705	90	7
6927	9\nx11	705	99	8
6928	9\nx12	705	108	9
6929	9\nx13	705	117	10
6930	9\nx5	706	45	1
6931	9\nx6	706	54	2
6932	9\nx7	706	63	3
6933	9\nx8	706	72	4
6900	9\nx2	703	18	1
6901	9\nx3	703	27	2
6902	9\nx4	703	36	3
6903	9\nx5	703	45	4
6904	9\nx6	703	54	5
6905	9\nx7	703	63	6
6906	9\nx8	703	72	7
6907	9\nx9	703	81	8
6908	9\nx10	703	90	9
6909	9\nx11	703	99	10
6910	9\nx3	704	27	1
6911	9\nx4	704	36	2
6912	9\nx5	704	45	3
6913	9\nx6	704	54	4
6914	9\nx7	704	63	5
6915	9\nx8	704	72	6
6916	9\nx9	704	81	7
6917	9\nx10	704	90	8
6918	9\nx11	704	99	9
6954	9\nx11	708	99	5
6955	9\nx12	708	108	6
6956	9\nx13	708	117	7
6957	9\nx14	708	126	8
6958	9\nx15	708	135	9
6959	9\nx16	708	144	10
6960	9\nx8	709	72	1
6961	9\nx9	709	81	2
6962	9\nx10	709	90	3
6963	9\nx11	709	99	4
6986	9\nx16	711	144	7
6987	9\nx17	711	153	8
6988	9\nx18	711	162	9
6989	9\nx19	711	171	10
6937	9\nx12	706	108	8
6964	9\nx12	709	108	5
6965	9\nx13	709	117	6
6966	9\nx14	709	126	7
6967	9\nx15	709	135	8
6968	9\nx16	709	144	9
6969	9\nx17	709	153	10
6970	9\nx9	710	81	1
6971	9\nx10	710	90	2
6972	9\nx11	710	99	3
6973	9\nx12	710	108	4
6974	9\nx13	710	117	5
6975	9\nx14	710	126	6
6976	9\nx15	710	135	7
6977	9\nx16	710	144	8
6978	9\nx17	710	153	9
6979	9\nx18	710	162	10
6980	9\nx10	711	90	1
6981	9\nx11	711	99	2
6982	9\nx12	711	108	3
6983	9\nx13	711	117	4
6984	9\nx14	711	126	5
6985	9\nx15	711	135	6
6938	9\nx13	706	117	9
6990	9\nx11	712	99	1
6991	9\nx12	712	108	2
6992	9\nx13	712	117	3
6993	9\nx14	712	126	4
6994	9\nx15	712	135	5
6995	9\nx16	712	144	6
6996	9\nx17	712	153	7
6997	9\nx18	712	162	8
6998	9\nx19	712	171	9
6999	9\nx20	712	180	10
7000	9\nx2	713	18	1
7001	9\nx3	713	27	2
7002	9\nx4	713	36	3
7003	9\nx5	713	45	4
7004	9\nx6	713	54	5
7005	9\nx7	713	63	6
7006	9\nx8	713	72	7
7007	9\nx9	713	81	8
7008	9\nx10	713	90	9
7009	9\nx11	713	99	10
6935	9\nx10	706	90	6
6936	9\nx11	706	99	7
6939	9\nx14	706	126	10
6940	9\nx6	707	54	1
6941	9\nx7	707	63	2
6942	9\nx8	707	72	3
6943	9\nx9	707	81	4
6944	9\nx10	707	90	5
6945	9\nx11	707	99	6
6946	9\nx12	707	108	7
6947	9\nx13	707	117	8
6948	9\nx14	707	126	9
6949	9\nx15	707	135	10
6950	9\nx7	708	63	1
6951	9\nx8	708	72	2
6952	9\nx9	708	81	3
6953	9\nx10	708	90	4
7059	9\nx16	718	144	10
7060	9\nx8	719	72	1
7061	9\nx9	719	81	2
7062	9\nx10	719	90	3
7063	9\nx11	719	99	4
7064	9\nx12	719	108	5
7065	9\nx13	719	117	6
7066	9\nx14	719	126	7
7083	9\nx13	721	117	4
7084	9\nx14	721	126	5
7085	9\nx15	721	135	6
7086	9\nx16	721	144	7
7087	9\nx17	721	153	8
7088	9\nx18	721	162	9
7089	9\nx19	721	171	10
7170	81\n/9	730	9	1
7067	9\nx15	719	135	8
7011	9\nx4	714	36	2
7012	9\nx5	714	45	3
7013	9\nx6	714	54	4
7014	9\nx7	714	63	5
7015	9\nx8	714	72	6
7016	9\nx9	714	81	7
7082	9\nx12	721	108	3
7039	9\nx14	716	126	10
7017	9\nx10	714	90	8
7018	9\nx11	714	99	9
7019	9\nx12	714	108	10
7020	9\nx4	715	36	1
7021	9\nx5	715	45	2
7022	9\nx6	715	54	3
7023	9\nx7	715	63	4
7024	9\nx8	715	72	5
7025	9\nx9	715	81	6
7026	9\nx10	715	90	7
7027	9\nx11	715	99	8
7028	9\nx12	715	108	9
7029	9\nx13	715	117	10
7030	9\nx5	716	45	1
7031	9\nx6	716	54	2
7032	9\nx7	716	63	3
7033	9\nx8	716	72	4
7034	9\nx9	716	81	5
7035	9\nx10	716	90	6
7036	9\nx11	716	99	7
7037	9\nx12	716	108	8
7038	9\nx13	716	117	9
7068	9\nx16	719	144	9
7069	9\nx17	719	153	10
7070	9\nx9	720	81	1
7071	9\nx10	720	90	2
7072	9\nx11	720	99	3
7073	9\nx12	720	108	4
7074	9\nx13	720	117	5
7075	9\nx14	720	126	6
7076	9\nx15	720	135	7
7077	9\nx16	720	144	8
7078	9\nx17	720	153	9
7079	9\nx18	720	162	10
7080	9\nx10	721	90	1
7081	9\nx11	721	99	2
7040	9\nx6	717	54	1
7041	9\nx7	717	63	2
7042	9\nx8	717	72	3
7043	9\nx9	717	81	4
7044	9\nx10	717	90	5
7045	9\nx11	717	99	6
7046	9\nx12	717	108	7
7047	9\nx13	717	117	8
7048	9\nx14	717	126	9
7049	9\nx15	717	135	10
7050	9\nx7	718	63	1
7051	9\nx8	718	72	2
7052	9\nx9	718	81	3
7053	9\nx10	718	90	4
7054	9\nx11	718	99	5
7055	9\nx12	718	108	6
7056	9\nx13	718	117	7
7057	9\nx14	718	126	8
7058	9\nx15	718	135	9
7160	72\n/9	729	8	1
5232	14\n15\n16	536	45	3
7161	81\n/9	729	9	2
7162	90\n/9	729	10	3
7163	99\n/9	729	11	4
7164	108\n/9	729	12	5
7165	117\n/9	729	13	6
7091	9\nx12	722	108	2
7092	9\nx13	722	117	3
7093	9\nx14	722	126	4
7094	9\nx15	722	135	5
7095	9\nx16	722	144	6
7096	9\nx17	722	153	7
7097	9\nx18	722	162	8
7098	9\nx19	722	171	9
7099	9\nx20	722	180	10
7127	99\n/9	725	11	8
7128	108\n/9	725	12	9
7129	117\n/9	725	13	10
7130	45\n/9	726	5	1
7131	54\n/9	726	6	2
7132	63\n/9	726	7	3
7133	72\n/9	726	8	4
7134	81\n/9	726	9	5
7102	36\n/9	723	4	3
7135	90\n/9	726	10	6
7136	99\n/9	726	11	7
7137	108\n/9	726	12	8
7138	117\n/9	726	13	9
7139	126\n/9	726	14	10
7140	54\n/9	727	6	1
7141	63\n/9	727	7	2
7142	72\n/9	727	8	3
7143	81\n/9	727	9	4
7144	90\n/9	727	10	5
7145	99\n/9	727	11	6
7146	108\n/9	727	12	7
7147	117\n/9	727	13	8
7148	126\n/9	727	14	9
7149	135\n/9	727	15	10
7150	63\n/9	728	7	1
7151	72\n/9	728	8	2
7152	81\n/9	728	9	3
7153	90\n/9	728	10	4
7169	153\n/9	729	17	10
7100	18\n/9	723	2	1
7101	27\n/9	723	3	2
7166	126\n/9	729	14	7
7167	135\n/9	729	15	8
7168	144\n/9	729	16	9
7103	45\n/9	723	5	4
7104	54\n/9	723	6	5
7105	63\n/9	723	7	6
7106	72\n/9	723	8	7
7107	81\n/9	723	9	8
7108	90\n/9	723	10	9
7109	99\n/9	723	11	10
7110	27\n/9	724	3	1
7111	36\n/9	724	4	2
7112	45\n/9	724	5	3
7113	54\n/9	724	6	4
7114	63\n/9	724	7	5
7115	72\n/9	724	8	6
7116	81\n/9	724	9	7
7117	90\n/9	724	10	8
7118	99\n/9	724	11	9
7119	108\n/9	724	12	10
7120	36\n/9	725	4	1
7121	45\n/9	725	5	2
7122	54\n/9	725	6	3
7123	63\n/9	725	7	4
7124	72\n/9	725	8	5
7125	81\n/9	725	9	6
7126	90\n/9	725	10	7
7154	99\n/9	728	11	5
7155	108\n/9	728	12	6
7156	117\n/9	728	13	7
7157	126\n/9	728	14	8
7158	135\n/9	728	15	9
7159	144\n/9	728	16	10
7225	81\n/9	735	9	6
7226	90\n/9	735	10	7
7227	99\n/9	735	11	8
7228	108\n/9	735	12	9
7229	117\n/9	735	13	10
7230	45\n/9	736	5	1
7231	54\n/9	736	6	2
7232	63\n/9	736	7	3
7233	72\n/9	736	8	4
7234	81\n/9	736	9	5
7235	90\n/9	736	10	6
7236	99\n/9	736	11	7
5317	7\nx10	544	70	8
7197	162\n/9	732	18	8
7198	171\n/9	732	19	9
7199	180\n/9	732	20	10
7200	18\n/9	733	2	1
7201	27\n/9	733	3	2
7202	36\n/9	733	4	3
7203	45\n/9	733	5	4
7204	54\n/9	733	6	5
7205	63\n/9	733	7	6
7206	72\n/9	733	8	7
7207	81\n/9	733	9	8
7208	90\n/9	733	10	9
7209	99\n/9	733	11	10
7218	99\n/9	734	11	9
7210	27\n/9	734	3	1
7211	36\n/9	734	4	2
7212	45\n/9	734	5	3
7213	54\n/9	734	6	4
7214	63\n/9	734	7	5
7215	72\n/9	734	8	6
7216	81\n/9	734	9	7
7217	90\n/9	734	10	8
7174	117\n/9	730	13	5
7175	126\n/9	730	14	6
7176	135\n/9	730	15	7
7177	144\n/9	730	16	8
7178	153\n/9	730	17	9
7179	162\n/9	730	18	10
7180	90\n/9	731	10	1
7181	99\n/9	731	11	2
7182	108\n/9	731	12	3
7183	117\n/9	731	13	4
7184	126\n/9	731	14	5
7185	135\n/9	731	15	6
7186	144\n/9	731	16	7
7187	153\n/9	731	17	8
7188	162\n/9	731	18	9
7189	171\n/9	731	19	10
7190	99\n/9	732	11	1
7191	108\n/9	732	12	2
7192	117\n/9	732	13	3
7219	108\n/9	734	12	10
7220	36\n/9	735	4	1
7221	45\n/9	735	5	2
7237	108\n/9	736	12	8
7238	117\n/9	736	13	9
7239	126\n/9	736	14	10
7240	54\n/9	737	6	1
7241	63\n/9	737	7	2
7242	72\n/9	737	8	3
7243	81\n/9	737	9	4
7244	90\n/9	737	10	5
7245	99\n/9	737	11	6
7246	108\n/9	737	12	7
7247	117\n/9	737	13	8
7248	126\n/9	737	14	9
7249	135\n/9	737	15	10
7250	63\n/9	738	7	1
7251	72\n/9	738	8	2
7172	99\n/9	730	11	3
7173	108\n/9	730	12	4
7193	126\n/9	732	14	4
7194	135\n/9	732	15	5
7195	144\n/9	732	16	6
7196	153\n/9	732	17	7
7222	54\n/9	735	6	3
7223	63\n/9	735	7	4
7224	72\n/9	735	8	5
7275	126\n/9	740	14	6
7276	135\n/9	740	15	7
7277	144\n/9	740	16	8
7278	153\n/9	740	17	9
7300	12\n+1	743	13	1
7301	13\n+2	743	15	2
7302	14\n+3	743	17	3
7303	15\n+4	743	19	4
7304	16\n+5	743	21	5
7305	17\n+6	743	23	6
7306	18\n+7	743	25	7
7307	19\n+8	743	27	8
7308	20\n+9	743	29	9
7309	21\n+10	743	31	10
7310	13\n+1	744	14	1
7311	14\n+2	744	16	2
7312	15\n+3	744	18	3
7313	16\n+4	744	20	4
7314	17\n+5	744	22	5
7315	18\n+6	744	24	6
7316	19\n+7	744	26	7
7317	20\n+8	744	28	8
7318	21\n+9	744	30	9
7319	22\n+10	744	32	10
7320	14\n+1	745	15	1
7321	15\n+2	745	17	2
7299	180\n/9	742	20	10
7322	16\n+3	745	19	3
7323	17\n+4	745	21	4
7324	18\n+5	745	23	5
7325	19\n+6	745	25	6
7326	20\n+7	745	27	7
7327	21\n+8	745	29	8
7328	22\n+9	745	31	9
7329	23\n+10	745	33	10
7330	15\n+1	746	16	1
7331	16\n+2	746	18	2
7332	17\n+3	746	20	3
7283	117\n/9	741	13	4
7284	126\n/9	741	14	5
7285	135\n/9	741	15	6
7286	144\n/9	741	16	7
7287	153\n/9	741	17	8
7288	162\n/9	741	18	9
7289	171\n/9	741	19	10
7290	99\n/9	742	11	1
7291	108\n/9	742	12	2
7253	90\n/9	738	10	4
7292	117\n/9	742	13	3
7293	126\n/9	742	14	4
7294	135\n/9	742	15	5
7295	144\n/9	742	16	6
7296	153\n/9	742	17	7
7297	162\n/9	742	18	8
7298	171\n/9	742	19	9
7254	99\n/9	738	11	5
7255	108\n/9	738	12	6
7256	117\n/9	738	13	7
7257	126\n/9	738	14	8
7258	135\n/9	738	15	9
7259	144\n/9	738	16	10
7260	72\n/9	739	8	1
7261	81\n/9	739	9	2
7262	90\n/9	739	10	3
7263	99\n/9	739	11	4
7264	108\n/9	739	12	5
7265	117\n/9	739	13	6
7266	126\n/9	739	14	7
7267	135\n/9	739	15	8
7268	144\n/9	739	16	9
7269	153\n/9	739	17	10
7270	81\n/9	740	9	1
7271	90\n/9	740	10	2
5392	7\nx13	552	91	3
7279	162\n/9	740	18	10
7280	90\n/9	741	10	1
7281	99\n/9	741	11	2
7282	108\n/9	741	12	3
7272	99\n/9	740	11	3
7273	108\n/9	740	12	4
7274	117\n/9	740	13	5
7362	20\n+3	749	23	3
7363	21\n+4	749	25	4
7364	22\n+5	749	27	5
7365	23\n+6	749	29	6
7366	24\n+7	749	31	7
7367	25\n+8	749	33	8
7368	26\n+9	749	35	9
7369	27\n+10	749	37	10
7370	19\n+1	750	20	1
7371	20\n+2	750	22	2
7372	21\n+3	750	24	3
7373	22\n+4	750	26	4
7374	23\n+5	750	28	5
7375	24\n+6	750	30	6
7376	25\n+7	750	32	7
7377	26\n+8	750	34	8
7378	27\n+9	750	36	9
7379	28\n+10	750	38	10
7380	20\n+1	751	21	1
7381	21\n+2	751	23	2
7382	22\n+3	751	25	3
7383	23\n+4	751	27	4
7384	24\n+5	751	29	5
7385	25\n+6	751	31	6
7386	26\n+7	751	33	7
7387	27\n+8	751	35	8
7334	19\n+5	746	24	5
7388	28\n+9	751	37	9
7389	29\n+10	751	39	10
7390	21\n+1	752	22	1
7391	22\n+2	752	24	2
7392	23\n+3	752	26	3
7393	24\n+4	752	28	4
7394	25\n+5	752	30	5
7395	26\n+6	752	32	6
7396	27\n+7	752	34	7
7397	28\n+8	752	36	8
7398	29\n+9	752	38	9
7399	30\n+10	752	40	10
7400	12\n+1	753	13	1
7401	13\n+2	753	15	2
7402	14\n+3	753	17	3
7403	15\n+4	753	19	4
7404	16\n+5	753	21	5
7405	17\n+6	753	23	6
7406	18\n+7	753	25	7
7407	19\n+8	753	27	8
7408	20\n+9	753	29	9
7409	21\n+10	753	31	10
7410	13\n+1	754	14	1
7411	14\n+2	754	16	2
7412	15\n+3	754	18	3
7413	16\n+4	754	20	4
5472	7\nx11	560	77	3
7335	20\n+6	746	26	6
7336	21\n+7	746	28	7
7337	22\n+8	746	30	8
7338	23\n+9	746	32	9
7339	24\n+10	746	34	10
7340	16\n+1	747	17	1
7341	17\n+2	747	19	2
7342	18\n+3	747	21	3
7343	19\n+4	747	23	4
7344	20\n+5	747	25	5
7345	21\n+6	747	27	6
7346	22\n+7	747	29	7
7347	23\n+8	747	31	8
7348	24\n+9	747	33	9
7349	25\n+10	747	35	10
7350	17\n+1	748	18	1
7351	18\n+2	748	20	2
7352	19\n+3	748	22	3
7353	20\n+4	748	24	4
7354	21\n+5	748	26	5
7355	22\n+6	748	28	6
7356	23\n+7	748	30	7
7357	24\n+8	748	32	8
7358	25\n+9	748	34	9
7359	26\n+10	748	36	10
7360	18\n+1	749	19	1
7361	19\n+2	749	21	2
7443	19\n+4	757	23	4
7444	20\n+5	757	25	5
7445	21\n+6	757	27	6
7446	22\n+7	757	29	7
7447	23\n+8	757	31	8
7448	24\n+9	757	33	9
7449	25\n+10	757	35	10
7450	17\n+1	758	18	1
7451	18\n+2	758	20	2
7452	19\n+3	758	22	3
7453	20\n+4	758	24	4
7454	21\n+5	758	26	5
7455	22\n+6	758	28	6
7456	23\n+7	758	30	7
7457	24\n+8	758	32	8
7458	25\n+9	758	34	9
7459	26\n+10	758	36	10
7460	18\n+1	759	19	1
7461	19\n+2	759	21	2
7462	20\n+3	759	23	3
7463	21\n+4	759	25	4
7464	22\n+5	759	27	5
7465	23\n+6	759	29	6
7466	24\n+7	759	31	7
7467	25\n+8	759	33	8
7468	26\n+9	759	35	9
7469	27\n+10	759	37	10
7415	18\n+6	754	24	6
7470	19\n+1	760	20	1
7471	20\n+2	760	22	2
7472	21\n+3	760	24	3
7473	22\n+4	760	26	4
7474	23\n+5	760	28	5
7475	24\n+6	760	30	6
7476	25\n+7	760	32	7
7477	26\n+8	760	34	8
7478	27\n+9	760	36	9
7479	28\n+10	760	38	10
7480	20\n+1	761	21	1
7481	21\n+2	761	23	2
7482	22\n+3	761	25	3
7483	23\n+4	761	27	4
7484	24\n+5	761	29	5
7485	25\n+6	761	31	6
7486	26\n+7	761	33	7
7487	27\n+8	761	35	8
7488	28\n+9	761	37	9
7489	29\n+10	761	39	10
7490	21\n+1	762	22	1
7491	22\n+2	762	24	2
7492	23\n+3	762	26	3
7493	24\n+4	762	28	4
7494	25\n+5	762	30	5
5552	63\n/7	568	9	3
7416	19\n+7	754	26	7
7417	20\n+8	754	28	8
7418	21\n+9	754	30	9
7419	22\n+10	754	32	10
7420	14\n+1	755	15	1
7421	15\n+2	755	17	2
7422	16\n+3	755	19	3
7423	17\n+4	755	21	4
7424	18\n+5	755	23	5
7425	19\n+6	755	25	6
7426	20\n+7	755	27	7
7427	21\n+8	755	29	8
7428	22\n+9	755	31	9
7429	23\n+10	755	33	10
7430	15\n+1	756	16	1
7431	16\n+2	756	18	2
7432	17\n+3	756	20	3
7433	18\n+4	756	22	4
7434	19\n+5	756	24	5
7435	20\n+6	756	26	6
7436	21\n+7	756	28	7
7437	22\n+8	756	30	8
7438	23\n+9	756	32	9
7439	24\n+10	756	34	10
7440	16\n+1	757	17	1
7441	17\n+2	757	19	2
7442	18\n+3	757	21	3
7524	18\n+5	765	23	5
7525	19\n+6	765	25	6
7526	20\n+7	765	27	7
7527	21\n+8	765	29	8
7528	22\n+9	765	31	9
7529	23\n+10	765	33	10
7530	15\n+1	766	16	1
7531	16\n+2	766	18	2
7532	17\n+3	766	20	3
7533	18\n+4	766	22	4
7534	19\n+5	766	24	5
7535	20\n+6	766	26	6
7536	21\n+7	766	28	7
7537	22\n+8	766	30	8
7538	23\n+9	766	32	9
7539	24\n+10	766	34	10
7540	16\n+1	767	17	1
7541	17\n+2	767	19	2
7542	18\n+3	767	21	3
7543	19\n+4	767	23	4
7544	20\n+5	767	25	5
7545	21\n+6	767	27	6
7546	22\n+7	767	29	7
7547	23\n+8	767	31	8
7548	24\n+9	767	33	9
7549	25\n+10	767	35	10
7550	17\n+1	768	18	1
7496	27\n+7	762	34	7
7551	18\n+2	768	20	2
7552	19\n+3	768	22	3
7553	20\n+4	768	24	4
7554	21\n+5	768	26	5
7555	22\n+6	768	28	6
7556	23\n+7	768	30	7
7557	24\n+8	768	32	8
7558	25\n+9	768	34	9
7559	26\n+10	768	36	10
7560	18\n+1	769	19	1
7561	19\n+2	769	21	2
7562	20\n+3	769	23	3
7563	21\n+4	769	25	4
7564	22\n+5	769	27	5
7565	23\n+6	769	29	6
7566	24\n+7	769	31	7
7567	25\n+8	769	33	8
7568	26\n+9	769	35	9
7569	27\n+10	769	37	10
7570	19\n+1	770	20	1
7571	20\n+2	770	22	2
7572	21\n+3	770	24	3
7573	22\n+4	770	26	4
7574	23\n+5	770	28	5
7575	24\n+6	770	30	6
5633	56\n/7	576	8	4
7497	28\n+8	762	36	8
7498	29\n+9	762	38	9
7499	30\n+10	762	40	10
7500	12\n+1	763	13	1
7501	13\n+2	763	15	2
7502	14\n+3	763	17	3
7503	15\n+4	763	19	4
7504	16\n+5	763	21	5
7505	17\n+6	763	23	6
7506	18\n+7	763	25	7
7507	19\n+8	763	27	8
7508	20\n+9	763	29	9
7509	21\n+10	763	31	10
7510	13\n+1	764	14	1
7511	14\n+2	764	16	2
7512	15\n+3	764	18	3
7513	16\n+4	764	20	4
7514	17\n+5	764	22	5
7515	18\n+6	764	24	6
7516	19\n+7	764	26	7
7517	20\n+8	764	28	8
7518	21\n+9	764	30	9
7519	22\n+10	764	32	10
7520	14\n+1	765	15	1
7521	15\n+2	765	17	2
7522	16\n+3	765	19	3
7523	17\n+4	765	21	4
7577	26\n+8	770	34	8
7578	27\n+9	770	36	9
7579	28\n+10	770	38	10
7580	20\n+1	771	21	1
7581	21\n+2	771	23	2
7582	22\n+3	771	25	3
7583	23\n+4	771	27	4
7584	24\n+5	771	29	5
7585	25\n+6	771	31	6
7586	26\n+7	771	33	7
7587	27\n+8	771	35	8
7588	28\n+9	771	37	9
7589	29\n+10	771	39	10
7590	21\n+1	772	22	1
7591	22\n+2	772	24	2
7592	23\n+3	772	26	3
7593	24\n+4	772	28	4
7594	25\n+5	772	30	5
7595	26\n+6	772	32	6
7596	27\n+7	772	34	7
7597	28\n+8	772	36	8
7598	29\n+9	772	38	9
7599	30\n+10	772	40	10
7600	12\n13\n14	773	39	1
7601	13\n14\n15	773	42	2
7602	14\n15\n16	773	45	3
7603	15\n16\n17	773	48	4
7604	16\n17\n18	773	51	5
7605	17\n18\n19	773	54	6
7606	18\n19\n20	773	57	7
7607	19\n20\n21	773	60	8
7608	20\n21\n22	773	63	9
7609	21\n22\n23	773	66	10
7610	13\n14\n15	774	42	1
7611	14\n15\n16	774	45	2
7612	15\n16\n17	774	48	3
7613	16\n17\n18	774	51	4
7614	17\n18\n19	774	54	5
7615	18\n19\n20	774	57	6
7616	19\n20\n21	774	60	7
7617	20\n21\n22	774	63	8
7618	21\n22\n23	774	66	9
7619	22\n23\n24	774	69	10
7620	14\n15\n16	775	45	1
7621	15\n16\n17	775	48	2
7622	16\n17\n18	775	51	3
7623	17\n18\n19	775	54	4
7624	18\n19\n20	775	57	5
7625	19\n20\n21	775	60	6
7626	20\n21\n22	775	63	7
7627	21\n22\n23	775	66	8
7628	22\n23\n24	775	69	9
7629	23\n24\n25	775	72	10
7630	15\n16\n17	776	48	1
7631	16\n17\n18	776	51	2
7632	17\n18\n19	776	54	3
7633	18\n19\n20	776	57	4
7634	19\n20\n21	776	60	5
7635	20\n21\n22	776	63	6
7636	21\n22\n23	776	66	7
7637	22\n23\n24	776	69	8
7638	23\n24\n25	776	72	9
7639	24\n25\n26	776	75	10
7640	16\n17\n18	777	51	1
7641	17\n18\n19	777	54	2
7642	18\n19\n20	777	57	3
7643	19\n20\n21	777	60	4
7644	20\n21\n22	777	63	5
7645	21\n22\n23	777	66	6
7646	22\n23\n24	777	69	7
7647	23\n24\n25	777	72	8
7648	24\n25\n26	777	75	9
7649	25\n26\n27	777	78	10
7650	17\n18\n19	778	54	1
7651	18\n19\n20	778	57	2
7652	19\n20\n21	778	60	3
7653	20\n21\n22	778	63	4
7654	21\n22\n23	778	66	5
7655	22\n23\n24	778	69	6
7656	23\n24\n25	778	72	7
7657	24\n25\n26	778	75	8
7658	25\n26\n27	778	78	9
7659	26\n27\n28	778	81	10
7660	18\n19\n20	779	57	1
7661	19\n20\n21	779	60	2
7663	21\n22\n23	779	66	4
7664	22\n23\n24	779	69	5
7665	23\n24\n25	779	72	6
7666	24\n25\n26	779	75	7
7667	25\n26\n27	779	78	8
7668	26\n27\n28	779	81	9
7669	27\n28\n29	779	84	10
7670	19\n20\n21	780	60	1
7671	20\n21\n22	780	63	2
7672	21\n22\n23	780	66	3
7673	22\n23\n24	780	69	4
7674	23\n24\n25	780	72	5
7675	24\n25\n26	780	75	6
7676	25\n26\n27	780	78	7
7677	26\n27\n28	780	81	8
7678	27\n28\n29	780	84	9
7679	28\n29\n30	780	87	10
7680	20\n21\n22	781	63	1
7681	21\n22\n23	781	66	2
7682	22\n23\n24	781	69	3
7683	23\n24\n25	781	72	4
7684	24\n25\n26	781	75	5
7685	25\n26\n27	781	78	6
7686	26\n27\n28	781	81	7
7687	27\n28\n29	781	84	8
7688	28\n29\n30	781	87	9
7689	29\n30\n31	781	90	10
7690	21\n22\n23	782	66	1
7691	22\n23\n24	782	69	2
7692	23\n24\n25	782	72	3
7693	24\n25\n26	782	75	4
7694	25\n26\n27	782	78	5
7695	26\n27\n28	782	81	6
7696	27\n28\n29	782	84	7
7697	28\n29\n30	782	87	8
7698	29\n30\n31	782	90	9
7699	30\n31\n32	782	93	10
7718	10\nx11	784	110	9
7719	10\nx12	784	120	10
7720	10\nx4	785	40	1
7721	10\nx5	785	50	2
7722	10\nx6	785	60	3
7723	10\nx7	785	70	4
7724	10\nx8	785	80	5
7725	10\nx9	785	90	6
7726	10\nx10	785	100	7
7727	10\nx11	785	110	8
7728	10\nx12	785	120	9
7729	10\nx13	785	130	10
7730	10\nx5	786	50	1
7731	10\nx6	786	60	2
7732	10\nx7	786	70	3
7733	10\nx8	786	80	4
7734	10\nx9	786	90	5
7735	10\nx10	786	100	6
7700	10\nx2	783	20	1
7701	10\nx3	783	30	2
7702	10\nx4	783	40	3
7703	10\nx5	783	50	4
7704	10\nx6	783	60	5
7705	10\nx7	783	70	6
7706	10\nx8	783	80	7
7707	10\nx9	783	90	8
7708	10\nx10	783	100	9
7709	10\nx11	783	110	10
7710	10\nx3	784	30	1
7711	10\nx4	784	40	2
7712	10\nx5	784	50	3
7713	10\nx6	784	60	4
7714	10\nx7	784	70	5
7715	10\nx8	784	80	6
7716	10\nx9	784	90	7
7717	10\nx10	784	100	8
7736	10\nx11	786	110	7
7737	10\nx12	786	120	8
7738	10\nx13	786	130	9
7739	10\nx14	786	140	10
7740	10\nx6	787	60	1
7741	10\nx7	787	70	2
7764	10\nx12	789	120	5
7765	10\nx13	789	130	6
7766	10\nx14	789	140	7
7767	10\nx15	789	150	8
7768	10\nx16	789	160	9
7769	10\nx17	789	170	10
7770	10\nx9	790	90	1
7771	10\nx10	790	100	2
7772	10\nx11	790	110	3
7794	10\nx15	792	150	5
7795	10\nx16	792	160	6
7796	10\nx17	792	170	7
7797	10\nx18	792	180	8
7798	10\nx19	792	190	9
5714	15\n+5	584	20	5
7773	10\nx12	790	120	4
7774	10\nx13	790	130	5
7775	10\nx14	790	140	6
7776	10\nx15	790	150	7
7777	10\nx16	790	160	8
7778	10\nx17	790	170	9
7779	10\nx18	790	180	10
7780	10\nx10	791	100	1
7781	10\nx11	791	110	2
7782	10\nx12	791	120	3
7783	10\nx13	791	130	4
7784	10\nx14	791	140	5
7785	10\nx15	791	150	6
7786	10\nx16	791	160	7
7787	10\nx17	791	170	8
7788	10\nx18	791	180	9
7789	10\nx19	791	190	10
7790	10\nx11	792	110	1
7791	10\nx12	792	120	2
7792	10\nx13	792	130	3
7793	10\nx14	792	140	4
7746	10\nx12	787	120	7
7747	10\nx13	787	130	8
7748	10\nx14	787	140	9
7799	10\nx20	792	200	10
7800	10\nx2	793	20	1
7801	10\nx3	793	30	2
7802	10\nx4	793	40	3
7803	10\nx5	793	50	4
7804	10\nx6	793	60	5
7805	10\nx7	793	70	6
7806	10\nx8	793	80	7
7807	10\nx9	793	90	8
7808	10\nx10	793	100	9
7809	10\nx11	793	110	10
7810	10\nx3	794	30	1
7811	10\nx4	794	40	2
7812	10\nx5	794	50	3
7813	10\nx6	794	60	4
7814	10\nx7	794	70	5
7815	10\nx8	794	80	6
7816	10\nx9	794	90	7
7743	10\nx9	787	90	4
7744	10\nx10	787	100	5
7745	10\nx11	787	110	6
7749	10\nx15	787	150	10
7750	10\nx7	788	70	1
7751	10\nx8	788	80	2
7752	10\nx9	788	90	3
7753	10\nx10	788	100	4
7754	10\nx11	788	110	5
7755	10\nx12	788	120	6
7756	10\nx13	788	130	7
7757	10\nx14	788	140	8
7758	10\nx15	788	150	9
7759	10\nx16	788	160	10
7760	10\nx8	789	80	1
7761	10\nx9	789	90	2
7762	10\nx10	789	100	3
7763	10\nx11	789	110	4
7839	10\nx14	796	140	10
7840	10\nx6	797	60	1
7841	10\nx7	797	70	2
7842	10\nx8	797	80	3
7843	10\nx9	797	90	4
7844	10\nx10	797	100	5
7845	10\nx11	797	110	6
7846	10\nx12	797	120	7
7847	10\nx13	797	130	8
7869	10\nx17	799	170	10
7870	10\nx9	800	90	1
7871	10\nx10	800	100	2
7872	10\nx11	800	110	3
7873	10\nx12	800	120	4
5795	24\n+6	592	30	6
7848	10\nx14	797	140	9
7849	10\nx15	797	150	10
7850	10\nx7	798	70	1
7851	10\nx8	798	80	2
7852	10\nx9	798	90	3
7853	10\nx10	798	100	4
7854	10\nx11	798	110	5
7855	10\nx12	798	120	6
7856	10\nx13	798	130	7
7857	10\nx14	798	140	8
7858	10\nx15	798	150	9
7859	10\nx16	798	160	10
7860	10\nx8	799	80	1
7861	10\nx9	799	90	2
7862	10\nx10	799	100	3
7863	10\nx11	799	110	4
7864	10\nx12	799	120	5
7865	10\nx13	799	130	6
7866	10\nx14	799	140	7
7867	10\nx15	799	150	8
7868	10\nx16	799	160	9
7821	10\nx5	795	50	2
7822	10\nx6	795	60	3
7823	10\nx7	795	70	4
7874	10\nx13	800	130	5
7875	10\nx14	800	140	6
7876	10\nx15	800	150	7
7877	10\nx16	800	160	8
7878	10\nx17	800	170	9
7879	10\nx18	800	180	10
7880	10\nx10	801	100	1
7881	10\nx11	801	110	2
7882	10\nx12	801	120	3
7883	10\nx13	801	130	4
7884	10\nx14	801	140	5
7885	10\nx15	801	150	6
7886	10\nx16	801	160	7
7887	10\nx17	801	170	8
7888	10\nx18	801	180	9
7889	10\nx19	801	190	10
7890	10\nx11	802	110	1
7891	10\nx12	802	120	2
7818	10\nx11	794	110	9
7819	10\nx12	794	120	10
7820	10\nx4	795	40	1
7824	10\nx8	795	80	5
7825	10\nx9	795	90	6
7826	10\nx10	795	100	7
7827	10\nx11	795	110	8
7828	10\nx12	795	120	9
7829	10\nx13	795	130	10
7830	10\nx5	796	50	1
7831	10\nx6	796	60	2
7832	10\nx7	796	70	3
7833	10\nx8	796	80	4
7834	10\nx9	796	90	5
7835	10\nx10	796	100	6
7836	10\nx11	796	110	7
7837	10\nx12	796	120	8
7838	10\nx13	796	130	9
7931	60\n/10	806	6	2
7932	70\n/10	806	7	3
7933	80\n/10	806	8	4
7934	90\n/10	806	9	5
7935	100\n/10	806	10	6
7945	110\n/10	807	11	6
7946	120\n/10	807	12	7
7947	130\n/10	807	13	8
7893	10\nx14	802	140	4
7894	10\nx15	802	150	5
7895	10\nx16	802	160	6
7896	10\nx17	802	170	7
7914	70\n/10	804	7	5
7915	80\n/10	804	8	6
7916	90\n/10	804	9	7
7917	100\n/10	804	10	8
7918	110\n/10	804	11	9
7919	120\n/10	804	12	10
7920	40\n/10	805	4	1
7921	50\n/10	805	5	2
7922	60\n/10	805	6	3
7923	70\n/10	805	7	4
7924	80\n/10	805	8	5
7925	90\n/10	805	9	6
7897	10\nx18	802	180	8
7948	140\n/10	807	14	9
7949	150\n/10	807	15	10
7950	70\n/10	808	7	1
7951	80\n/10	808	8	2
7952	90\n/10	808	9	3
7953	100\n/10	808	10	4
7954	110\n/10	808	11	5
7955	120\n/10	808	12	6
7956	130\n/10	808	13	7
7957	140\n/10	808	14	8
7958	150\n/10	808	15	9
7959	160\n/10	808	16	10
7960	80\n/10	809	8	1
7961	90\n/10	809	9	2
7962	100\n/10	809	10	3
7963	110\n/10	809	11	4
7936	110\n/10	806	11	7
7937	120\n/10	806	12	8
7938	130\n/10	806	13	9
7939	140\n/10	806	14	10
7940	60\n/10	807	6	1
7941	70\n/10	807	7	2
7942	80\n/10	807	8	3
7943	90\n/10	807	9	4
7944	100\n/10	807	10	5
7898	10\nx19	802	190	9
7899	10\nx20	802	200	10
7913	60\n/10	804	6	4
7964	120\n/10	809	12	5
7965	130\n/10	809	13	6
7966	140\n/10	809	14	7
7967	150\n/10	809	15	8
7968	160\n/10	809	16	9
7969	170\n/10	809	17	10
7970	90\n/10	810	9	1
7971	100\n/10	810	10	2
7972	110\n/10	810	11	3
7900	20\n/10	803	2	1
7901	30\n/10	803	3	2
7902	40\n/10	803	4	3
7903	50\n/10	803	5	4
7904	60\n/10	803	6	5
7905	70\n/10	803	7	6
7906	80\n/10	803	8	7
7907	90\n/10	803	9	8
7908	100\n/10	803	10	9
7909	110\n/10	803	11	10
7910	30\n/10	804	3	1
7911	40\n/10	804	4	2
7912	50\n/10	804	5	3
7926	100\n/10	805	10	7
7927	110\n/10	805	11	8
7928	120\n/10	805	12	9
7929	130\n/10	805	13	10
7930	50\n/10	806	5	1
8003	50\n/10	813	5	4
8004	60\n/10	813	6	5
8005	70\n/10	813	7	6
8006	80\n/10	813	8	7
8007	90\n/10	813	9	8
8008	100\n/10	813	10	9
8009	110\n/10	813	11	10
8010	30\n/10	814	3	1
8011	40\n/10	814	4	2
8012	50\n/10	814	5	3
8013	60\n/10	814	6	4
8014	70\n/10	814	7	5
8015	80\n/10	814	8	6
8016	90\n/10	814	9	7
8017	100\n/10	814	10	8
7983	130\n/10	811	13	4
7984	140\n/10	811	14	5
7985	150\n/10	811	15	6
7986	160\n/10	811	16	7
7987	170\n/10	811	17	8
7988	180\n/10	811	18	9
7989	190\n/10	811	19	10
7990	110\n/10	812	11	1
7991	120\n/10	812	12	2
8018	110\n/10	814	11	9
8019	120\n/10	814	12	10
5876	23\n+7	600	30	7
8020	40\n/10	815	4	1
8021	50\n/10	815	5	2
8022	60\n/10	815	6	3
8023	70\n/10	815	7	4
8024	80\n/10	815	8	5
8025	90\n/10	815	9	6
8026	100\n/10	815	10	7
8027	110\n/10	815	11	8
8028	120\n/10	815	12	9
8029	130\n/10	815	13	10
8030	50\n/10	816	5	1
8053	100\n/10	818	10	4
7974	130\n/10	810	13	5
7975	140\n/10	810	14	6
7976	150\n/10	810	15	7
7977	160\n/10	810	16	8
7978	170\n/10	810	17	9
7979	180\n/10	810	18	10
7980	100\n/10	811	10	1
7981	110\n/10	811	11	2
7982	120\n/10	811	12	3
7992	130\n/10	812	13	3
7993	140\n/10	812	14	4
7994	150\n/10	812	15	5
7995	160\n/10	812	16	6
7996	170\n/10	812	17	7
8031	60\n/10	816	6	2
8032	70\n/10	816	7	3
8033	80\n/10	816	8	4
8034	90\n/10	816	9	5
8035	100\n/10	816	10	6
8036	110\n/10	816	11	7
8037	120\n/10	816	12	8
8038	130\n/10	816	13	9
8039	140\n/10	816	14	10
8040	60\n/10	817	6	1
8041	70\n/10	817	7	2
8042	80\n/10	817	8	3
8043	90\n/10	817	9	4
8044	100\n/10	817	10	5
8045	110\n/10	817	11	6
8046	120\n/10	817	12	7
8047	130\n/10	817	13	8
8048	140\n/10	817	14	9
8049	150\n/10	817	15	10
8050	70\n/10	818	7	1
8051	80\n/10	818	8	2
8052	90\n/10	818	9	3
7997	180\n/10	812	18	8
7998	190\n/10	812	19	9
7999	200\n/10	812	20	10
8000	20\n/10	813	2	1
8001	30\n/10	813	3	2
8002	40\n/10	813	4	3
6042	16\n17\n18	617	51	3
6852	18\n19\n20	698	57	3
7662	20\n21\n22	779	63	3
8085	150\n/10	821	15	6
8086	160\n/10	821	16	7
8087	170\n/10	821	17	8
8088	180\n/10	821	18	9
8089	190\n/10	821	19	10
8090	110\n/10	822	11	1
8091	120\n/10	822	12	2
8092	130\n/10	822	13	3
8093	140\n/10	822	14	4
5957	22\n+8	608	30	8
6524	17\n+5	665	22	5
6605	16\n+6	673	22	6
6686	25\n+7	681	32	7
6767	24\n+8	689	32	8
7333	18\n+4	746	22	4
8094	150\n/10	822	15	5
8095	160\n/10	822	16	6
7414	17\n+5	754	22	5
7495	26\n+6	762	32	6
7576	25\n+7	770	32	7
8096	170\n/10	822	17	7
8097	180\n/10	822	18	8
8098	190\n/10	822	19	9
8099	200\n/10	822	20	10
7892	10\nx13	802	130	3
8064	120\n/10	819	12	5
8065	130\n/10	819	13	6
8066	140\n/10	819	14	7
8067	150\n/10	819	15	8
8068	160\n/10	819	16	9
8069	170\n/10	819	17	10
8070	90\n/10	820	9	1
8071	100\n/10	820	10	2
8072	110\n/10	820	11	3
8073	120\n/10	820	12	4
6362	80\n/8	649	10	3
6443	72\n/8	657	9	4
7171	90\n/9	730	10	2
7252	81\n/9	738	9	3
7973	120\n/10	810	12	4
8054	110\n/10	818	11	5
8055	120\n/10	818	12	6
8056	130\n/10	818	13	7
8057	140\n/10	818	14	8
8058	150\n/10	818	15	9
8059	160\n/10	818	16	10
8060	80\n/10	819	8	1
8061	90\n/10	819	9	2
8062	100\n/10	819	10	3
8063	110\n/10	819	11	4
8074	130\n/10	820	13	5
8075	140\n/10	820	14	6
8076	150\n/10	820	15	7
8077	160\n/10	820	16	8
8078	170\n/10	820	17	9
8079	180\n/10	820	18	10
8080	100\n/10	821	10	1
8081	110\n/10	821	11	2
8082	120\n/10	821	12	3
8083	130\n/10	821	13	4
6126	8\nx10	625	80	7
6201	8\nx3	633	24	2
6282	8\nx12	641	96	3
6934	9\nx9	706	81	5
7010	9\nx3	714	27	1
7090	9\nx11	722	99	1
7742	10\nx8	787	80	3
7817	10\nx10	794	100	8
8084	140\n/10	821	14	5
\.


--
-- Data for Name: curriculum_unit_attempts; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.curriculum_unit_attempts (id, student_id, unit_id, status, elapsed_seconds, correct_count, wrong_count, completed_at, updated_at, created_at, assignment_id) FROM stdin;
12	4	24	in_progress	15	0	1	\N	2026-03-28 02:59:33.279514	2026-03-28 02:25:53.063042	79
7	4	263	passed	33	9	1	2026-03-28 02:16:58.950779	2026-03-28 02:16:58.950791	2026-03-28 02:16:29.831929	82
2	4	17	failed	9	1	9	2026-03-26 22:07:38.634906	2026-03-26 22:07:38.634909	2026-03-26 22:07:32.345104	\N
11	4	23	passed	30	9	1	2026-03-28 02:25:37.162802	2026-03-28 02:25:37.162818	2026-03-28 02:25:12.504347	79
8	4	323	failed	8	2	8	2026-03-28 02:20:17.567187	2026-03-28 02:20:17.567193	2026-03-28 02:20:14.012725	82
3	4	11	in_progress	7	1	3	\N	2026-03-26 23:18:09.213507	2026-03-26 23:18:07.171274	\N
13	4	25	failed	21	0	10	2026-03-28 03:00:09.324491	2026-03-28 03:00:09.324494	2026-03-28 02:59:54.94678	79
4	4	12	in_progress	3	0	4	\N	2026-03-26 23:18:28.607882	2026-03-26 23:18:26.708192	\N
1	4	13	in_progress	21	0	5	\N	2026-03-26 23:21:01.479941	2026-03-26 21:42:42.559563	\N
6	4	9	passed	4	1	0	2026-03-27 00:48:44.145842	2026-03-27 00:48:44.145846	2026-03-27 00:48:44.136315	58
9	4	503	passed	35	10	0	2026-03-28 02:23:09.226737	2026-03-28 02:23:09.226752	2026-03-28 02:22:38.092703	85
14	4	30	failed	8	0	10	2026-03-28 03:00:31.516413	2026-03-28 03:00:31.516417	2026-03-28 03:00:27.874432	79
10	4	504	failed	3	0	10	2026-03-28 02:23:21.11717	2026-03-28 02:23:21.117173	2026-03-28 02:23:19.134347	85
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	contenttypes	contenttype
2	sessions	session
3	api	appuser
4	api	assignment
5	api	chapter
6	api	grade
7	api	learning
8	api	lessontype
9	api	question
10	api	studentanswer
11	api	studentprofile
12	api	sublesson
13	api	sublessontypemaster
14	api	unit
15	api	curriculumquestionattempt
16	api	curriculumunitattempt
\.


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2026-03-22 21:36:48.201462+00
2	contenttypes	0002_remove_content_type_name	2026-03-22 21:36:48.207687+00
3	sessions	0001_initial	2026-03-22 22:18:34.486614+00
4	api	0001_initial	2026-03-24 22:54:21.281702+00
5	api	0002_question_order	2026-03-24 22:54:21.287312+00
6	api	0003_learning_order	2026-03-24 22:54:21.289014+00
7	api	0004_drop_deprecated_units	2026-03-25 22:18:38.109595+00
8	api	0005_rename_curriculum_tables	2026-03-25 22:41:56.576068+00
9	api	0006_ensure_order_columns	2026-03-26 21:40:49.157611+00
10	api	0007_curriculum_unit_attempts	2026-03-26 21:40:49.187798+00
11	api	0008_curriculum_attempt_assignment_scope	2026-03-27 00:45:54.35604+00
12	api	0009_ensure_student_profile_columns	2026-03-29 14:09:43.251361+01
13	api	0010_sync_primary_key_sequences	2026-03-29 15:13:12.825489+01
\.


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
pnjli80max1ctjvw45mch0w93aq6mjvi	eyJ1aV91c2VyX2lkIjo0fQ:1w6ICa:wl346Z1Lx7KrIog0cnEqVXNZVMDEnGKIZc6zUqUF2ok	2026-04-11 02:11:00.332441+01
9indj051nsu91ri5pw5dheu6v3vk3uqp	eyJ1aV91c2VyX2lkIjoyfQ:1w6qOc:cFWb1JR5jdKgXxiVzH4_BHfGDURuDOuHgCNz_oxaM_Y	2026-04-12 14:41:42.039416+01
f1vjiwie4izy7x2jhb8v31blptr6bk8d	eyJ1aV91c2VyX2lkIjoyfQ:1w5BCh:Cg-wfo3ptvxFZNPjpWQtN-d1ec7FQkjmc9DE05Ybicg	2026-04-08 00:30:31.794432+01
67whzyqxf5f7kox0fzc2ros97bdh8gaz	eyJ1aV91c2VyX2lkIjoyfQ:1w5BCt:REDemKQyqH-DboTBBYCd8S5uS1uNjNH7e07arvqaWos	2026-04-08 00:30:43.946406+01
tdiehf53xyo84j7eisy9w05voc77p3lb	eyJ1aV91c2VyX2lkIjoyfQ:1w5BFi:Ru9QLCE36myivXvbD1a_uhlmU9LpD0b8mM175gB-0IA	2026-04-08 00:33:38.862876+01
sreutvs6gtjsofhr1yz1459bpabj8zck	eyJ1aV91c2VyX2lkIjoyfQ:1w5BFt:k7xoMNxgILcYiUJs98e_PvJpQ13dZ8LZX0gid4-5jDM	2026-04-08 00:33:49.315649+01
qne5m7dkgcuvn9lpj0padnbad2lsqn5a	eyJ1aV91c2VyX2lkIjoyfQ:1w5Xjs:Bfl64OAhcug4xdZLoE79U0Un2OEvuVWtQi1ily4O_aI	2026-04-09 00:34:16.392894+01
oob61wzjrh92g6qa7pc2ppjffsev1u2i	eyJ1aV91c2VyX2lkIjo0fQ:1w5pcN:H3GMSU0KF9JqSSp725lFUScVf1kyeWVIuDFFzWLCUi8	2026-04-09 19:39:43.161717+01
\.


--
-- Data for Name: grades; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.grades (id, grade_name) FROM stdin;
9	10
10	9
11	8
12	1
\.


--
-- Data for Name: lesson_types; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.lesson_types (id, grade_id, lesson_name) FROM stdin;
13	9	1
14	9	2
15	10	1
16	10	2
17	10	3
18	11	1
19	9	3
20	9	4
21	9	5
22	9	6
23	9	7
24	9	8
25	9	9
26	9	10
27	12	1
28	12	2
29	12	3
30	12	4
31	12	5
32	12	6
33	12	7
34	12	8
35	12	9
36	12	10
\.


--
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.questions (id, assignment_id, question_text, correct_answer, "order") FROM stdin;
\.


--
-- Data for Name: student_answers; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.student_answers (id, question_id, student_id, student_answer, is_correct) FROM stdin;
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.students (id, user_id, grade_id, first_name, last_name, father_name, mother_name, contact, profile_photo, date_of_birth) FROM stdin;
2	3	\N	t1	t1	ft1	mt1	0123456789	student_profiles/fbaadbe8508949b5872efa28d94f1b28.png	\N
3	4	\N	prabhat	shukla	fn	mn	0123456789	student_profiles/3d0c94fa38a34602b89c4d25c24efb94.png	\N
4	8	\N	test	test	fn	mn	0123456789	student_profiles/b43f0035a3d04cc9836dcd329e62a5e8.png	2026-03-07
\.


--
-- Data for Name: sub_lesson_type_master; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.sub_lesson_type_master (id, type_name) FROM stdin;
1	Reading Abacus
2	Listening Abacus
3	Listening Anzan
4	Flash Anzan
5	Multiplication Abacus
6	Multiplication Anzan
7	Division Abacus
8	Division Anzan
\.


--
-- Data for Name: sub_lessons; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.sub_lessons (id, lesson_type_id, sub_lesson_name, sub_lesson_type_master_id) FROM stdin;
3	13	Reading Abacus	1
4	14	Reading Abacus	1
5	14	Listening Abacus	2
6	15	Reading Abacus	1
7	15	Listening Abacus	2
8	16	Listening Anzan	3
9	17	Flash Anzan	4
10	18	Reading Abacus	1
11	18	Listening Abacus	2
12	18	Listening Anzan	3
13	19	Reading Abacus	1
14	19	Listening Abacus	2
15	20	Reading Abacus	1
16	21	Reading Abacus	1
17	22	Reading Abacus	1
18	23	Reading Abacus	1
19	24	Reading Abacus	1
20	25	Reading Abacus	1
21	26	Reading Abacus	1
22	26	Listening Abacus	2
23	18	Multiplication Abacus	5
24	18	Multiplication Anzan	6
25	18	Division Abacus	7
26	18	Division Anzan	8
27	18	Flash Anzan	4
28	27	Reading Abacus	1
29	27	Listening Abacus	2
30	27	Listening Anzan	3
31	27	Flash Anzan	4
32	27	Multiplication Abacus	5
33	27	Multiplication Anzan	6
34	27	Division Abacus	7
35	27	Division Anzan	8
36	28	Reading Abacus	1
37	28	Listening Abacus	2
38	28	Listening Anzan	3
39	28	Flash Anzan	4
40	28	Multiplication Abacus	5
41	28	Multiplication Anzan	6
42	28	Division Abacus	7
43	28	Division Anzan	8
44	29	Reading Abacus	1
45	29	Listening Abacus	2
46	29	Listening Anzan	3
47	29	Flash Anzan	4
48	29	Multiplication Abacus	5
49	29	Multiplication Anzan	6
50	29	Division Abacus	7
51	29	Division Anzan	8
52	30	Reading Abacus	1
53	30	Listening Abacus	2
54	30	Listening Anzan	3
55	30	Flash Anzan	4
56	30	Multiplication Abacus	5
57	30	Multiplication Anzan	6
58	30	Division Abacus	7
59	30	Division Anzan	8
60	31	Reading Abacus	1
61	31	Listening Abacus	2
62	31	Listening Anzan	3
63	31	Flash Anzan	4
64	31	Multiplication Abacus	5
65	31	Multiplication Anzan	6
66	31	Division Abacus	7
67	31	Division Anzan	8
68	32	Reading Abacus	1
69	32	Listening Abacus	2
70	32	Listening Anzan	3
71	32	Flash Anzan	4
72	32	Multiplication Abacus	5
73	32	Multiplication Anzan	6
74	32	Division Abacus	7
75	32	Division Anzan	8
76	33	Reading Abacus	1
77	33	Listening Abacus	2
78	33	Listening Anzan	3
79	33	Flash Anzan	4
80	33	Multiplication Abacus	5
81	33	Multiplication Anzan	6
82	33	Division Abacus	7
83	33	Division Anzan	8
84	34	Reading Abacus	1
85	34	Listening Abacus	2
86	34	Listening Anzan	3
87	34	Flash Anzan	4
88	34	Multiplication Abacus	5
89	34	Multiplication Anzan	6
90	34	Division Abacus	7
91	34	Division Anzan	8
92	35	Reading Abacus	1
93	35	Listening Abacus	2
94	35	Listening Anzan	3
95	35	Flash Anzan	4
96	35	Multiplication Abacus	5
97	35	Multiplication Anzan	6
98	35	Division Abacus	7
99	35	Division Anzan	8
100	36	Reading Abacus	1
101	36	Listening Abacus	2
102	36	Listening Anzan	3
103	36	Flash Anzan	4
104	36	Multiplication Abacus	5
105	36	Multiplication Anzan	6
106	36	Division Abacus	7
107	36	Division Anzan	8
\.


--
-- Data for Name: units; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.units (id, sub_lesson_id, unit_name) FROM stdin;
3	3	1
4	3	2
5	4	1
7	5	1
9	6	1
10	7	1
11	10	1
12	10	2
13	11	1
14	3	3
15	3	4
16	3	5
17	12	1
18	23	1
19	24	1
20	25	1
21	26	1
22	27	1
23	28	1
24	28	2
25	28	3
26	28	4
27	28	5
28	28	6
29	28	7
30	28	8
31	28	9
32	28	10
33	29	1
34	29	2
35	29	3
36	29	4
37	29	5
38	29	6
39	29	7
40	29	8
41	29	9
42	29	10
43	30	1
44	30	2
45	30	3
46	30	4
47	30	5
48	30	6
49	30	7
50	30	8
51	30	9
52	30	10
53	31	1
54	31	2
55	31	3
56	31	4
57	31	5
58	31	6
59	31	7
60	31	8
61	31	9
62	31	10
63	32	1
64	32	2
65	32	3
66	32	4
67	32	5
68	32	6
69	32	7
70	32	8
71	32	9
72	32	10
73	33	1
74	33	2
75	33	3
76	33	4
77	33	5
78	33	6
79	33	7
80	33	8
81	33	9
82	33	10
83	34	1
84	34	2
85	34	3
86	34	4
87	34	5
88	34	6
89	34	7
90	34	8
91	34	9
92	34	10
93	35	1
94	35	2
95	35	3
96	35	4
97	35	5
98	35	6
99	35	7
100	35	8
101	35	9
102	35	10
103	36	1
104	36	2
105	36	3
106	36	4
107	36	5
108	36	6
109	36	7
110	36	8
111	36	9
112	36	10
113	37	1
114	37	2
115	37	3
116	37	4
117	37	5
118	37	6
119	37	7
120	37	8
121	37	9
122	37	10
123	38	1
124	38	2
125	38	3
126	38	4
127	38	5
128	38	6
129	38	7
130	38	8
131	38	9
132	38	10
133	39	1
134	39	2
135	39	3
136	39	4
137	39	5
138	39	6
139	39	7
140	39	8
141	39	9
142	39	10
143	40	1
144	40	2
145	40	3
146	40	4
147	40	5
148	40	6
149	40	7
150	40	8
151	40	9
152	40	10
153	41	1
154	41	2
155	41	3
156	41	4
157	41	5
158	41	6
159	41	7
160	41	8
161	41	9
162	41	10
163	42	1
164	42	2
165	42	3
166	42	4
167	42	5
168	42	6
169	42	7
170	42	8
171	42	9
172	42	10
173	43	1
174	43	2
175	43	3
176	43	4
177	43	5
178	43	6
179	43	7
180	43	8
181	43	9
182	43	10
183	44	1
184	44	2
185	44	3
186	44	4
187	44	5
188	44	6
189	44	7
190	44	8
191	44	9
192	44	10
193	45	1
194	45	2
195	45	3
196	45	4
197	45	5
198	45	6
199	45	7
200	45	8
201	45	9
202	45	10
203	46	1
204	46	2
205	46	3
206	46	4
207	46	5
208	46	6
209	46	7
210	46	8
211	46	9
212	46	10
213	47	1
214	47	2
215	47	3
216	47	4
217	47	5
218	47	6
219	47	7
220	47	8
221	47	9
222	47	10
223	48	1
224	48	2
225	48	3
226	48	4
227	48	5
228	48	6
229	48	7
230	48	8
231	48	9
232	48	10
233	49	1
234	49	2
235	49	3
236	49	4
237	49	5
238	49	6
239	49	7
240	49	8
241	49	9
242	49	10
243	50	1
244	50	2
245	50	3
246	50	4
247	50	5
248	50	6
249	50	7
250	50	8
251	50	9
252	50	10
253	51	1
254	51	2
255	51	3
256	51	4
257	51	5
258	51	6
259	51	7
260	51	8
261	51	9
262	51	10
263	52	1
264	52	2
265	52	3
266	52	4
267	52	5
268	52	6
269	52	7
270	52	8
271	52	9
272	52	10
273	53	1
274	53	2
275	53	3
276	53	4
277	53	5
278	53	6
279	53	7
280	53	8
281	53	9
282	53	10
283	54	1
284	54	2
285	54	3
286	54	4
287	54	5
288	54	6
289	54	7
290	54	8
291	54	9
292	54	10
293	55	1
294	55	2
295	55	3
296	55	4
297	55	5
298	55	6
299	55	7
300	55	8
301	55	9
302	55	10
303	56	1
304	56	2
305	56	3
306	56	4
307	56	5
308	56	6
309	56	7
310	56	8
311	56	9
312	56	10
313	57	1
314	57	2
315	57	3
316	57	4
317	57	5
318	57	6
319	57	7
320	57	8
321	57	9
322	57	10
323	58	1
324	58	2
325	58	3
326	58	4
327	58	5
328	58	6
329	58	7
330	58	8
331	58	9
332	58	10
333	59	1
334	59	2
335	59	3
336	59	4
337	59	5
338	59	6
339	59	7
340	59	8
341	59	9
342	59	10
343	60	1
344	60	2
345	60	3
346	60	4
347	60	5
348	60	6
349	60	7
350	60	8
351	60	9
352	60	10
353	61	1
354	61	2
355	61	3
356	61	4
357	61	5
358	61	6
359	61	7
360	61	8
361	61	9
362	61	10
363	62	1
364	62	2
365	62	3
366	62	4
367	62	5
368	62	6
369	62	7
370	62	8
371	62	9
372	62	10
373	63	1
374	63	2
375	63	3
376	63	4
377	63	5
378	63	6
379	63	7
380	63	8
381	63	9
382	63	10
383	64	1
384	64	2
385	64	3
386	64	4
387	64	5
388	64	6
389	64	7
390	64	8
391	64	9
392	64	10
393	65	1
394	65	2
395	65	3
396	65	4
397	65	5
398	65	6
399	65	7
400	65	8
401	65	9
402	65	10
403	66	1
404	66	2
405	66	3
406	66	4
407	66	5
408	66	6
409	66	7
410	66	8
411	66	9
412	66	10
413	67	1
414	67	2
415	67	3
416	67	4
417	67	5
418	67	6
419	67	7
420	67	8
421	67	9
422	67	10
423	68	1
424	68	2
425	68	3
426	68	4
427	68	5
428	68	6
429	68	7
430	68	8
431	68	9
432	68	10
433	69	1
434	69	2
435	69	3
436	69	4
437	69	5
438	69	6
439	69	7
440	69	8
441	69	9
442	69	10
443	70	1
444	70	2
445	70	3
446	70	4
447	70	5
448	70	6
449	70	7
450	70	8
451	70	9
452	70	10
453	71	1
454	71	2
455	71	3
456	71	4
457	71	5
458	71	6
459	71	7
460	71	8
461	71	9
462	71	10
463	72	1
464	72	2
465	72	3
466	72	4
467	72	5
468	72	6
469	72	7
470	72	8
471	72	9
472	72	10
473	73	1
474	73	2
475	73	3
476	73	4
477	73	5
478	73	6
479	73	7
480	73	8
481	73	9
482	73	10
483	74	1
484	74	2
485	74	3
486	74	4
487	74	5
488	74	6
489	74	7
490	74	8
491	74	9
492	74	10
493	75	1
494	75	2
495	75	3
496	75	4
497	75	5
498	75	6
499	75	7
500	75	8
501	75	9
502	75	10
503	76	1
504	76	2
505	76	3
506	76	4
507	76	5
508	76	6
509	76	7
510	76	8
511	76	9
512	76	10
513	77	1
514	77	2
515	77	3
516	77	4
517	77	5
518	77	6
519	77	7
520	77	8
521	77	9
522	77	10
523	78	1
524	78	2
525	78	3
526	78	4
527	78	5
528	78	6
529	78	7
530	78	8
531	78	9
532	78	10
533	79	1
534	79	2
535	79	3
536	79	4
537	79	5
538	79	6
539	79	7
540	79	8
541	79	9
542	79	10
543	80	1
544	80	2
545	80	3
546	80	4
547	80	5
548	80	6
549	80	7
550	80	8
551	80	9
552	80	10
553	81	1
554	81	2
555	81	3
556	81	4
557	81	5
558	81	6
559	81	7
560	81	8
561	81	9
562	81	10
563	82	1
564	82	2
565	82	3
566	82	4
567	82	5
568	82	6
569	82	7
570	82	8
571	82	9
572	82	10
573	83	1
574	83	2
575	83	3
576	83	4
577	83	5
578	83	6
579	83	7
580	83	8
581	83	9
582	83	10
583	84	1
584	84	2
585	84	3
586	84	4
587	84	5
588	84	6
589	84	7
590	84	8
591	84	9
592	84	10
593	85	1
594	85	2
595	85	3
596	85	4
597	85	5
598	85	6
599	85	7
600	85	8
601	85	9
602	85	10
603	86	1
604	86	2
605	86	3
606	86	4
607	86	5
608	86	6
609	86	7
610	86	8
611	86	9
612	86	10
613	87	1
614	87	2
615	87	3
616	87	4
617	87	5
618	87	6
619	87	7
620	87	8
621	87	9
622	87	10
623	88	1
624	88	2
625	88	3
626	88	4
627	88	5
628	88	6
629	88	7
630	88	8
631	88	9
632	88	10
633	89	1
634	89	2
635	89	3
636	89	4
637	89	5
638	89	6
639	89	7
640	89	8
641	89	9
642	89	10
643	90	1
644	90	2
645	90	3
646	90	4
647	90	5
648	90	6
649	90	7
650	90	8
651	90	9
652	90	10
653	91	1
654	91	2
655	91	3
656	91	4
657	91	5
658	91	6
659	91	7
660	91	8
661	91	9
662	91	10
663	92	1
664	92	2
665	92	3
666	92	4
667	92	5
668	92	6
669	92	7
670	92	8
671	92	9
672	92	10
673	93	1
674	93	2
675	93	3
676	93	4
677	93	5
678	93	6
679	93	7
680	93	8
681	93	9
682	93	10
683	94	1
684	94	2
685	94	3
686	94	4
687	94	5
688	94	6
689	94	7
690	94	8
691	94	9
692	94	10
693	95	1
694	95	2
695	95	3
696	95	4
697	95	5
698	95	6
699	95	7
700	95	8
701	95	9
702	95	10
703	96	1
704	96	2
705	96	3
706	96	4
707	96	5
708	96	6
709	96	7
710	96	8
711	96	9
712	96	10
713	97	1
714	97	2
715	97	3
716	97	4
717	97	5
718	97	6
719	97	7
720	97	8
721	97	9
722	97	10
723	98	1
724	98	2
725	98	3
726	98	4
727	98	5
728	98	6
729	98	7
730	98	8
731	98	9
732	98	10
733	99	1
734	99	2
735	99	3
736	99	4
737	99	5
738	99	6
739	99	7
740	99	8
741	99	9
742	99	10
743	100	1
744	100	2
745	100	3
746	100	4
747	100	5
748	100	6
749	100	7
750	100	8
751	100	9
752	100	10
753	101	1
754	101	2
755	101	3
756	101	4
757	101	5
758	101	6
759	101	7
760	101	8
761	101	9
762	101	10
763	102	1
764	102	2
765	102	3
766	102	4
767	102	5
768	102	6
769	102	7
770	102	8
771	102	9
772	102	10
773	103	1
774	103	2
775	103	3
776	103	4
777	103	5
778	103	6
779	103	7
780	103	8
781	103	9
782	103	10
783	104	1
784	104	2
785	104	3
786	104	4
787	104	5
788	104	6
789	104	7
790	104	8
791	104	9
792	104	10
793	105	1
794	105	2
795	105	3
796	105	4
797	105	5
798	105	6
799	105	7
800	105	8
801	105	9
802	105	10
803	106	1
804	106	2
805	106	3
806	106	4
807	106	5
808	106	6
809	106	7
810	106	8
811	106	9
812	106	10
813	107	1
814	107	2
815	107	3
816	107	4
817	107	5
818	107	6
819	107	7
820	107	8
821	107	9
822	107	10
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: prabhatshukla
--

COPY public.users (id, name, email, password, role) FROM stdin;
3	t1 t1	t1@gmail.com	$2b$12$DmgVx9KFUXoFIi1prcRwQOyyhKYLv7Q1.gCKcIUpge8e8HOJFm5Ru	student
5	Test	test@test.com	1234	teacher
2	prabhat shukla	teacher@example.com	$2a$10$8RCjiqHSJalYY6vdapRrd.AJarvgzSJBYQCj1vBJGfIQ6luQNI2xC	teacher
4	prabhat shukla	prabhat@gmail.com	$2b$12$MndrsJybMPhkQASQLFD3pu77JhJLuuGSDDkoKb8lSTPOgrYznBQXK	student
8	test test	s@gmail.com	$2b$12$VNnEUNi6FOgVyuSUwM3DmuqJPmwVy9JZOdKdm0pWs0B2pVtQ1ALXK	student
\.


--
-- Name: assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.assignments_id_seq', 88, true);


--
-- Name: chapters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.chapters_id_seq', 822, true);


--
-- Name: curriculum_question_attempts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.curriculum_question_attempts_id_seq', 118, true);


--
-- Name: curriculum_unit_attempts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.curriculum_unit_attempts_id_seq', 14, true);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 16, true);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 13, true);


--
-- Name: grades_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.grades_id_seq', 12, true);


--
-- Name: learnings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.learnings_id_seq', 8099, true);


--
-- Name: lesson_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.lesson_types_id_seq', 36, true);


--
-- Name: questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.questions_id_seq', 1, true);


--
-- Name: student_answers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.student_answers_id_seq', 1, true);


--
-- Name: students_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.students_id_seq', 4, true);


--
-- Name: sub_lesson_type_master_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.sub_lesson_type_master_id_seq', 8, true);


--
-- Name: sub_lessons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.sub_lessons_id_seq', 107, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: prabhatshukla
--

SELECT pg_catalog.setval('public.users_id_seq', 8, true);


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: units chapters_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT chapters_pkey PRIMARY KEY (id);


--
-- Name: curriculum_question_attempts curriculum_question_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.curriculum_question_attempts
    ADD CONSTRAINT curriculum_question_attempts_pkey PRIMARY KEY (id);


--
-- Name: curriculum_question_attempts curriculum_question_attempts_unit_attempt_id_curriculum_que_key; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.curriculum_question_attempts
    ADD CONSTRAINT curriculum_question_attempts_unit_attempt_id_curriculum_que_key UNIQUE (unit_attempt_id, curriculum_question_id);


--
-- Name: curriculum_unit_attempts curriculum_unit_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.curriculum_unit_attempts
    ADD CONSTRAINT curriculum_unit_attempts_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: grades grades_grade_name_key; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_grade_name_key UNIQUE (grade_name);


--
-- Name: grades grades_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_pkey PRIMARY KEY (id);


--
-- Name: curriculum_questions learnings_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.curriculum_questions
    ADD CONSTRAINT learnings_pkey PRIMARY KEY (id);


--
-- Name: lesson_types lesson_types_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.lesson_types
    ADD CONSTRAINT lesson_types_pkey PRIMARY KEY (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: student_answers student_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.student_answers
    ADD CONSTRAINT student_answers_pkey PRIMARY KEY (id);


--
-- Name: student_answers student_answers_question_id_student_id_key; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.student_answers
    ADD CONSTRAINT student_answers_question_id_student_id_key UNIQUE (question_id, student_id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: students students_user_id_key; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_user_id_key UNIQUE (user_id);


--
-- Name: sub_lesson_type_master sub_lesson_type_master_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.sub_lesson_type_master
    ADD CONSTRAINT sub_lesson_type_master_pkey PRIMARY KEY (id);


--
-- Name: sub_lesson_type_master sub_lesson_type_master_type_name_key; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.sub_lesson_type_master
    ADD CONSTRAINT sub_lesson_type_master_type_name_key UNIQUE (type_name);


--
-- Name: sub_lessons sub_lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.sub_lessons
    ADD CONSTRAINT sub_lessons_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: curriculum_unit_attempts_student_unit_assignment_uniq; Type: INDEX; Schema: public; Owner: prabhatshukla
--

CREATE UNIQUE INDEX curriculum_unit_attempts_student_unit_assignment_uniq ON public.curriculum_unit_attempts USING btree (student_id, unit_id, assignment_id);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: prabhatshukla
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: prabhatshukla
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: idx_answers_student; Type: INDEX; Schema: public; Owner: prabhatshukla
--

CREATE INDEX idx_answers_student ON public.student_answers USING btree (student_id);


--
-- Name: idx_assignments_student; Type: INDEX; Schema: public; Owner: prabhatshukla
--

CREATE INDEX idx_assignments_student ON public.assignments USING btree (student_id);


--
-- Name: idx_questions_assignment; Type: INDEX; Schema: public; Owner: prabhatshukla
--

CREATE INDEX idx_questions_assignment ON public.questions USING btree (assignment_id);


--
-- Name: idx_sub_lessons_lesson_type; Type: INDEX; Schema: public; Owner: prabhatshukla
--

CREATE INDEX idx_sub_lessons_lesson_type ON public.sub_lessons USING btree (lesson_type_id);


--
-- Name: idx_units_sub_lesson; Type: INDEX; Schema: public; Owner: prabhatshukla
--

CREATE INDEX idx_units_sub_lesson ON public.units USING btree (sub_lesson_id);


--
-- Name: assignments assignments_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_lesson_id_fkey FOREIGN KEY (lesson_id) REFERENCES public.lesson_types(id) ON DELETE CASCADE;


--
-- Name: assignments assignments_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: assignments assignments_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: units chapters_sub_lesson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT chapters_sub_lesson_id_fkey FOREIGN KEY (sub_lesson_id) REFERENCES public.sub_lessons(id) ON DELETE CASCADE;


--
-- Name: curriculum_question_attempts curriculum_question_attempts_curriculum_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.curriculum_question_attempts
    ADD CONSTRAINT curriculum_question_attempts_curriculum_question_id_fkey FOREIGN KEY (curriculum_question_id) REFERENCES public.curriculum_questions(id) ON DELETE CASCADE;


--
-- Name: curriculum_question_attempts curriculum_question_attempts_unit_attempt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.curriculum_question_attempts
    ADD CONSTRAINT curriculum_question_attempts_unit_attempt_id_fkey FOREIGN KEY (unit_attempt_id) REFERENCES public.curriculum_unit_attempts(id) ON DELETE CASCADE;


--
-- Name: curriculum_unit_attempts curriculum_unit_attempts_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.curriculum_unit_attempts
    ADD CONSTRAINT curriculum_unit_attempts_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.assignments(id) ON DELETE CASCADE;


--
-- Name: curriculum_unit_attempts curriculum_unit_attempts_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.curriculum_unit_attempts
    ADD CONSTRAINT curriculum_unit_attempts_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: curriculum_unit_attempts curriculum_unit_attempts_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.curriculum_unit_attempts
    ADD CONSTRAINT curriculum_unit_attempts_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id) ON DELETE CASCADE;


--
-- Name: curriculum_questions learnings_chapter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.curriculum_questions
    ADD CONSTRAINT learnings_chapter_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id) ON DELETE CASCADE;


--
-- Name: lesson_types lesson_types_grade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.lesson_types
    ADD CONSTRAINT lesson_types_grade_id_fkey FOREIGN KEY (grade_id) REFERENCES public.grades(id) ON DELETE CASCADE;


--
-- Name: questions questions_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.assignments(id) ON DELETE CASCADE;


--
-- Name: student_answers student_answers_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.student_answers
    ADD CONSTRAINT student_answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


--
-- Name: student_answers student_answers_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.student_answers
    ADD CONSTRAINT student_answers_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: students students_grade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_grade_id_fkey FOREIGN KEY (grade_id) REFERENCES public.grades(id) ON DELETE SET NULL;


--
-- Name: students students_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: sub_lessons sub_lessons_lesson_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.sub_lessons
    ADD CONSTRAINT sub_lessons_lesson_type_id_fkey FOREIGN KEY (lesson_type_id) REFERENCES public.lesson_types(id) ON DELETE CASCADE;


--
-- Name: sub_lessons sub_lessons_sub_lesson_type_master_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: prabhatshukla
--

ALTER TABLE ONLY public.sub_lessons
    ADD CONSTRAINT sub_lessons_sub_lesson_type_master_id_fkey FOREIGN KEY (sub_lesson_type_master_id) REFERENCES public.sub_lesson_type_master(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

