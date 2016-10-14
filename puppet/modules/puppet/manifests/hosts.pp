

class puppet::hosts {
  $hosts = { puppet => '172.16.32.64', master => '172.16.32.10', node1 => '172.16.32.11', node2 => '172.16.32.12', authserver => '172.16.32.13' }
  keys($hosts).each |String $host_name| {
    if $hostname != $host_name {
      host { "$host_name.${domain}":
        ip           => $hosts[$host_name],
        host_aliases => [$host_name],
        ensure       => present
      }
    }
  }

#  host { "puppet.${domain}":
#    ip           => '172.16.32.64',
#    host_aliases => ['puppet'],
#    ensure       => present
#  }
#
#  host { "master.${domain}":
#    ip           => '172.16.32.10',
#    host_aliases => ['master'],
#    ensure       => present
#  }
#
#  host { "node1.${domain}":
#    ip           => '172.16.32.11',
#    host_aliases => ['node1'],
#    ensure       => present
#  }
#
#  host { "node2.${domain}":
#    ip           => '172.16.32.12',
#    host_aliases => ['node2'],
#    ensure       => present
#  }
}