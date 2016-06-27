class releases::flannel-binaries {
  define binary {
    file {$name:
      path => "/usr/bin/${name}",
      ensure => file,
      source => "puppet:///modules/releases/releases/flannel-0.5.5-linux-amd64/${name}",
    }
  }
  binary {['flanneld']:}
}
