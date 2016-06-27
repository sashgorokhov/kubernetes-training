class puppet::server {
  file { [ '/etc/puppet', '/etc/puppet/files' ]:
    ensure => directory,
  }->
  package { 'puppetserver':
    ensure => present,
  }

  package { 'puppet-lint':
    ensure   => latest,
    provider => gem,
  }

  file { 'puppet.conf':
    path    => '/etc/puppet/puppet.conf',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    source  => 'puppet:///modules/puppet/puppet.conf',
    require => Package['puppetserver'],
    notify  => Service['puppetserver'],
  }

  file { 'site.pp':
    path    => '/etc/puppet/manifests/site.pp',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    source  => 'puppet:///modules/puppet/site.pp',
    require => Package[ 'puppetserver' ],
  }

  file { 'autosign.conf':
    path    => '/etc/puppet/autosign.conf',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    content => '*',
    require => Package['puppetserver'],
  }

  #file { '/etc/puppet/manifests/nodes.pp':
  #  ensure  => link,
  #  target  => '/vagrant/nodes.pp',
  #  require => Package[ 'puppetserver' ],
  #}
  #
  ## initialize a template file then ignore
  #file { '/vagrant/nodes.pp':
  #  ensure  => present,
  #  replace => false,
  #  source  => 'puppet:///modules/puppet/nodes.pp',
  #}

  service { 'puppetserver':
    enable => true,
    ensure => running,
  }
}