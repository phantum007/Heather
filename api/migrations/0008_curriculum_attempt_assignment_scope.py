from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0007_curriculum_unit_attempts'),
    ]

    operations = [
        migrations.AddField(
            model_name='curriculumunitattempt',
            name='assignment',
            field=models.ForeignKey(blank=True, db_column='assignment_id', null=True, on_delete=models.deletion.CASCADE, related_name='curriculum_unit_attempts', to='api.assignment'),
        ),
        migrations.RunSQL(
            sql="""
                ALTER TABLE curriculum_unit_attempts
                ADD COLUMN IF NOT EXISTS assignment_id INTEGER NULL REFERENCES assignments(id) ON DELETE CASCADE;

                ALTER TABLE curriculum_unit_attempts
                DROP CONSTRAINT IF EXISTS curriculum_unit_attempts_student_id_unit_id_key;

                CREATE UNIQUE INDEX IF NOT EXISTS curriculum_unit_attempts_student_unit_assignment_uniq
                ON curriculum_unit_attempts (student_id, unit_id, assignment_id);
            """,
            reverse_sql="""
                DROP INDEX IF EXISTS curriculum_unit_attempts_student_unit_assignment_uniq;

                ALTER TABLE curriculum_unit_attempts
                DROP COLUMN IF EXISTS assignment_id;

                ALTER TABLE curriculum_unit_attempts
                ADD CONSTRAINT curriculum_unit_attempts_student_id_unit_id_key UNIQUE (student_id, unit_id);
            """,
        ),
    ]
