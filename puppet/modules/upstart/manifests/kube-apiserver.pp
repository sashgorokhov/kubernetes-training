

class upstart::kube-apiserver {
  file {'/etc/default/kube-apiserver':
    ensure => file,
    source => 'puppet:///modules/upstart/kube-apiserver'
  }
  file {'/etc/init/kube-apiserver.conf':
    ensure => file,
    source => 'puppet:///modules/upstart/kube-apiserver.conf'
  }

}