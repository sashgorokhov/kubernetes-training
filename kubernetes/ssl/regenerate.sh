#!/usr/bin/env bash

set -ex

K8S_SERVICE_IP=10.10.0.1
MASTER_IP=172.16.32.10

SSLDIR=/vagrant/kubernetes/ssl

rm -rf $SSLDIR/*.pem $SSLDIR/*.csr $SSLDIR/*.cnf $SSLDIR/*.srl

openssl genrsa -out $SSLDIR/ca-key.pem 2048
openssl req -x509 -new -nodes -key $SSLDIR/ca-key.pem -days 10000 -out $SSLDIR/ca.pem -subj "/CN=kube-ca"

sed "s/\${K8S_SERVICE_IP}/${K8S_SERVICE_IP}/g" $SSLDIR/openssl.cnf.template > $SSLDIR/openssl.cnf
sed -i "s/\${MASTER_IP}/${MASTER_IP}/g" $SSLDIR/openssl.cnf

openssl genrsa -out $SSLDIR/apiserver-key.pem 2048
openssl req -new -key $SSLDIR/apiserver-key.pem -out $SSLDIR/apiserver.csr -subj "/CN=kube-apiserver" -config $SSLDIR/openssl.cnf
openssl x509 -req -in $SSLDIR/apiserver.csr -CA $SSLDIR/ca.pem -CAkey $SSLDIR/ca-key.pem -CAcreateserial -out $SSLDIR/apiserver.pem -days 365 -extensions v3_req -extfile $SSLDIR/openssl.cnf


function generate-worker {
    WORKER_IP=$1
    WORKER_FQDN_1=$2
    WORKER_FQDN_2=$3

    sed "s/\${WORKER_IP}/${WORKER_IP}/g" $SSLDIR/worker-openssl.cnf.template > $SSLDIR/${WORKER_FQDN_2}.cnf
    sed -i "s/\${WORKER_FQDN_1}/${WORKER_FQDN_1}/g" $SSLDIR/${WORKER_FQDN_2}.cnf
    sed -i "s/\${WORKER_FQDN_2}/${WORKER_FQDN_2}/g" $SSLDIR/${WORKER_FQDN_2}.cnf
    openssl genrsa -out $SSLDIR/${WORKER_FQDN_2}-key.pem 2048
    openssl req -new -key $SSLDIR/${WORKER_FQDN_2}-key.pem -out $SSLDIR/${WORKER_FQDN_2}.csr -subj "/CN=${WORKER_FQDN_1}" -config $SSLDIR/${WORKER_FQDN_2}.cnf
    openssl x509 -req -in $SSLDIR/${WORKER_FQDN_2}.csr -CA $SSLDIR/ca.pem -CAkey $SSLDIR/ca-key.pem -CAcreateserial -out $SSLDIR/${WORKER_FQDN_2}.pem -days 365 -extensions v3_req -extfile $SSLDIR/${WORKER_FQDN_2}.cnf
}

generate-worker 172.16.32.10 master.example.com master
generate-worker 172.16.32.11 node1.example.com node1
generate-worker 172.16.32.12 node2.example.com node2

openssl genrsa -out $SSLDIR/admin-key.pem 2048
openssl req -new -key $SSLDIR/admin-key.pem -out $SSLDIR/admin.csr -subj "/CN=kube-admin"
openssl x509 -req -in $SSLDIR/admin.csr -CA $SSLDIR/ca.pem -CAkey $SSLDIR/ca-key.pem -CAcreateserial -out $SSLDIR/admin.pem -days 365

chmod 600 $SSLDIR/*.pem
chown root:root $SSLDIR/*.pem