

class etcd::etcd {
  class {'releases::etcd':}
  class {'upstart::etcd':}
  service { 'etcd':
    ensure => running,
    enable => true,
    require => [Class['releases::etcd'], Class['upstart::etcd']]
  }
}