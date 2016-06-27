

class heapster::influxdb {
  exec {'build heapster influxdb':
    command => "/usr/bin/docker build --rm=true --force-rm -t master:5000/influxdb ${releases::heapster::heapster_release}/influxdb",
    unless => "/usr/bin/docker images | /bin/grep -q master:5000/influxdb",
    require => Class['releases::heapster']
  }~>
  exec {'push heapster influxdb image':
    command => "/usr/bin/docker push master:5000/influxdb",
    refreshonly => true
  }
}