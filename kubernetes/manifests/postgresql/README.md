

Creating kubernetes cluster.

Please refer to: https://github.com/sorintlab/stolon/tree/v0.2.0/examples/kubernetes

1) start stolon sentinel
kubectl create -f /vagrant/kubernetes/manifests/postgresql/stolon-sentinel.yaml

Wait until it starts.

2) start stolon keeper
kubectl create -f /vagrant/kubernetes/manifests/postgresql/stolon-keeper.yaml

3) set stolon superuser password
kubectl exec -it $(kubectl get po | grep stolon-keeper-rc | awk '{print $1}') -- psql -h localhost -U stolon -d postgres -c "ALTER ROLE stolon WITH PASSWORD 'stolon';"

4) start stolon proxy and proxy service
kubectl create -f /vagrant/kubernetes/manifests/postgresql/stolon-proxy.yaml
kubectl create -f /vagrant/kubernetes/manifests/postgresql/stolon-proxy-service.yaml

5) Now connect to database via stolon proxy service ip
psql -h $(kubectl get svc | grep stolon-proxy-service | awk '{print $2}') -U stolon -d postgres

6) now you can scale postgres cluster as you want - increase replicas count for proxies, sentinels, keepers.
kubectl scale rc/stolon-sentinel-rc --replicas=3
kubectl scale rc/stolon-proxy-rc --replicas=3
kubectl scale rc/stolon-keeper-rc --replicas=3

after scaling, stolon keepers will connect to current postgres master in standby mode and start to replicate data.
Currently only warm standby is available.
