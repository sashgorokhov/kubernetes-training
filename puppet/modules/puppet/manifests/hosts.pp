

class puppet::hosts {
  $hosts = { master => '172.16.32.10', node1 => '172.16.32.13', node2 => '172.16.32.14', node3 => '172.16.32.15' }
  keys($hosts).each |String $host_name| {
    if $hostname != $host_name {
      host { "$host_name.${domain}":
        ip           => $hosts[$host_name],
        host_aliases => [$host_name],
        ensure       => present
      }
    }
  }
}