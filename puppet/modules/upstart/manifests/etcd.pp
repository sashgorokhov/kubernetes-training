

class upstart::etcd {
  file {'/etc/default/etcd':
    ensure => file,
    source => 'puppet:///modules/upstart/etcd'
  }
  file {'/etc/init/etcd.conf':
    ensure => file,
    source => 'puppet:///modules/upstart/etcd.conf'
  }
}