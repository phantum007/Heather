from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0008_curriculum_attempt_assignment_scope'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                ALTER TABLE students
                    ADD COLUMN IF NOT EXISTS first_name VARCHAR(120),
                    ADD COLUMN IF NOT EXISTS last_name VARCHAR(120),
                    ADD COLUMN IF NOT EXISTS date_of_birth DATE,
                    ADD COLUMN IF NOT EXISTS father_name VARCHAR(120),
                    ADD COLUMN IF NOT EXISTS mother_name VARCHAR(120),
                    ADD COLUMN IF NOT EXISTS contact VARCHAR(40),
                    ADD COLUMN IF NOT EXISTS profile_photo TEXT;
            """,
            reverse_sql="""
                ALTER TABLE students
                    DROP COLUMN IF EXISTS profile_photo,
                    DROP COLUMN IF EXISTS contact,
                    DROP COLUMN IF EXISTS mother_name,
                    DROP COLUMN IF EXISTS father_name,
                    DROP COLUMN IF EXISTS date_of_birth,
                    DROP COLUMN IF EXISTS last_name,
                    DROP COLUMN IF EXISTS first_name;
            """,
        ),
    ]
