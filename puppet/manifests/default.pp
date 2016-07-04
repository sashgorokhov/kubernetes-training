# sudo /opt/puppetlabs/bin/puppet apply --debug --modulepath=/vagrant/puppet/modules /vagrant/puppet/manifests/default.pp

stage { 'pre': before => Stage['main'] }

class {'puppet::hosts': stage => 'pre'}

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

if $hostname == 'master' {
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

class {'releases::kubernetes':}

if $hostname == 'master' {
  class {'docker::registry':
    require => Class['docker']
  }
  class {'upstart::kube_apiserver':}
  service {'kube-apiserver':
    ensure => running,
    enable => true,
    require => [Service['etcd'], Class['releases::kubernetes']]
  }
  class {'releases::heapster':}->
  class {'heapster':
    require => Class['docker::registry']
  }
}

class {'upstart::kube_proxy':}->
service {'kube-proxy':
  ensure => running,
  enable => true,
  require => Class['releases::kubernetes']
}

class {'upstart::kubelet':}->
service {'kubelet':
  ensure => running,
  enable => true,
  require => [Class['releases::kubernetes'], Class['docker']]
}->
exec {'label node':
  command => "/usr/bin/kubectl --server http://master:8080 label nodes ${hostname} --overwrite node=${hostname}",
  unless => "/usr/bin/kubectl --server http://master:8080 get no -l node=${hostname} | /bin/grep -q ${hostname}",
}