
class upstart {
  class {'upstart::docker':}
  class {'upstart::flanneld':}
  class {'upstart::kube_proxy':}
  class {'upstart::kubelet':}
}
