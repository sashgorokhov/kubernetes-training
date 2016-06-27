
class upstart::docker {
  file {'/etc/default/docker':
    name => '/etc/default/docker',
    path => '/etc/default/docker',
    ensure => file,
    source => 'puppet:///modules/upstart/docker',
    group => 'root',
    mode => '0755'
  }
}