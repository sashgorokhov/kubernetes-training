from __future__ import print_function

import random

import postgres
import time
import sys
import contextlib
import threading


TABLE_NAME = 'postgres_stolon_tests'
STOP = False
GLOBAL_START = time.time()
PRINT_LOCK = threading.Lock()


class throttle:
    def __init__(self, interval=1):
        """
        :param int|float interval:
        """
        self.interval = interval

    def __enter__(self):
        self.start = time.time()
        self.relative_start = self.start - GLOBAL_START

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.end = time.time()
        self.relative_end = self.end - GLOBAL_START
        self.delta = self.end - self.start
        if self.delta < self.interval:
            time.sleep(self.interval - self.delta)


def create_table(drop=True):
    with postgres.cursor_only() as curr:
        if drop:
            curr.execute('DROP TABLE IF EXISTS %s;' % TABLE_NAME)
        curr.execute('CREATE TABLE IF NOT EXISTS %s (id serial PRIMARY KEY, value varchar(20));' % TABLE_NAME)


def simple_infinite_select_test():
    global_start = time.time()

    while True:
        start = time.time()
        print(start - global_start, end=' ')
        try:
            postgres.list_tables()
        except KeyboardInterrupt:
            break
        except Exception as e:
            print(e)
        finally:
            delta = time.time() - start
            print(delta)
            sys.stdout.flush()
            if delta < 1:
                time.sleep(1 - delta)


def reader():
    last_value = None
    while not globals()['STOP']:
        thr = throttle(0.1)
        with thr:
            try:
                with postgres.cursor_only() as curr:
                    curr.execute('SELECT id,value FROM %s ORDER BY id DESC LIMIT 1;' % TABLE_NAME)
                    value = curr.fetchone()
                    if last_value and value == last_value:
                        continue
                    else:
                        last_value = value
            except Exception as e:
                value = str(e)
        with PRINT_LOCK:
            print('[reader] {thr.relative_end:<5.1f} {thr.delta:<5.1f} {0}'.format(value, thr=thr))
        sys.stdout.flush()
    print('[reader] exited')


def writer():
    while not globals()['STOP']:
        thr = throttle(0.5)
        with thr:
            randvalue = str(random.randint(1, 100000))
            try:
                with postgres.cursor_only() as curr:
                    curr.execute("INSERT INTO {} (value) VALUES ('{}') RETURNING id,value;".format(TABLE_NAME, randvalue))
                    value = curr.fetchone()
            except Exception as e:
                value = str(e)
        with PRINT_LOCK:
            print('[writer] {thr.relative_end:<5.1f} {thr.delta:<5.1f} {0}'.format(value, thr=thr))
        sys.stdout.flush()
    print('[writer] exited')


def readwrite_test():
    create_table()

    reader_thread = threading.Thread(target=reader)
    reader_thread.start()
    writer_thread = threading.Thread(target=writer)
    writer_thread.start()

    try:
        while True:
            with throttle():
                pass
    except:
        global STOP
        STOP = True



def main():
    import sys

    if len(sys.argv) > 1:
        globals()[sys.argv[1]]()
    else:
        print('Usage: tests.py <test function name>')


if __name__ == '__main__':
    main()
