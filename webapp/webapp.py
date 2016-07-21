import os
import time
import bottle
from postgres import check_db


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


@bottle.get('/cpu_usage')
def cpu_usage():
    start = time.time()
    while True:
        if time.time() - start > 10.0:
            break
        time.time() ** 2
    return '{:.1f}s '.format(time.time() - start) + os.environ.get('HOSTNAME', 'unknown')


def main():
    bottle.run(host='0.0.0.0', port=80)


if __name__ == '__main__':
    main()
