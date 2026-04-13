from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0011_unit_attempt_history'),
    ]

    operations = [
        migrations.AddField(
            model_name='studentprofile',
            name='coins',
            field=models.PositiveIntegerField(default=0),
        ),
        migrations.RunSQL(
            sql='ALTER TABLE students ADD COLUMN IF NOT EXISTS coins INT NOT NULL DEFAULT 0;',
            reverse_sql='ALTER TABLE students DROP COLUMN IF EXISTS coins;',
        ),
    ]
