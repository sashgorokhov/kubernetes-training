import os

from django.http import HttpResponse


def index(request):
    return HttpResponse('<br>'.join('%s: %s' % (k, v) for k, v in os.environ.items()))


def health(request):
    return HttpResponse('OK ' + os.environ.get('HOSTNAME', 'unknown'))