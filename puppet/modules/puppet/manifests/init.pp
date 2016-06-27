class puppet {
  group { 'puppet':
    ensure => present
  }

  package { 'puppet':
    ensure => latest,
  }

  #exec { 'start_puppet':
  #  command => '/bin/sed -i /etc/default/puppet -e "s/START=no/START=yes/"',
  #  unless  => '/bin/grep START=yes /etc/default/puppet',
  #  require => Package['puppet'],
  #  before  => Service['puppet'],
  #}

  exec { 'remove_templatedir_setting':
    command => '/bin/sed -i /etc/puppet/puppet.conf -e "/templatedir=/d"',
    onlyif  => '/bin/grep templatedir /etc/puppet/puppet.conf',
    require => Package['puppet'],
  }

  #service { 'puppet':
  #  enable  => true,
  #  ensure  => running,
  #  require => Package['puppet'],
  #}
}