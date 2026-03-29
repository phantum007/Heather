from django.db import migrations


SEQUENCE_SYNC_SQL = """
DO $$
DECLARE
    table_name text;
    seq_name text;
BEGIN
    FOREACH table_name IN ARRAY ARRAY[
        'users',
        'students',
        'grades',
        'lesson_types',
        'sub_lesson_type_master',
        'sub_lessons',
        'units',
        'curriculum_questions',
        'assignments',
        'questions',
        'student_answers',
        'curriculum_unit_attempts',
        'curriculum_question_attempts'
    ]
    LOOP
        SELECT pg_get_serial_sequence(table_name, 'id') INTO seq_name;
        IF seq_name IS NOT NULL THEN
            EXECUTE format(
                'SELECT setval(%L, COALESCE((SELECT MAX(id) FROM %I), 1), COALESCE((SELECT MAX(id) FROM %I), 1) IS NOT NULL)',
                seq_name,
                table_name,
                table_name
            );
        END IF;
    END LOOP;
END $$;
"""


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0009_ensure_student_profile_columns'),
    ]

    operations = [
        migrations.RunSQL(
            sql=SEQUENCE_SYNC_SQL,
            reverse_sql=migrations.RunSQL.noop,
        ),
    ]
