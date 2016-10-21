

class etcd::etcd {
  class {'releases::etcd':}
  class {'upstart::etcd':}
  service { 'etcd':
    ensure => running,
    enable => true,
    require => [Class['releases::etcd'], Class['upstart::etcd']]
  }#~>
  #exec {'ensure etcd is running':
  #  command => "/bin/bash -c \"until /usr/bin/curl -sL http://127.0.0.1:2379/health ; do /bin/echo \"Waiting for etcd\" /bin/sleep 1s; done\"",
  #}
}