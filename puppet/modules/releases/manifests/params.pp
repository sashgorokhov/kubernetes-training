

class releases::params {
  $root = '/vagrant/puppet/modules/releases/files'
  $downloads_dir = "${root}/downloads"
  $releases_dir = "${root}/releases"

  exec {"create $root":
    command => "/bin/mkdir -p $root"
  }->
  file { $downloads_dir:
    ensure => directory,
  }->
  file { $releases_dir:
    ensure => directory,
  }

}