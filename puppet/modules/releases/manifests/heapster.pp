
class releases::heapster inherits releases::params {
  $heapster_url = 'https://github.com/kubernetes/heapster/archive/v1.1.0.tar.gz'
  $heapster_tarname = "${downloads_dir}/heapster-v1.1.0.tar.gz"
  $heapster_release = "${releases_dir}/heapster-v1.1.0"

  downloader {'get heapster':
    download_url => $heapster_url,
    tarname => $heapster_tarname,
    extracted => $heapster_release,
  }
}
