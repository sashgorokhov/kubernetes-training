try:
    import deco
except ImportError:
    print('Package "deco" is not installed.\nInstall it:\npip install deco')
import requests
import sys

import time

IP = sys.argv[1]
URL = 'http://{}/cpu_usage'.format(IP)


@deco.concurrent
def load():
    return requests.get(URL)


@deco.synchronized
def loader():
    results = list()
    for i in range(50):
        results.append(load())
    return results


def main():
    while True:
        start = time.time()
        loader()
        #print('Executed: ' + str(loader()))
        delta = time.time() - start
        if delta < 1.0:
            time.sleep(1.0 - delta)

if __name__ == '__main__':
    main()