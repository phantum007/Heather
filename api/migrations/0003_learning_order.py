from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0002_question_order'),
    ]

    operations = [
        migrations.AddField(
            model_name='learning',
            name='order',
            field=models.PositiveIntegerField(blank=True, null=True),
        ),
    ]
