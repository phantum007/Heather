INSERT INTO grades (grade_name)
VALUES ('Grade 1'), ('Grade 2'), ('Grade 3')
ON CONFLICT (grade_name) DO NOTHING;

INSERT INTO lesson_types (grade_id, lesson_name)
VALUES
  (1, 'Addition Basics'),
  (1, 'Subtraction Basics'),
  (2, 'Two-Digit Addition'),
  (2, 'Two-Digit Subtraction'),
  (3, 'Mixed Arithmetic')
ON CONFLICT DO NOTHING;

INSERT INTO sub_lesson_type_master (type_name)
VALUES
  ('Reading Abacus'),
  ('Listening Abacus'),
  ('Listening Anzan'),
  ('Flash Anzan'),
  ('Multiplication Abacus'),
  ('Multiplication Anzan'),
  ('Division Abacus'),
  ('Division Anzan')
ON CONFLICT (type_name) DO NOTHING;
