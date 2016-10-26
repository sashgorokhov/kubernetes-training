

class systemd::kubelet {
  file {'/etc/systemd/system/kubelet.service':
    ensure => file,
    source => 'puppet:///modules/systemd/kubelet.service'
  }
  if "master" in $hostname {
    file {'/etc/default/kubelet':
      ensure => file,
      source => 'puppet:///modules/systemd/kubelet-master',
      require => File['/etc/systemd/system/kubelet.service']
    }
  } else {
    file {'/etc/default/kubelet':
      ensure => file,
      source => 'puppet:///modules/systemd/kubelet-node',
      require => File['/etc/systemd/system/kubelet.service']
    }
  }
}