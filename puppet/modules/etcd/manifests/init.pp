

class etcd {
  file {'/etc/default/etcd':
    ensure => file,
    source => 'puppet:///modules/systemd/etcd'
  }->
  package {'etcd':
    ensure => present
  }->
  service {'etcd':
    ensure => running,
    enable => true,
  }
}