import os
import re
from io import StringIO
from pathlib import Path

import psycopg2
from psycopg2 import sql


BASE_DIR = Path(__file__).resolve().parents[1]
ENV_PATH = BASE_DIR / '.env'
SCHEMA_DUMP_PATH = BASE_DIR / 'abacus_platform_2026-03-29_214930.sql'

TABLE_ORDER = [
    'django_content_type',
    'django_migrations',
    'django_session',
    'grades',
    'sub_lesson_type_master',
    'users',
    'lesson_types',
    'students',
    'sub_lessons',
    'units',
    'curriculum_questions',
    'assignments',
    'questions',
    'student_answers',
    'curriculum_unit_attempts',
    'curriculum_question_attempts',
]

SEQUENCE_SYNC_SQL = """
DO $$
DECLARE
    table_name text;
    seq_name text;
BEGIN
    PERFORM set_config('search_path', 'public', false);

    FOREACH table_name IN ARRAY ARRAY[
        'users',
        'students',
        'grades',
        'lesson_types',
        'sub_lesson_type_master',
        'sub_lessons',
        'units',
        'curriculum_questions',
        'assignments',
        'questions',
        'student_answers',
        'curriculum_unit_attempts',
        'curriculum_question_attempts',
        'django_content_type',
        'django_migrations'
    ]
    LOOP
        SELECT pg_get_serial_sequence(table_name, 'id') INTO seq_name;
        IF seq_name IS NOT NULL THEN
            EXECUTE format(
                'SELECT setval(%L, COALESCE((SELECT MAX(id) FROM %I), 1), COALESCE((SELECT MAX(id) FROM %I), 1) IS NOT NULL)',
                seq_name,
                table_name,
                table_name
            );
        END IF;
    END LOOP;
END $$;
"""


def load_dotenv() -> None:
    if not ENV_PATH.exists():
        return

    for raw_line in ENV_PATH.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith('#') or '=' not in line:
            continue
        key, value = line.split('=', 1)
        os.environ.setdefault(key.strip(), value.strip())


def railway_database_url() -> str:
    if os.getenv('RAILWAY_DATABASE_URL'):
        return os.environ['RAILWAY_DATABASE_URL']

    user = os.getenv('PGUSER') or 'postgres'
    password = os.getenv('PGPASSWORD') or 'faFzfZMjfiXifMdToeVbsDluGnbuKCnA'
    host = os.getenv('RAILWAY_SERVICE_POSTGRES_URL') or os.getenv('PGHOST') or 'ballast.proxy.rlwy.net'
    port = os.getenv('PGPORT') or '41912'
    name = os.getenv('PGDATABASE') or 'railway'
    sslmode = os.getenv('PGSSLMODE') or 'require'
    return f'postgresql://{user}:{password}@{host}:{port}/{name}?sslmode={sslmode}'


def target_database_url() -> str:
    database_url = os.getenv('DATABASE_URL')
    if not database_url:
        raise RuntimeError('DATABASE_URL must be set to the Neon target database.')
    return database_url


def schema_sql() -> str:
    raw_sql = SCHEMA_DUMP_PATH.read_text()
    return re.sub(r'^ALTER .* OWNER TO .*;\n', '', raw_sql, flags=re.MULTILINE)


def table_columns(connection, table_name: str) -> list[str]:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = 'public' AND table_name = %s
            ORDER BY ordinal_position
            """,
            [table_name],
        )
        return [row[0] for row in cursor.fetchall()]


def table_counts(connection) -> dict[str, int]:
    counts: dict[str, int] = {}
    with connection.cursor() as cursor:
        for table_name in TABLE_ORDER:
            cursor.execute(sql.SQL('SELECT COUNT(*) FROM {}').format(sql.Identifier(table_name)))
            counts[table_name] = cursor.fetchone()[0]
    return counts


def reset_target_schema(connection) -> None:
    connection.autocommit = True
    with connection.cursor() as cursor:
        cursor.execute('DROP SCHEMA IF EXISTS public CASCADE;')
        cursor.execute('CREATE SCHEMA public;')
        cursor.execute(schema_sql())


def copy_table_data(source_connection, target_connection, table_name: str) -> None:
    columns = table_columns(source_connection, table_name)
    column_list = sql.SQL(', ').join(sql.Identifier(column_name) for column_name in columns)
    ordered_columns = ', '.join(f'"{column_name}"' for column_name in columns)
    export_sql = sql.SQL('COPY (SELECT {} FROM {} ORDER BY 1) TO STDOUT WITH CSV').format(
        column_list,
        sql.Identifier('public', table_name),
    )
    import_sql = sql.SQL('COPY {} ({}) FROM STDIN WITH CSV').format(
        sql.Identifier('public', table_name),
        column_list,
    )

    buffer = StringIO()
    with source_connection.cursor() as source_cursor:
        source_cursor.copy_expert(export_sql.as_string(source_connection), buffer)

    if not buffer.getvalue():
        return

    buffer.seek(0)
    with target_connection.cursor() as target_cursor:
        target_cursor.copy_expert(import_sql.as_string(target_connection), buffer)

    print(f'Copied {table_name} columns: {ordered_columns}')


def main() -> None:
    load_dotenv()

    source_url = railway_database_url()
    target_url = target_database_url()

    with psycopg2.connect(target_url) as schema_connection:
        reset_target_schema(schema_connection)

    with psycopg2.connect(source_url) as source_connection, psycopg2.connect(target_url) as target_connection:
        source_counts = table_counts(source_connection)

        for table_name in TABLE_ORDER:
            copy_table_data(source_connection, target_connection, table_name)

        with target_connection.cursor() as cursor:
            cursor.execute(SEQUENCE_SYNC_SQL)
        target_connection.commit()

        target_counts = table_counts(target_connection)

    mismatches = [
        table_name
        for table_name in TABLE_ORDER
        if source_counts[table_name] != target_counts[table_name]
    ]

    print('Source counts:', source_counts)
    print('Target counts:', target_counts)

    if mismatches:
        raise RuntimeError(f'Row count mismatch after sync: {mismatches}')

    print('Railway to Neon sync completed successfully.')


if __name__ == '__main__':
    main()
