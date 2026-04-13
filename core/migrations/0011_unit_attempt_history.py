from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0010_sync_primary_key_sequences'),
    ]

    operations = [
        migrations.AddField(
            model_name='curriculumunitattempt',
            name='attempt_number',
            field=models.PositiveIntegerField(default=1),
        ),
        migrations.RunSQL(
            sql="""
                ALTER TABLE curriculum_unit_attempts
                  ADD COLUMN IF NOT EXISTS attempt_number INT NOT NULL DEFAULT 1;

                DROP INDEX IF EXISTS curriculum_unit_attempts_student_unit_assignment_uniq;
            """,
            reverse_sql="""
                ALTER TABLE curriculum_unit_attempts
                  DROP COLUMN IF EXISTS attempt_number;

                CREATE UNIQUE INDEX IF NOT EXISTS curriculum_unit_attempts_student_unit_assignment_uniq
                  ON curriculum_unit_attempts (student_id, unit_id, assignment_id);
            """,
        ),
    ]
