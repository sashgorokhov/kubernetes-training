
class upstart {
  class {'upstart::docker':}
  class {'upstart::flanneld':}
  class {'upstart::kube-proxy':}
  class {'upstart::kubelet':}
}

class upstart-master {
  class {'upstart::etcd':}
  class {'upstart::kube-apiserver':}
}

class upstart-node {}