import os
from contextlib import contextmanager

import psycopg2

POSTGRES_DEFAULT_USER = 'stolon'

POSTGRES_CONFIG = dict(user=os.environ.get('POSTGRES_USER', POSTGRES_DEFAULT_USER),
                       password=os.environ.get('POSTGRES_PASSWORD', os.environ.get('POSTGRES_USER', POSTGRES_DEFAULT_USER)),
                       host=os.environ.get(os.environ.get('POSTGRES_HOST_ENV_NAME', 'POSTGRES_HOST')),
                       database=os.environ.get('POSTGRES_DATABASE', os.environ.get('POSTGRES_USER', POSTGRES_DEFAULT_USER)))

print('Using config: {}'.format(POSTGRES_CONFIG))


@contextmanager
def connection():
    """:rtype: psycopg2.extensions.connection"""
    conn = psycopg2.connect(**POSTGRES_CONFIG)
    """:type: psycopg2.extensions.connection"""
    try:
        yield conn
    finally:
        conn.close()


@contextmanager
def cursor(connection, autocommit=True):
    """
    :param psycopg2.extensions.connection connection:
    :rtype: psycopg2.extensions.cursor
    """
    cursor = connection.cursor()  # type: psycopg2.extensions.cursor
    try:
        yield cursor
    finally:
        cursor.close()
    if autocommit:
        connection.commit()


@contextmanager
def cursor_only(*args, **kwargs):
    """:rtype: psycopg2.extensions.cursor"""
    with connection(*args, **kwargs) as conn:
        with cursor(conn) as curr:
            yield curr


def list_databases():
    with cursor_only() as curr:
        curr.execute('SELECT datname FROM pg_database WHERE datistemplate = false;')
        return [i[0] for i in curr.fetchall()]


def list_tables():
    with cursor_only() as curr:
        curr.execute('SELECT table_name FROM information_schema.tables ORDER BY table_schema,table_name;')
        return [i[0] for i in curr.fetchall()]


def check_db():
    with connection():
        pass

if __name__ == '__main__':
    import pprint

    pprint.pprint(list_databases())
    pprint.pprint(list_tables())