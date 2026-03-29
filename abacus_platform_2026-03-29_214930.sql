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

