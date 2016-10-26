
class systemd::flannel {
  file {'/etc/systemd/system/flannel.service':
    ensure => file,
    source => 'puppet:///modules/systemd/flannel.service'
  }
}