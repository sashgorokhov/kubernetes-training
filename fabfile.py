import pprint

from fabric.context_managers import settings
from fabric.decorators import task
from fabric.operations import local, run
from fabric.state import env
from fabric.tasks import execute


def config():
    """Return vagrant ssh-config as dict"""
    with settings(warn_only=True):
        output = local('vagrant ssh-config', capture=True)
    conf = dict()
    current_host = None
    for line in output.split('\n'):
        line = line.strip()
        if not line:
            continue
        key, value = line.split(' ', 1)
        if key == 'Host':
            current_host = value
            conf[current_host] = dict()
        if value.startswith('"') and value.endswith('"'):
            value = value[1:-1]
        conf[current_host][key] = value
    return conf


def configure(host):
    print('Using node: %s' % host)
    conf = config()[host]
    env['VAGRANT'] = conf
    env['user'] = conf['User']
    env['key_filename'] = conf['IdentityFile']
    env['hosts'] = ['{HostName}:{Port}'.format(**conf)]


@task
def master():
    configure('master')


@task
def node(num):
    configure('node-'+str(num))

@task
def fix_docker_bridge():
    run('bash /vagrant/kubernetes/system/fix_docker_bridge.sh')