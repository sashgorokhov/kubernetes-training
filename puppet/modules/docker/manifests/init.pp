

class docker {
  package {['apt-transport-https', 'ca-certificates', 'apparmor']:
    ensure => installed,
  }->
  exec {'add docker keys':
    command => '/usr/bin/apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D'
  }->
  file {'/etc/apt/sources.list.d/docker.list':
    ensure => file
  }->
  file_line {'add docker repo':
    path => '/etc/apt/sources.list.d/docker.list',
    line => 'deb https://apt.dockerproject.org/repo ubuntu-trusty main',
    ensure => present
  }->
  exec {'apt-get update':
    command => '/usr/bin/apt-get update'
  }->
  package {'docker-engine':
    ensure => installed
  }->
  group {'docker':
    ensure => present,
    members => ['vagrant']
  }->
  service {'docker':
    ensure => running,
    enable => true,
  }

}