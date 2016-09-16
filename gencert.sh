#!/usr/bin/env bash
set -e

if [ "$1" == "ca" ]; then
    openssl genrsa -out ca-key.pem 2048
    openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kube-ca"
    exit 0
fi

IP="$1"
HOST="$2"

cat <<EOF >${HOST}.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${HOST}
IP.1 = ${IP}
EOF

openssl genrsa -out ${HOST}-key.pem 2048
openssl req -new -key ${HOST}-key.pem -out ${HOST}.csr -subj "/CN=${HOST}" -config ${HOST}.cnf
openssl x509 -req -in ${HOST}.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out ${HOST}.pem -days 365 -extensions v3_req -extfile ${HOST}.cnf
