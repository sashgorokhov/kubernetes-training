import os
import time
import traceback

import bottle
import sys

from postgres import check_db, cursor_only


def create_table(curr):
    """:param curr psycopg2.extensions.cursor"""
    curr.execute('CREATE TABLE IF NOT EXISTS webapp_table (id serial PRIMARY KEY, key varchar(20), value varchar(20));')


def drop_table(curr):
    """:param curr psycopg2.extensions.cursor"""
    curr.execute('DROP TABLE IF EXISTS webapp_table;')


@bottle.get('/')
def index():
    return '<br>\n'.join('%s: %s' % (k, v) for k, v in sorted(os.environ.items(), key=lambda i: i[0]))


@bottle.get('/health')
def health():
    try:
        check_db()
    except Exception as e:
        return bottle.HTTPError(500, body=str(e))
    return 'OK ' + os.environ.get('HOSTNAME', 'unknown')


def request_wrapper(func):
    def wrapper(*args, **kwargs):
        try:
            with cursor_only() as curr:
                create_table(curr)
                return func(curr, *args, **kwargs) or ''
        except:
            return traceback.format_exception(*sys.exc_info())
    return wrapper


@bottle.get('/cpu_usage')
def cpu_usage():
    start = time.time()
    while True:
        if time.time() - start > 10.0:
            break
        time.time() ** 2
    return '{:.1f}s '.format(time.time() - start) + os.environ.get('HOSTNAME', 'unknown')


@bottle.get('/write/<key>/<value>')
@request_wrapper
def write(curr, key, value):
    curr.execute("INSERT INTO webapp_table (key, value) VALUES (%s, %s) RETURNING id;", (key, value))
    id = curr.fetchone()
    return str(id[0]) + '\n'


@bottle.get('/list')
@request_wrapper
def list_keys(curr):
    curr.execute("SELECT id, key, value FROM webapp_table")
    return '<br>\n'.join('[{}] {} = {}'.format(*i) for i in curr.fetchall()) + '\n'


@bottle.get('/get/<key>')
@request_wrapper
def get_key(curr, key):
    curr.execute('SELECT id, value FROM webapp_table WHERE key=%s', (key,))
    return '<br>\n'.join('[{}] {}'.format(*i) for i in curr.fetchall()) + '\n'


@bottle.get('/drop')
@request_wrapper
def drop_table_view(curr):
    drop_table(curr)


@bottle.get('/help')
def help():
    return """\
    /write/<key>/<value> -- returns inserted row id
    /list -- returns all key-value pairs in table
    /get/<key> -- return value of key
    /drop -- drops table
    / -- returns all environment variables
    """


def main():
    bottle.run(host='0.0.0.0', port=80)


if __name__ == '__main__':
    main()
