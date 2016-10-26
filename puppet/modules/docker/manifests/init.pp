

class docker {
  file {'/etc/systemd/system/docker.service.d':
    ensure => directory
  }->
  file {'/etc/systemd/system/docker.service.d/docker-flannel.conf':
    ensure => file,
    source => 'puppet:///modules/systemd/docker-flannel.conf'
  }->
  package {"docker.io":
    ensure => present
  }->
  service {'docker':
    ensure => running,
    enable => true,
  }
}