import os
from contextlib import contextmanager

import bottle
import time
import psycopg2


@contextmanager
def connection(user=None, password=None, host=None, database=None):
    """:rtype: psycopg2.extensions.connection"""
    conn = psycopg2.connect(user=user or os.environ.get('POSTGRES_USER'),
                            password=password or os.environ.get('POSTGRES_PASSWORD'),
                            host=host or os.environ.get(os.environ.get('POSTGRES_HOST_ENV_NAME', 'POSTGRES_HOST')),
                            database=database or os.environ.get('POSTGRES_DATABASE', os.environ.get('POSTGRES_USER')))
    """:type: psycopg2.extensions.connection"""
    try:
        yield conn
    finally:
        conn.close()


@contextmanager
def cursor(connection):
    """
    :param psycopg2.extensions.connection connection:
    :rtype: psycopg2.extensions.cursor
    """
    cursor = connection.cursor()  # type: psycopg2.extensions.cursor
    try:
        yield cursor
    finally:
        cursor.close()


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


@bottle.get('/')
def index():
    return '<br>\n'.join('%s: %s' % (k, v) for k, v in sorted(os.environ.items(), key=lambda i: i[0]))


@bottle.get('/health')
def health():
    return 'OK ' + os.environ.get('HOSTNAME', 'unknown')


@bottle.get('/cpu_usage')
def cpu_usage():
    start = time.time()
    while True:
        if time.time() - start > 10.0:
            break
        time.time() ** 2
    return '{:.1f}s '.format(time.time() - start) + os.environ.get('HOSTNAME', 'unknown')


def main():
    bottle.run(host='0.0.0.0', port=8080)


if __name__ == '__main__':
    main()
