
stage { 'pre': before => Stage['main'] }

class {'puppet::hosts': stage => 'pre'}

package {'bridge-utils':
  ensure => present
}

class {'releases':}

file {'/etc/bash.bashrc':
  ensure => file
}

if $hostname != 'master' {
  file_line {'kubectl to master':
    ensure => present,
    path => '/etc/bash.bashrc',
    line   => 'alias kubectl="kubectl --server http://master:8080"',
    require => File['/etc/bash.bashrc']
  }
}

file_line {'kubectl-system':
  ensure => present,
  path => '/etc/bash.bashrc',
  line   => 'alias kubectl-system="kubectl --namespace=kube-system"',
  require => File['/etc/bash.bashrc']
}


class {'upstart':
  require => Class['releases']
}

if $hostname == 'master' {
  class { 'upstart::master':
    require => Class['releases']
  }->
  service { 'etcd':
    ensure => running,
    enable => true
  }~>
  exec { 'wait etcd to start':
    command     => '/bin/sleep 8s',
    refreshonly => true
  }

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
    require => Service['etcd'],
  }->
  service { 'flanneld':
    ensure => running,
    enable => true,
    require => Class['upstart']
  }
} else {
  service {'flanneld':
    ensure => running,
    enable => true,
    require => Class['upstart']
  }
}


#
#class {'docker':
#  require => Service['flanneld']
#}
#
#if $hostname == 'puppet' {
#  service {'kube-apiserver':
#    ensure => running,
#    enable => true,
#    require => Class['docker']
#  }->
#  exec {'label master node':
#    command => '/bin/sleep 5s && /usr/bin/kubectl label nodes puppet --overwrite node=master',
#    unless => '/usr/bin/kubectl get no -l node=master | /bin/grep -q master',
#  }
#
#  #class {'heapster':
#  #  require => Class['releases::heapster']
#  #}
#
#}
#
#service {'kubelet':
#  ensure => running,
#  enable => true,
#  require => Class['docker']
#}
#service {'kube-proxy':
#  ensure => running,
#  enable => true,
#  require => Class['docker']
#}
#