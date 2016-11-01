

class flannel {
  if 'master' in $hostname {
    file { '/etc/flannel':
      ensure => directory
    }->
    file { '/etc/flannel/flannel-config.json':
      ensure => file,
      source => 'puppet:///modules/systemd/flannel-config.json'
    }->
    exec {'wait for etcd to become available':
      command => '/bin/bash -c "until /usr/bin/etcdctl set /coreos.com/network/config < /etc/flannel/flannel-config.json; do echo \"waiting for etcd to become available...\"; sleep 5; done"',
      unless  => '/usr/bin/etcdctl get /coreos.com/network/config',
    }
  }
  class {'releases::flannel':}->
  class {'systemd::flannel':}->
  service { 'flannel':
    ensure => running,
    enable => true,
    require => [Class['releases::flannel'], Class['systemd::flannel']]
  }
}