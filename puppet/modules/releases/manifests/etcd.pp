
class releases::etcd inherits releases::params {
  $etcd_url = 'https://github.com/coreos/etcd/releases/download/v2.3.6/etcd-v2.3.6-linux-amd64.tar.gz'
  $etcd_tarname = "${downloads_dir}/etcd-v2.3.6-linux-amd64.tar.gz"
  $etcd_release = "${releases_dir}/etcd-v2.3.6-linux-amd64"

  downloader {'get etcd':
    download_url => $etcd_url,
    tarname => $etcd_tarname,
    extracted => $etcd_release,
  }->
  releases::binary {'etcd binaries':
    names => ['etcd', 'etcdctl'],
    source => 'puppet:///modules/releases/releases/etcd-v2.3.6-linux-amd64/'
  }
}
