

class certs::ca inherits certs::params {
  file {$ssl_dir:
   ensure => directory
  }->
  file {'/etc/kubernetes/shared':
   ensure => directory
  }->
  exec {'ca-key.pem':
    command => "/usr/bin/openssl genrsa -out /etc/kubernetes/shared/ssl/ca-key.pem 2048",
    unless => "/usr/bin/test -f /etc/kubernetes/shared/ssl/ca-key.pem"
  }->
  exec {'ca.pem':
    command => "/usr/bin/openssl req -x509 -new -nodes -key /etc/kubernetes/shared/ssl/ca-key.pem -days 10000 -out /etc/kubernetes/shared/ssl/ca.pem -subj \"/CN=kube-ca\"",
    unless => "/usr/bin/test -f /etc/kubernetes/shared/ssl/ca.pem"
  }
}