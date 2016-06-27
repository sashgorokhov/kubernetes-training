class puppet::hosts {
  host { "puppet.${domain}":
    ip           => '172.16.32.10',
    host_aliases => ['puppet', 'master'],
    ensure       => present
  }

  host { "node1.${domain}":
    ip           => '172.16.32.11',
    host_aliases => ['node1'],
    ensure       => present
  }
}