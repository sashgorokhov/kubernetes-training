import os

import time
from django.http import HttpResponse


def index(request):
    return HttpResponse('<br>'.join('%s: %s' % (k, v) for k, v in os.environ.items()))


def health(request):
    return HttpResponse('OK ' + os.environ.get('HOSTNAME', 'unknown'))


def cpu_usage(request):
    start = time.time()
    while True:
        if time.time() - start > 10.0:
            break
        time.time()**2
    return HttpResponse('{:.1f}s '.format(time.time()-start) + os.environ.get('HOSTNAME', 'unknown'))
