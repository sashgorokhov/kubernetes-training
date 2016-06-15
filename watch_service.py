from __future__ import print_function

import requests
import sys

import time

IP = sys.argv[1]
URL = 'http://{}/health'.format(IP)

start = time.time()

print('URL: ' + URL)


while True:
    print('{:<5.2f} '.format(time.time()-start), end='')
    sys.stdout.flush()
    try:
        response = requests.get(URL, timeout=5)
    except Exception as e:
        print('Error: ' + str(e))
    else:
        print(response.text)