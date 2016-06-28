define releases::binary ($names=[], $source="") {
  $names.each |String $binary_name| {
    file {$binary_name:
      path => "/bin/${binary_name}",
      ensure => file,
      owner => vagrant,
      group => vagrant,
      source => "${source}${binary_name}",
    }
  }
}