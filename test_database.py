from __future__ import print_function
import sys
import time
import uuid

import requests

IP = sys.argv[1]
PREFIX = 'http://' + IP
SLEEP = 0.5

start = time.time()


def drop():
    response = requests.get(PREFIX + '/drop')
    #response.raise_for_status()
    return response


def write(key, value):
    response = requests.get(PREFIX + '/write/' + str(key) + '/' + str(value))
    #response.raise_for_status()
    return response


def read(key):
    response = requests.get(PREFIX + '/get/' + str(key))
    #response.raise_for_status()
    return response


drop()


USED_KEYS = set()


def read_write():
    while True:
        key = str(uuid.uuid4())[:20]
        if key in USED_KEYS:
            continue
        USED_KEYS.add(key)
        break
    value = str(uuid.uuid4())[:20]

    response = write(key, value)
    hostname_write = response.headers.get("HOSTNAME", "unknown")
    if response.status_code != 200:
        print('[%s] WRITE failed with code %s' % (hostname_write, response.status_code), end='')
        print(response.text)
        return
    row_id = response.text.strip()

    response = read(key)
    hostname_read = response.headers.get("HOSTNAME", "unknown")
    if response.status_code != 200:
        print('[%s] READ failed with code %s' % (hostname_read, response.status_code), end='')
        print(response.text)
        return
    text = response.text.strip()
    if value not in text:
        print('[%s] READ failed: inserted value not found' % hostname_read, end='')
    print('[%s] - [%s] OK' % (hostname_write, hostname_read), end='')


while True:
    st = time.time()
    print('{:<5.1f} '.format(time.time()-start), end='')
    sys.stdout.flush()
    try:
        read_write()
    except Exception as e:
        print('Error: ' + str(e), end='')
    finally:
        print()
    sys.stdout.flush()
    delta = time.time() - st
    if delta < SLEEP:
        time.sleep(SLEEP-delta)
