from __future__ import print_function

import sys
import time

try:
    import pykube
except ImportError:
    print('Package "pykube" is not installed.\nInstall it:\npip install pykube')

import requests

SLEEP = 0.5

api = pykube.HTTPClient(pykube.KubeConfig.from_file("/vagrant/kubernetes/kubeconfig"))

webapp_sercvice_ip = pykube.Service.objects(api).get_by_name("webapp-service").obj['spec']['clusterIP']

start = time.time()

health_url = 'http://%s/health' % webapp_sercvice_ip
print('Health url: ' + health_url)

pod_node_map = dict()


def update_pod_node_map():
    pod_node_map.clear()
    pods = pykube.Pod.objects(api).filter(selector="name=webapp")
    for pod in pods:
        pod_node_map[pod.obj['metadata']['name']] = pod.obj['spec']['nodeName']


update_pod_node_map()

while True:
    st = time.time()
    print('{:<5.1f} '.format(time.time() - start), end='')
    sys.stdout.flush()

    try:
        response = requests.get(health_url, timeout=5)
    except Exception as e:
        print('Error: ' + str(e))
    else:
        print(response.text, end='')

        pod_name = response.headers.get("HOSTNAME", "unknown")
        if pod_name != 'unknown':
            if pod_name not in pod_node_map:
                update_pod_node_map()
            if pod_name not in pod_node_map:
                print(' -- ' + pod_name)
            else:
                print(' -- ' + pod_node_map[pod_name])
        else:
            print(' -- ' + pod_name)

        delta = time.time() - st
        if delta < SLEEP:
            time.sleep(SLEEP - delta)
