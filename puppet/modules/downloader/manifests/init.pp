define downloader ($download_url, $tarname, $extracted) {
  wget::fetch { $download_url:
    destination => $tarname
  }~>
  exec { "exctract ${tarname}":
    command => "/bin/mkdir -p ${extracted} && /bin/tar -C ${extracted} --strip-components 1 -xzf ${tarname}",
    creates => $extracted,
  }
}
