-- USERS
INSERT INTO users (id, name, email, password, role) VALUES
(2, 'ps', 'teacher@example.com', '$2a$10$8RCjiqHSJalYY6vdapRrd.AJarvgzSJBYQCj1vBJGfIQ6luQNI2xC', 'teacher'),
(3, 't1 t1', 't1@gmail.com', '$2b$12$DmgVx9KFUXoFIi1prcRwQOyyhKYLv7Q1.gCKcIUpge8e8HOJFm5Ru', 'student'),
(4, 'prabhat shukla', 'prabhat@gmail.com', '$2b$12$MndrsJybMPhkQASQLFD3pu77JhJLuuGSDDkoKb8lSTPOgrYznBQXK', 'student'),
(5, 'Test', 'test@test.com', '1234', 'teacher');

-- GRADES
INSERT INTO grades (id, grade_name) VALUES
(9, '10'),
(10, '9');

-- LESSON TYPES
INSERT INTO lesson_types (id, grade_id, lesson_name) VALUES
(13, 9, '1'),
(14, 9, '2'),
(15, 10, '1');

-- SUB LESSON TYPE MASTER
INSERT INTO sub_lesson_type_master (id, type_name) VALUES
(1, 'Reading Abacus'),
(2, 'Listening Abacus'),
(3, 'Listening Anzan'),
(4, 'Flash Anzan'),
(5, 'Multiplication Abacus'),
(6, 'Multiplication Anzan'),
(7, 'Division Abacus'),
(8, 'Division Anzan');

-- SUB LESSONS
INSERT INTO sub_lessons (id, lesson_type_id, sub_lesson_name, sub_lesson_type_master_id) VALUES
(3, 13, 'Reading Abacus', 1),
(4, 14, 'Reading Abacus', 1),
(5, 14, 'Listening Abacus', 2),
(6, 15, 'Reading Abacus', 1),
(7, 15, 'Listening Abacus', 2);

-- UNITS
INSERT INTO units (id, sub_lesson_id, unit_name) VALUES
(3, 3, '1'),
(4, 3, '2'),
(5, 4, '1'),
(7, 5, '1'),
(9, 6, '1'),
(10, 7, '1');

-- CURRICULUM QUESTIONS
INSERT INTO curriculum_questions (id, question_text, unit_id, answer_text) VALUES
(4, '1+2+3', 3, '6'),
(5, '2+1+4', 3, '7'),
(6, '1+2', 4, '3'),
(7, '1+2', 7, '3');

-- STUDENTS
INSERT INTO students (id, user_id, grade_id, first_name, last_name, father_name, mother_name, contact, profile_photo, date_of_birth) VALUES
(3, 4, NULL, 'prabhat', 'shukla', 'fn', 'mn', '0123456789', 'student_profiles/241abdc481054099aabf542290650800.png', NULL),
(2, 3, NULL, 't1', 't1', 'ft1', 'mt1', '0123456789', 'student_profiles/fbaadbe8508949b5872efa28d94f1b28.png', NULL);

-- ASSIGNMENTS
INSERT INTO assignments (id, teacher_id, student_id, lesson_id, assigned_date, assignment_kind, available_on) VALUES
(7, 2, 4, 13, '2026-03-24 00:40:32', 'homework', '2026-03-24'),
(8, 2, 4, 14, '2026-03-24 00:40:32', 'homework', '2026-03-24'),
(9, 2, 4, 13, '2026-03-24 00:42:56', 'classroom', '2026-03-24'),
(10, 2, 4, 14, '2026-03-24 00:42:56', 'classroom', '2026-03-24');

DELETE FROM users WHERE email = 'test@test.com';
