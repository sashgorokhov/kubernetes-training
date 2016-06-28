
class upstart::docker {
  file {'/etc/default/docker':
    ensure => file,
    source => 'puppet:///modules/upstart/docker',
    group => 'docker',
  }
}