# puppet-training


How to start kubernetes cluster:

vagrant up puppet master node1 node2

after startup, you must wait some time (minute or so) until all machines will be provisioned with puppet.
Re-provisioning runs every 5 minutes.

Enable cluster DNS:
kubectl create -f /vagrant/kubernetes/manifests/kube-dns

Enable dashboard:
kubectl create -f /vagrant/kubernetes/manifests/dashboard

Access: http://172.16.32.10/ui

Enable heapster:
kubectl create -f /vagrant/kubernetes/manifests/heapster

Access to grafana: http://172.16.32.10:8080/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana/
