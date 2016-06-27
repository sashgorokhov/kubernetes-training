
class releases::kubernetes inherits releases::params {
  $kubernetes_url = 'https://github.com/kubernetes/kubernetes/releases/download/v1.3.0-beta.1/kubernetes.tar.gz'
  $kubernetes_tarname = "${downloads_dir}/kubernetes-v1.3.0-beta.1.tar.gz"
  $kubernetes_release = "${releases_dir}/kubernetes-v1.3.0-beta.1"
  $kubernetes_bin_dir = "${kubernetes_release}/server/bin"

  downloader { 'get kubernetes':
    download_url => $kubernetes_url,
    tarname      => $kubernetes_tarname,
    extracted    => $kubernetes_release
  }~>
  exec { 'extract kubernetes release binaries':
    command => "/bin/tar -C ${kubernetes_release} --strip-components 1 -xzf ${kubernetes_release}/server/kubernetes-server-linux-amd64.tar.gz",
    creates => $kubernetes_bin_dir
  }
}
