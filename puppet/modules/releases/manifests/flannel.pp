
class releases::flannel inherits releases::params {
  $flannel_url = 'https://github.com/coreos/flannel/releases/download/v0.5.5/flannel-0.5.5-linux-amd64.tar.gz'
  $flannel_tarname = "${downloads_dir}/flannel-0.5.5-linux-amd64.tar.gz"
  $flannel_release = "${releases_dir}/flannel-0.5.5-linux-amd64"

  downloader {'get flannel':
    download_url => $flannel_url,
    tarname => $flannel_tarname,
    extracted => $flannel_release,
  }~>
  releases::binary {'flannel binaries':
    names => ['flanneld'],
    source => 'puppet:///modules/releases/releases/flannel-0.5.5-linux-amd64/'
  }
}
