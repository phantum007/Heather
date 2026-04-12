from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0013_toys_and_redemptions'),
    ]

    operations = [
        migrations.RunSQL(
            sql="ALTER TABLE assignments ADD COLUMN IF NOT EXISTS mode VARCHAR(20) NOT NULL DEFAULT 'sprint';",
            reverse_sql="ALTER TABLE assignments DROP COLUMN IF EXISTS mode;",
        ),
    ]
