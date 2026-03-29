from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0003_learning_order'),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunSQL(
                    sql="""
                        DROP INDEX IF EXISTS idx_learnings_unit;
                        DROP INDEX IF EXISTS idx_units_chapter;
                        ALTER TABLE learnings DROP COLUMN IF EXISTS unit_id;
                        DROP TABLE IF EXISTS units CASCADE;
                    """,
                    reverse_sql="""
                        CREATE TABLE IF NOT EXISTS units (
                            id BIGSERIAL PRIMARY KEY,
                            chapter_id BIGINT NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
                            unit_name VARCHAR(120) NOT NULL
                        );
                        ALTER TABLE learnings
                            ADD COLUMN IF NOT EXISTS unit_id BIGINT REFERENCES units(id) ON DELETE CASCADE;
                        CREATE INDEX IF NOT EXISTS idx_units_chapter ON units(chapter_id);
                        CREATE INDEX IF NOT EXISTS idx_learnings_unit ON learnings(unit_id);
                    """,
                ),
            ],
            state_operations=[
                migrations.DeleteModel(
                    name='Unit',
                ),
            ],
        ),
    ]
