from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0006_ensure_order_columns'),
    ]

    operations = [
        migrations.CreateModel(
            name='CurriculumUnitAttempt',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('status', models.CharField(choices=[('in_progress', 'In Progress'), ('passed', 'Passed'), ('failed', 'Failed')], default='in_progress', max_length=20)),
                ('elapsed_seconds', models.PositiveIntegerField(default=0)),
                ('correct_count', models.PositiveIntegerField(default=0)),
                ('wrong_count', models.PositiveIntegerField(default=0)),
                ('completed_at', models.DateTimeField(blank=True, null=True)),
                ('updated_at', models.DateTimeField()),
                ('created_at', models.DateTimeField()),
            ],
            options={
                'db_table': 'curriculum_unit_attempts',
                'managed': False,
            },
        ),
        migrations.RunSQL(
            sql="""
                CREATE TABLE IF NOT EXISTS curriculum_unit_attempts (
                    id BIGSERIAL PRIMARY KEY,
                    student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                    unit_id INTEGER NOT NULL REFERENCES units(id) ON DELETE CASCADE,
                    status VARCHAR(20) NOT NULL DEFAULT 'in_progress',
                    elapsed_seconds INTEGER NOT NULL DEFAULT 0,
                    correct_count INTEGER NOT NULL DEFAULT 0,
                    wrong_count INTEGER NOT NULL DEFAULT 0,
                    completed_at TIMESTAMP NULL,
                    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
                    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                    UNIQUE (student_id, unit_id)
                );
            """,
            reverse_sql="DROP TABLE IF EXISTS curriculum_unit_attempts CASCADE;",
        ),
        migrations.CreateModel(
            name='CurriculumQuestionAttempt',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('student_answer', models.TextField()),
                ('is_correct', models.BooleanField()),
                ('attempted_at', models.DateTimeField()),
            ],
            options={
                'db_table': 'curriculum_question_attempts',
                'managed': False,
            },
        ),
        migrations.RunSQL(
            sql="""
                CREATE TABLE IF NOT EXISTS curriculum_question_attempts (
                    id BIGSERIAL PRIMARY KEY,
                    unit_attempt_id BIGINT NOT NULL REFERENCES curriculum_unit_attempts(id) ON DELETE CASCADE,
                    curriculum_question_id INTEGER NOT NULL REFERENCES curriculum_questions(id) ON DELETE CASCADE,
                    student_answer TEXT NOT NULL,
                    is_correct BOOLEAN NOT NULL,
                    attempted_at TIMESTAMP NOT NULL DEFAULT NOW(),
                    UNIQUE (unit_attempt_id, curriculum_question_id)
                );
            """,
            reverse_sql="DROP TABLE IF EXISTS curriculum_question_attempts CASCADE;",
        ),
    ]
