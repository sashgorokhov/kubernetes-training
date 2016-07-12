

class certs::ca inherits certs::params {
  file {$ssl_dir:
   ensure => directory
  }->
  exec {'ca-key.pem':
    command => "/usr/bin/openssl genrsa -out ${ssl_dir}/ca-key.pem 2048",
    unless => "/usr/bin/test -f ${ssl_dir}/ca-key.pem"
  }->
  exec {'ca.pem':
    command => "/usr/bin/openssl req -x509 -new -nodes -key ${ssl_dir}/ca-key.pem -days 10000 -out ${ssl_dir}/ca.pem -subj \"/CN=kube-ca\"",
    unless => "/usr/bin/test -f ${ssl_dir}/ca.pem"
  }
}