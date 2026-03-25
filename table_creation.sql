-- USERS
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(180) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('teacher', 'student'))
);

-- GRADES
CREATE TABLE IF NOT EXISTS grades (
    id SERIAL PRIMARY KEY,
    grade_name VARCHAR(60) UNIQUE NOT NULL
);

-- LESSON TYPES
CREATE TABLE IF NOT EXISTS lesson_types (
    id SERIAL PRIMARY KEY,
    grade_id INTEGER NOT NULL REFERENCES grades(id) ON DELETE CASCADE,
    lesson_name VARCHAR(120) NOT NULL
);

-- SUB LESSON TYPE MASTER
CREATE TABLE IF NOT EXISTS sub_lesson_type_master (
    id SERIAL PRIMARY KEY,
    type_name VARCHAR(120) UNIQUE NOT NULL
);

-- SUB LESSONS
CREATE TABLE IF NOT EXISTS sub_lessons (
    id SERIAL PRIMARY KEY,
    lesson_type_id INTEGER NOT NULL REFERENCES lesson_types(id) ON DELETE CASCADE,
    sub_lesson_name VARCHAR(120) NOT NULL,
    sub_lesson_type_master_id INTEGER REFERENCES sub_lesson_type_master(id) ON DELETE SET NULL
);

-- UNITS
CREATE TABLE IF NOT EXISTS units (
    id SERIAL PRIMARY KEY,
    sub_lesson_id INTEGER NOT NULL REFERENCES sub_lessons(id) ON DELETE CASCADE,
    unit_name VARCHAR(120) NOT NULL
);

-- CURRICULUM QUESTIONS
CREATE TABLE IF NOT EXISTS curriculum_questions (
    id SERIAL PRIMARY KEY,
    question_text TEXT NOT NULL,
    unit_id INTEGER REFERENCES units(id) ON DELETE CASCADE,
    answer_text TEXT
);

-- STUDENTS
CREATE TABLE IF NOT EXISTS students (
    id SERIAL PRIMARY KEY,
    user_id INTEGER UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    grade_id INTEGER REFERENCES grades(id) ON DELETE SET NULL,
    first_name VARCHAR(120),
    last_name VARCHAR(120),
    father_name VARCHAR(120),
    mother_name VARCHAR(120),
    contact VARCHAR(40),
    profile_photo TEXT,
    date_of_birth DATE
);

-- ASSIGNMENTS
CREATE TABLE IF NOT EXISTS assignments (
    id SERIAL PRIMARY KEY,
    teacher_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    student_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    lesson_id INTEGER REFERENCES lesson_types(id) ON DELETE CASCADE,
    assigned_date TIMESTAMP DEFAULT NOW(),
    assignment_kind VARCHAR(20) DEFAULT 'homework',
    available_on DATE
);

-- QUESTIONS
CREATE TABLE IF NOT EXISTS questions (
    id SERIAL PRIMARY KEY,
    assignment_id INTEGER REFERENCES assignments(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    correct_answer VARCHAR(120) NOT NULL
);

-- STUDENT ANSWERS
CREATE TABLE IF NOT EXISTS student_answers (
    id SERIAL PRIMARY KEY,
    question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE,
    student_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    student_answer VARCHAR(120) NOT NULL,
    is_correct BOOLEAN NOT NULL,
    UNIQUE (question_id, student_id)
);
