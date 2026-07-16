from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0017_add_voice_lang_name_to_speed_prefs'),
    ]

    operations = [
        migrations.AddField(
            model_name='studentspeedprefs',
            name='must_change_password',
            field=models.BooleanField(default=False),
        ),
    ]
