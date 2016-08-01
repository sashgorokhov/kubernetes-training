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

file_line {"enable br_netfilter on startup":
  ensure => present,
  path => '/etc/modules',
  line => "br_netfilter"
}

exec {"enable br_netfilter":
  command => "/sbin/modprobe br_netfilter",
  unless => "/sbin/lsmod | /bin/grep -q br_netfilter"
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
  package {"etcd":
    ensure => present,
  }
  file_line {"configure etcd LISTEN_CLIENT_URLS":
    ensure => present,
    path => '/etc/default/etcd',
    line => 'ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379,http://0.0.0.0:4001"'
  }->
  file_line {"configure etcd ADVERTISE_CLIENT_URLS":
    ensure => present,
    path => '/etc/default/etcd',
    line => 'ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379,http://0.0.0.0:4001"'
  }
  service {'etcd':
    ensure => running,
    enable => true,
    subscribe => [File_line["configure etcd LISTEN_CLIENT_URLS"], File_line["configure etcd ADVERTISE_CLIENT_URLS"]],
    require => Package['etcd']
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
#  class {'upstart::flanneld':
#    require => Service['etcd']
#  }
  class {'releases::flannel':}
#  service { 'flanneld':
#    ensure => running,
#    enable => true,
#    require => [Service['etcd'], Class['releases::flannel'], Class['upstart::flanneld'], Exec['insert flannel configs to etcd']]
#  }
}# else {
#  class {'upstart::flanneld':}
#  class {'releases::flannel':}
#  service {'flanneld':
#    ensure => running,
#    enable => true,
#    require => [Class['releases::flannel'], Class['upstart::flanneld']]
#  }
#}


#class {'upstart::docker':
#}->
class {'docker': }

#class {'releases::kubernetes':}->
#exec {'create kubeconfig':
#  command => "/bin/bash /vagrant/kubernetes/create-kubeconfig.sh",
#  require => [Class['certs::node']],
#  unless => "/usr/bin/test -f /etc/kubernetes/shared/kubeconfig"
#}


#class {'upstart::kubelet':}->
#service {'kubelet':
#  ensure => running,
#  enable => true,
#  require => [Class['releases::kubernetes'], Class['docker']]
#}


#if $hostname == 'master' {
#  class {'docker::registry':
#    require => Class['docker']
#  }->
#  class {'releases::heapster':}->
#  class {'heapster':
#    require => Class['upstart::kubelet']
#  }->
#  class {'releases::stolon':}
#}