from __future__ import print_function

import requests
import sys

import time

IP = sys.argv[1]
URL = 'http://{}/health'.format(IP)
SLEEP = 0.5

start = time.time()

print('URL: ' + URL)


while True:
    st = time.time()
    print('{:<5.1f} '.format(time.time()-start), end='')
    sys.stdout.flush()
    try:
        response = requests.get(URL, timeout=5)
    except Exception as e:
        print('Error: ' + str(e))
    else:
        print(response.text)
    delta = time.time() - st
    if delta < SLEEP:
        time.sleep(SLEEP-delta)