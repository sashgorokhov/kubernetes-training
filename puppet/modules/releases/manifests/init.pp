

class releases {
  class {'releases::kubernetes':}
  class {'releases::etcd':}
  class {'releases::flannel': }
  class {'releases::heapster':}
}

class releases-binaries {
  class {'releases::kubernetes-binaries':}
  class {'releases::flannel-binaries': }
}