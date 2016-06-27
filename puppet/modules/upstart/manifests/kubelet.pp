
class upstart::kubelet {
  file {'/etc/default/kubelet':
    ensure => file,
    source => 'puppet:///modules/upstart/kubelet'
  }
  file {'/etc/init/kubelet.conf':
    ensure => file,
    source => 'puppet:///modules/upstart/kubelet.conf'
  }

}