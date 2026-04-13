from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0012_student_coins'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                CREATE TABLE IF NOT EXISTS toys (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(120) NOT NULL,
                    image TEXT,
                    coin_value INT NOT NULL DEFAULT 1,
                    created_at TIMESTAMP NOT NULL DEFAULT NOW()
                );

                CREATE TABLE IF NOT EXISTS toy_redemptions (
                    id SERIAL PRIMARY KEY,
                    student_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                    toy_id INT NOT NULL REFERENCES toys(id) ON DELETE CASCADE,
                    coins_spent INT NOT NULL,
                    redeemed_at TIMESTAMP NOT NULL DEFAULT NOW()
                );

                CREATE INDEX IF NOT EXISTS idx_toy_redemptions_student ON toy_redemptions(student_id);
            """,
            reverse_sql="""
                DROP TABLE IF EXISTS toy_redemptions;
                DROP TABLE IF EXISTS toys;
            """,
        ),
    ]
