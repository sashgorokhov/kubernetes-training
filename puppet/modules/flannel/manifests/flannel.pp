

class flannel::flannel {
  if 'master' in $hostname {
    file { '/etc/flannel':
      ensure => directory
    }->
    file { '/etc/flannel/flannel-config.json':
      ensure => file,
      source => 'puppet:///modules/upstart/flannel-config.json'
    }->
    exec { 'insert flannel configs to etcd':
      command => '/usr/bin/etcdctl set /coreos.com/network/config < /etc/flannel/flannel-config.json',
      unless  => '/usr/bin/etcdctl get /coreos.com/network/config',
    }
  }
  class {'upstart::flanneld':}->
  class {'releases::flannel':}->
  service { 'flanneld':
    ensure => running,
    enable => true,
    require => [Class['releases::flannel'], Class['upstart::flanneld']]
  }
}