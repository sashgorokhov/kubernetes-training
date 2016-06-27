class puppet::hosts {
  host { "puppet.${domain}":
    ip           => '172.16.32.64',
    host_aliases => ['puppet'],
    ensure       => present
  }

  host { "master.${domain}":
    ip           => '172.16.32.10',
    host_aliases => ['master'],
    ensure       => present
  }

  host { "node1.${domain}":
    ip           => '172.16.32.11',
    host_aliases => ['node1'],
    ensure       => present
  }

  host { "node2.${domain}":
    ip           => '172.16.32.11',
    host_aliases => ['node2'],
    ensure       => present
  }
}