from __future__ import print_function

from multiprocessing.pool import ThreadPool

import requests
import time

import sys

try:
    import pykube
except ImportError:
    print('Package "pykube" is not installed.\nInstall it:\npip install pykube')

SLEEP = 2

api = pykube.HTTPClient(pykube.KubeConfig.from_file("/vagrant/kubernetes/kubeconfig"))

webapp_sercvice_ip = pykube.Service.objects(api).get_by_name("webapp-service").obj['spec']['clusterIP']

start = time.time()

cpu_url = 'http://%s/cpu_usage' % webapp_sercvice_ip
print('Cpu usage url: ' + cpu_url)


def run_usage():
    pool = ThreadPool(4)
    responses = pool.map(lambda *args, **kwargs: requests.get(cpu_url), range(4))
    pool.close()
    pool.join()
    return ', '.join(set(map(lambda response: response.headers.get("HOSTNAME", "unknown"), responses)))


def main():
    while True:
        st = time.time()
        print('{:<5.1f} '.format(time.time() - start), end='')
        sys.stdout.flush()

        print(run_usage())

        delta = time.time() - st
        if delta < SLEEP:
            time.sleep(SLEEP - delta)


if __name__ == '__main__':
    main()