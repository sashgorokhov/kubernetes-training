

class upstart::etcd {
  file {'/etc/default/etcd':
    ensure => file,
    content => epp('etcd/etcd.epp', {"hostname" => "${hostname}", "host" => "${hostname}.${domain}", "ip" => "${puppet::hosts::hosts[$hostname]}"})
  }
  file {'/etc/init/etcd.conf':
    ensure => file,
    source => 'puppet:///modules/upstart/etcd.conf'
  }
}