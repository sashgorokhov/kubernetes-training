
class upstart::flanneld {
  file {'/etc/default/flanneld':
    ensure => file,
    source => 'puppet:///modules/upstart/flanneld'
  }
  file {'/etc/init/flanneld.conf':
    ensure => file,
    source => 'puppet:///modules/upstart/flanneld.conf'
  }

}