class puppet::server {
  file { [ '/etc/puppet', '/etc/puppet/files' ]:
    ensure => directory,
  }->
  package { 'puppetserver':
    ensure => present,
  }

  file { '/etc/puppet/puppet.conf':
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    source  => 'puppet:///modules/puppet/puppet.conf',
    require => Package['puppetserver'],
  }

  file { '/etc/puppet/autosign.conf':
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    content => '*',
    require => Package['puppetserver'],
  }

  exec { 'change puppet memory usage':
    command => '/bin/sed -i "s/2g/256m/g" /etc/default/puppetserver',
    unless => '/bin/grep -q "-Xms256m -Xmx256m" /etc/default/puppetserver',
    require => Package['puppetserver']
  }
  service { 'puppetserver':
    enable => true,
    ensure => running,
    require => [Package['puppetserver'], File['/etc/puppet/puppet.conf'], File['/etc/puppet/autosign.conf'], Exec['change puppet memory usage']]
  }
}