define releases::binary ($names=[], $source="") {
  $names.each |String $binary_name| {
    file {$binary_name:
      path => "/usr/bin/${binary_name}",
      ensure => file,
      owner => ubuntu,
      group => ubuntu,
      mode => 'ug+rwx',
      source => "${source}${binary_name}",
    }
  }
}