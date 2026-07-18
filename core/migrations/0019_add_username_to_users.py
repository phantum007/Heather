from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0018_add_must_change_password'),
    ]

    operations = [
        migrations.RunSQL(
            sql='ALTER TABLE users ADD COLUMN username VARCHAR(60) DEFAULT NULL',
            reverse_sql='ALTER TABLE users DROP COLUMN username',
        ),
    ]
