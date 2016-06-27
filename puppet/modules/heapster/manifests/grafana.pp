

class heapster::grafana {
  exec {'build heapster grafana':
    command => "/usr/bin/docker build --rm=true --force-rm -t master:5000/grafana ${releases::heapster::heapster_release}/grafana",
    unless => "/usr/bin/docker images | /bin/grep -q master:5000/grafana",
    require => Class['releases::heapster']
  }~>
  exec {'push heapster grafana image':
    command => "/usr/bin/docker push master:5000/grafana",
    refreshonly => true
  }
}
