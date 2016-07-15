

class certs::apiserver inherits certs::params{
  file {"${ssl_dir}/apiserver.cnf":
    ensure => present,
    content => epp('certs/apiserver.cnf.epp', {"hostname" => "${hostname}", "host" => "${hostname}.${domain}", "ip" => "${puppet::hosts::hosts[$hostname]}"})
  }->
  exec {'apiserver-key.pem':
    command => "/usr/bin/openssl genrsa -out ${ssl_dir}/apiserver-key.pem 2048",
    unless => "/usr/bin/test -f ${ssl_dir}/apiserver-key.pem"
  }->
  exec {'apiserver.csr':
    command => "/usr/bin/openssl req -new -key ${ssl_dir}/apiserver-key.pem -out ${ssl_dir}/apiserver.csr -subj \"/CN=kube-apiserver\" -config ${ssl_dir}/apiserver.cnf",
    unless => "/usr/bin/test -f ${ssl_dir}/apiserver.csr"
  }->
  exec {'apiserver.pem':
    command => "/usr/bin/openssl x509 -req -in ${ssl_dir}/apiserver.csr -CA /etc/kubernetes/shared/ssl/ca.pem -CAkey /etc/kubernetes/shared/ssl/ca-key.pem -CAcreateserial -out ${ssl_dir}/apiserver.pem -days 365 -extensions v3_req -extfile ${ssl_dir}/apiserver.cnf",
    unless => "/usr/bin/test -f ${ssl_dir}/apiserver.pem"
  }
}