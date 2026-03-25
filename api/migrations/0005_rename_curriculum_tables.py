from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0004_drop_deprecated_units'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                ALTER TABLE IF EXISTS chapters RENAME TO units;
                ALTER TABLE IF EXISTS units RENAME COLUMN chapter_name TO unit_name;

                ALTER TABLE IF EXISTS learnings RENAME TO curriculum_questions;
                ALTER TABLE IF EXISTS curriculum_questions RENAME COLUMN chapter_id TO unit_id;
                ALTER TABLE IF EXISTS curriculum_questions RENAME COLUMN learning_text TO question_text;

                ALTER INDEX IF EXISTS idx_chapters_sub_lesson RENAME TO idx_units_sub_lesson;
            """,
            reverse_sql="""
                ALTER INDEX IF EXISTS idx_units_sub_lesson RENAME TO idx_chapters_sub_lesson;

                ALTER TABLE IF EXISTS curriculum_questions RENAME COLUMN question_text TO learning_text;
                ALTER TABLE IF EXISTS curriculum_questions RENAME COLUMN unit_id TO chapter_id;
                ALTER TABLE IF EXISTS curriculum_questions RENAME TO learnings;

                ALTER TABLE IF EXISTS units RENAME COLUMN unit_name TO chapter_name;
                ALTER TABLE IF EXISTS units RENAME TO chapters;
            """,
        ),
    ]
