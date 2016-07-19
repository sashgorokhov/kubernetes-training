
class releases::stolon inherits releases::params {
  $stolon_url = 'https://github.com/sorintlab/stolon/releases/download/v0.2.0/stolon-v0.2.0-linux-amd64.tar.gz'
  $stolon_tarname = "${downloads_dir}/stolon-v0.2.0-linux-amd64.tar.gz"
  $stolon_release = "${releases_dir}/stolon-v0.2.0-linux-amd64"

  downloader {'get stolon':
    download_url => $stolon_url,
    tarname => $stolon_tarname,
    extracted => $stolon_release,
  }->
  releases::binary {'stolon binaries':
    names => ['stolonctl'],
    source => 'puppet:///modules/releases/releases/stolon-v0.2.0-linux-amd64/'
  }
}
