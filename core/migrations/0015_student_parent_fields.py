from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0014_assignment_mode'),
    ]

    operations = [
        migrations.AddField(
            model_name='studentprofile',
            name='parent_email',
            field=models.EmailField(blank=True, max_length=180, null=True),
        ),
        migrations.AddField(
            model_name='studentprofile',
            name='parent_address',
            field=models.TextField(blank=True, null=True),
        ),
        migrations.RunSQL(
            sql="""
                ALTER TABLE students
                    ADD COLUMN IF NOT EXISTS parent_email VARCHAR(180),
                    ADD COLUMN IF NOT EXISTS parent_address TEXT;
            """,
            reverse_sql="""
                ALTER TABLE students
                    DROP COLUMN IF EXISTS parent_email,
                    DROP COLUMN IF EXISTS parent_address;
            """,
        ),
    ]
