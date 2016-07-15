

class certs::node inherits certs::params {
  file {"${ssl_dir}/node.cnf":
    ensure => present,
    content => epp('certs/node.cnf.epp', {"hostname" => "${hostname}", "host" => "${hostname}.${domain}", "ip" => "${puppet::hosts::hosts[$hostname]}"})
  }->
  exec {'node-key.pem':
    command => "/usr/bin/openssl genrsa -out ${ssl_dir}/node-key.pem 2048",
    unless => "/usr/bin/test -f ${ssl_dir}/node-key.pem"
  }->
  exec {'node.csr':
    command => "/usr/bin/openssl req -new -key ${ssl_dir}/node-key.pem -out ${ssl_dir}/node.csr -subj \"/CN=${hostname}\" -config ${ssl_dir}/node.cnf",
    unless => "/usr/bin/test -f ${ssl_dir}/node.csr"
  }->
  exec {'node.pem':
    command => "/usr/bin/openssl x509 -req -in ${ssl_dir}/node.csr -CA /etc/kubernetes/shared/ssl/ca.pem -CAkey /etc/kubernetes/shared/ssl/ca-key.pem -CAcreateserial -out ${ssl_dir}/node.pem -days 365 -extensions v3_req -extfile ${ssl_dir}/node.cnf",
    unless => "/usr/bin/test -f ${ssl_dir}/node.pem"
  }
}