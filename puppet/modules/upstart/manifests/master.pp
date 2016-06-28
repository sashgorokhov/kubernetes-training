

class upstart::master {
  class {'upstart::etcd':}
  class {'upstart::kube_apiserver':}
}