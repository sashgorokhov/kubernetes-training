

class docker::registry {
  exec {'start docker registry':
    command => '/usr/bin/docker run -d -p 5000:5000 -v /mnt/registry:/var/lib/registry --restart=always --name registry registry:2',
    unless => '/usr/bin/docker ps | /bin/grep -q registry'
  }
}