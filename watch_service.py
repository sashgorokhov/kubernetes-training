from __future__ import print_function

import json

import requests
import sys
import time
import subprocess

IP = sys.argv[1]
URL = 'http://{}/health'.format(IP)
SLEEP = 0.5

start = time.time()

print('URL: ' + URL)

print('Getting pods...')

pod_list = []

try:
    output = subprocess.check_output("kubectl --kubeconfig=/vagrant/kubernetes/kubeconfig get po -o json", shell=True)
except subprocess.CalledProcessError as e:
    print(e)
    print(e.output)
else:
    output = json.loads(output)
    output = output.get('items', [])
    pod_list = [(p['metadata']['name'], p['spec']['nodeName']) for p in output]

while True:
    st = time.time()
    print('{:<5.1f} '.format(time.time()-start), end='')
    sys.stdout.flush()
    try:
        response = requests.get(URL, timeout=5)
    except Exception as e:
        print('Error: ' + str(e))
    else:
        print(response.text, end='')
        for pod_name, node_name in pod_list:
            if pod_name in response.text:
                print(' --', node_name)
                break
        else:
            print(' -- unknown')
    delta = time.time() - st
    if delta < SLEEP:
        time.sleep(SLEEP-delta)