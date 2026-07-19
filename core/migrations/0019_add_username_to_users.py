from django.db import migrations


def _add_username_column(apps, schema_editor):
    try:
        schema_editor.execute(
            'ALTER TABLE users ADD COLUMN username VARCHAR(60) DEFAULT NULL'
        )
    except Exception:
        pass  # table doesn't exist in test env (managed=False)


def _remove_username_column(apps, schema_editor):
    try:
        schema_editor.execute('ALTER TABLE users DROP COLUMN username')
    except Exception:
        pass


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0018_add_must_change_password'),
    ]

    operations = [
        migrations.RunPython(_add_username_column, _remove_username_column),
    ]
