class puppet::agent {
  group { 'puppet':
    ensure => present,
    members => ['vagrant', 'puppet']
  }

  package { 'puppet-agent':
    ensure => latest,
  }

  #exec { 'start_puppet':
  #  command => '/bin/sed -i /etc/default/puppet -e "s/START=no/START=yes/"',
  #  unless  => '/bin/grep START=yes /etc/default/puppet',
  #  require => Package['puppet-agent'],
  #  before  => Service['puppet'],
  #}~>
  #exec { 'enable puppet':
  #  command => '/opt/puppetlabs/bin/puppet agent --enable'
  #}
#
  #exec { 'remove_templatedir_setting':
  #  command => '/bin/sed -i /etc/puppet/puppet.conf -e "/templatedir=/d"',
  #  onlyif  => '/bin/grep templatedir /etc/puppet/puppet.conf',
  #  require => Package['puppet-agent'],
  #  before => Service['puppet']
  #}

  file_line {'create main section':
    line => '[agent]',
    path => '/etc/puppetlabs/puppet/puppet.conf',
    ensure => present
  }->
  file_line {'set runinterval':
    after => '[agent]',
    line => 'runinterval = 1m',
    path => '/etc/puppetlabs/puppet/puppet.conf',
    ensure => present,
  }->
  service { 'puppet':
    enable  => true,
    ensure  => running,
    require => Package['puppet-agent'],
  }
}