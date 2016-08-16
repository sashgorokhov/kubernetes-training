# puppet-training


### Start kubernetes cluster:

```shell
vagrant up puppet master node1 node2
```

After startup, you must wait some time (minute or so) until all machines will be provisioned with puppet.
Re-provisioning runs every 5 minutes.

#### DNS:
```shell
kubectl create -f /vagrant/kubernetes/manifests/kube-dns
```

#### Dashboard:
```shell
kubectl create -f /vagrant/kubernetes/manifests/dashboard
```
Access: `http://172.16.32.10/ui`

#### Enable heapster:
```shell
kubectl create -f /vagrant/kubernetes/manifests/heapster
```

Access to grafana: `http://172.16.32.10:8080/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana/`


#### Download links
Hyperkube: http://storage.googleapis.com/kubernetes-release/release/v1.3.5/bin/linux/amd64/hyperkube
Kubectl: http://storage.googleapis.com/kubernetes-release/release/v1.3.5/bin/linux/amd64/kubectl
