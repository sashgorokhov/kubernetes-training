
class upstart::kubelet {
  file {'/etc/default/kubelet':
    ensure => file,
    source => 'puppet:///modules/upstart/kubelet'
  }->
  exec {'set node ip':
    command => "/bin/sed -i /etc/default/kubelet -e 's/NODE_IP/${puppet::hosts::hosts[$hostname]}/'",
    onlyif => "/bin/grep -q NODE_IP /etc/default/kubelet"
  }
  file {'/etc/init/kubelet.conf':
    ensure => file,
    source => 'puppet:///modules/upstart/kubelet.conf'
  }

}