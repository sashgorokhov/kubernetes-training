class releases::kubernetes inherits releases::params {
  $kubernetes_version = 'v1.4.5'
  $kubernetes_release_name = "kubernetes-$kubernetes_version"
  $kubernetes_release = "${releases_dir}/${kubernetes_release_name}"
  $hyperkube_url = "http://storage.googleapis.com/kubernetes-release/release/$kubernetes_version/bin/linux/amd64/hyperkube"
  $kubectl_url = "http://storage.googleapis.com/kubernetes-release/release/$kubernetes_version/bin/linux/amd64/kubectl"


  file {$kubernetes_release:
   ensure => directory
  }
  wget::fetch { $hyperkube_url:
    destination => "$kubernetes_release/hyperkube",
    require => File[$kubernetes_release]
  }->
  wget::fetch { $kubectl_url:
    destination => "$kubernetes_release/kubectl",
    require => File[$kubernetes_release]
  }->
  releases::binary {'kubernetes binaries':
    names => ['hyperkube', 'kubectl'],
    source => "puppet:///modules/releases/releases/${kubernetes_release_name}/"
  }
}
