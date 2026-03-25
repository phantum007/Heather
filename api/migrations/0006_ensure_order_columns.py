from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0005_rename_curriculum_tables'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                ALTER TABLE questions
                    ADD COLUMN IF NOT EXISTS "order" INTEGER;

                ALTER TABLE curriculum_questions
                    ADD COLUMN IF NOT EXISTS "order" INTEGER;
            """,
            reverse_sql="""
                ALTER TABLE curriculum_questions
                    DROP COLUMN IF EXISTS "order";

                ALTER TABLE questions
                    DROP COLUMN IF EXISTS "order";
            """,
        ),
    ]
