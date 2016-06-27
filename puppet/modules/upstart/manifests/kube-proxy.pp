

class upstart::kube-proxy {
  file {'/etc/default/kube-proxy':
    ensure => file,
    source => 'puppet:///modules/upstart/kube-proxy'
  }
  file {'/etc/init/kube-proxy.conf':
    ensure => file,
    source => 'puppet:///modules/upstart/kube-proxy.conf'
  }

}