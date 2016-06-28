

class releases {
  class {'releases::kubernetes':}
  class {'releases::etcd':}
  class {'releases::flannel': }
  class {'releases::heapster':}
}
