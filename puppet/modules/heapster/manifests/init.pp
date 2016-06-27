

class heapster {
  class {'heapster::heapster':}
  class {'heapster::influxdb':}
  class {'heapster::grafana':}
}