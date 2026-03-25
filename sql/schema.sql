CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(180) NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('teacher', 'student'))
);

CREATE TABLE IF NOT EXISTS grades (
  id SERIAL PRIMARY KEY,
  grade_name VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS students (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  grade_id INT REFERENCES grades(id) ON DELETE SET NULL,
  first_name VARCHAR(120),
  last_name VARCHAR(120),
  date_of_birth DATE,
  father_name VARCHAR(120),
  mother_name VARCHAR(120),
  contact VARCHAR(40),
  profile_photo TEXT
);

ALTER TABLE students
  ADD COLUMN IF NOT EXISTS date_of_birth DATE;

CREATE TABLE IF NOT EXISTS lesson_types (
  id SERIAL PRIMARY KEY,
  grade_id INT NOT NULL REFERENCES grades(id) ON DELETE CASCADE,
  lesson_name VARCHAR(120) NOT NULL
);

CREATE TABLE IF NOT EXISTS sub_lesson_type_master (
  id SERIAL PRIMARY KEY,
  type_name VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS sub_lessons (
  id SERIAL PRIMARY KEY,
  lesson_type_id INT NOT NULL REFERENCES lesson_types(id) ON DELETE CASCADE,
  sub_lesson_type_master_id INT REFERENCES sub_lesson_type_master(id) ON DELETE SET NULL,
  sub_lesson_name VARCHAR(120) NOT NULL
);

ALTER TABLE sub_lessons
  ADD COLUMN IF NOT EXISTS sub_lesson_type_master_id INT REFERENCES sub_lesson_type_master(id) ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS chapters (
  id SERIAL PRIMARY KEY,
  sub_lesson_id INT NOT NULL REFERENCES sub_lessons(id) ON DELETE CASCADE,
  chapter_name VARCHAR(120) NOT NULL
);

CREATE TABLE IF NOT EXISTS learnings (
  id SERIAL PRIMARY KEY,
  chapter_id INT REFERENCES chapters(id) ON DELETE CASCADE,
  learning_text TEXT NOT NULL,
  answer_text TEXT
);

ALTER TABLE learnings
  ADD COLUMN IF NOT EXISTS chapter_id INT REFERENCES chapters(id) ON DELETE CASCADE;

ALTER TABLE learnings
  ADD COLUMN IF NOT EXISTS answer_text TEXT;

CREATE TABLE IF NOT EXISTS assignments (
  id SERIAL PRIMARY KEY,
  teacher_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  student_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  lesson_id INT NOT NULL REFERENCES lesson_types(id) ON DELETE CASCADE,
  assigned_date TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE assignments
  ADD COLUMN IF NOT EXISTS assignment_kind VARCHAR(20) NOT NULL DEFAULT 'homework';

ALTER TABLE assignments
  ADD COLUMN IF NOT EXISTS available_on DATE;

CREATE TABLE IF NOT EXISTS questions (
  id SERIAL PRIMARY KEY,
  assignment_id INT NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  correct_answer VARCHAR(120) NOT NULL
);

CREATE TABLE IF NOT EXISTS student_answers (
  id SERIAL PRIMARY KEY,
  question_id INT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  student_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  student_answer VARCHAR(120) NOT NULL,
  is_correct BOOLEAN NOT NULL,
  UNIQUE(question_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_assignments_student ON assignments(student_id);
CREATE INDEX IF NOT EXISTS idx_questions_assignment ON questions(assignment_id);
CREATE INDEX IF NOT EXISTS idx_answers_student ON student_answers(student_id);
CREATE INDEX IF NOT EXISTS idx_sub_lessons_lesson_type ON sub_lessons(lesson_type_id);
CREATE INDEX IF NOT EXISTS idx_chapters_sub_lesson ON chapters(sub_lesson_id);

ALTER TABLE learnings
  DROP COLUMN IF EXISTS unit_id;

DROP TABLE IF EXISTS units CASCADE;
