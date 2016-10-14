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

file_line {'alias kubectl with kubeconfig':
  ensure => present,
  path => '/etc/bash.bashrc',
  line   => 'alias kubectl="kubectl --kubeconfig /etc/kubernetes/shared/kubeconfig"',
  require => File['/etc/bash.bashrc']
}

file_line {'alias kubectl to kube-system':
  ensure => present,
  path => '/etc/bash.bashrc',
  line   => 'alias kubectl-system="kubectl --namespace=kube-system"',
  require => File['/etc/bash.bashrc']
}

if 'master' in $hostname {
  class {'certs::apiserver':
    require => Class['certs::ca']
  }
  class {'etcd::etcd': }
}


class {'upstart::docker':
}->
class {'docker': }

class {'releases::kubernetes':}->
exec {'create kubeconfig':
  command => "/bin/bash /vagrant/kubernetes/create-kubeconfig.sh",
  require => [Class['certs::node']],
  unless => "/usr/bin/test -f /etc/kubernetes/shared/kubeconfig"
}

class {'upstart::kubelet':}->
service {'kubelet':
  ensure => running,
  enable => true,
  require => [Class['releases::kubernetes'], Class['docker']]
}
#
#
if $hostname == 'master1' {
  class {'docker::registry':
    require => Class['docker']
  }
#  class {'releases::heapster':}#->
#  #class {'heapster':
#  #  require => Class['upstart::kubelet']
#  #}->
#  class {'releases::stolon':}
}