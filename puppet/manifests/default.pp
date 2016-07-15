# sudo /opt/puppetlabs/bin/puppet apply --debug --modulepath=/vagrant/puppet/modules /vagrant/puppet/manifests/default.pp

#stage { 'pre': before => Stage['main'] }

class {'puppet::hosts':}

->
class {'certs::ca':}->
class {'certs::node':}


package {'bridge-utils':
  ensure => present
}

file {'/etc/bash.bashrc':
  ensure => file
}

if $hostname != 'master' {
  file_line {'kubectl to master':
    ensure => present,
    path => '/etc/bash.bashrc',
    line   => 'alias kubectl="kubectl --kubeconfig /etc/kubernetes/shared/kubeconfig"',
    require => File['/etc/bash.bashrc']
  }
}

file_line {'kubectl-system':
  ensure => present,
  path => '/etc/bash.bashrc',
  line   => 'alias kubectl-system="kubectl --namespace=kube-system"',
  require => File['/etc/bash.bashrc']
}

if $hostname == 'master' {
  class {'certs::apiserver':
    require => Class['certs::ca']
  }
  class {'upstart::etcd':}
  class {'releases::etcd':}
  service { 'etcd':
    ensure => running,
    enable => true,
    require => [Class['releases::etcd'], Class['upstart::etcd']]
  }~>
  exec {'wait etcd to start':
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
  }
  class {'upstart::flanneld':
    require => Service['etcd']
  }
  class {'releases::flannel':}
  service { 'flanneld':
    ensure => running,
    enable => true,
    require => [Service['etcd'], Class['releases::flannel'], Class['upstart::flanneld'], Exec['insert flannel configs to etcd']]
  }
} else {
  class {'upstart::flanneld':}
  class {'releases::flannel':}
  service {'flanneld':
    ensure => running,
    enable => true,
    require => [Class['releases::flannel'], Class['upstart::flanneld']]
  }
}


class {'upstart::docker':
}->
class {'docker':
  require => [Service['flanneld'], Class['upstart::docker']]
}

class {'releases::kubernetes':}->
exec {'create kubeconfig':
  command => "/bin/bash /vagrant/kubernetes/create-kubeconfig.sh",
  require => [Class['certs::node']],
  unless => "/usr/bin/test -f /etc/kubernetes/shared/kubeconfig"
}

if $hostname == 'master' {
  class {'docker::registry':
    require => Class['docker']
  }
  class {'releases::heapster':}
  class {'heapster':
    require => Class['docker::registry']
  }
}


class {'upstart::kubelet':}->
service {'kubelet':
  ensure => running,
  enable => true,
  require => [Class['releases::kubernetes'], Class['docker']]
}