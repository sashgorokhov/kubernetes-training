class releases::etcd-binaries {
  define binary {
    file {$name:
      path => "/usr/bin/${name}",
      ensure => file,
      source => "puppet:///modules/releases/releases/etcd-v2.3.6-linux-amd64/${name}",
    }
  }
  binary {['etcd', 'etcdctl']:}
}
