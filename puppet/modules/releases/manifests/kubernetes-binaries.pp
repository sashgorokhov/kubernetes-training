class releases::kubernetes-binaries {
  define binary {
    file {$name:
      path => "/usr/bin/${name}",
      ensure => file,
      source => "puppet:///modules/releases/releases/kubernetes-v1.3.0-beta.1/server/bin/${name}",
    }
  }
  binary {['hyperkube', 'kubectl']:}
}
