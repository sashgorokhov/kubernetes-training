

class docker {
  file {'/etc/default/docker':
    ensure => file,
    source => 'puppet:///modules/upstart/docker'
  }->
  package {"docker.io":
    ensure => present
  }->
  service {'dockerq':
    ensure => running,
    enable => true,
  }
}