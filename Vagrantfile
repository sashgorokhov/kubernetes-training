# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_check_update = true

  config.vm.provision "shell", inline: <<-SHELL
    set -ex

    echo 'Dpkg::Options {"--force-confdef";"--force-confold";}' > /etc/apt/apt.conf.d/local

    sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
        echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | tee /etc/apt/sources.list.d/docker.list
    fi

    apt-get update -qq

    if ! `lsmod | grep -q br_netfilter`; then
        sudo apt-get install -qqy linux-image-3.19.0-33-generic linux-image-extra-3.19.0-33-generic
        echo "br_netfilter" | tee -a /etc/modules
        echo "You need to reload machine."
        exit 1
    fi

    function stop-all {
        stop kube-apiserver || true
        stop kubelet || true
        stop docker || true
        stop flanneld || true
    }

    stop-all

    if [ ! "$HOSTNAME" == "master" ]; then
        if ! `cat /etc/hosts | grep -q master`; then
            echo "192.168.140.50 master" | tee -a /etc/hosts
        fi
        touch /home/vagrant/.bashrc
        if ! `cat /home/vagrant/.bashrc | grep -q "alias kubectl"`; then
            echo 'alias kubectl="kubectl --server http://master:8080"' | tee -a /home/vagrant/.bashrc
        fi
    fi

    if ! `cat /home/vagrant/.bashrc | grep -q "alias kubectl-system"`; then
        echo 'alias kubectl-system="kubectl --namespace=kube-system"' | tee -a /home/vagrant/.bashrc
    fi

    source /vagrant/kubernetes/system/get-all.sh

    if [ "$HOSTNAME" == "master" ]; then
        cp /vagrant/kubernetes/system/master/init/*.conf /etc/init/
        cp /vagrant/kubernetes/system/master/default/* /etc/default/
    else
        cp /vagrant/kubernetes/system/node/init/*.conf /etc/init/
        cp /vagrant/kubernetes/system/node/default/* /etc/default/
    fi

    mkdir -p /etc/kubernetes/manifests

    modprobe br_netfilter

    if [ "$HOSTNAME" == "master" ]; then
      start etcd || true
      sleep 5s
      etcdctl set /coreos.com/network/config < /vagrant/kubernetes/system/flannel-config.json
    fi

    start flanneld || true
    stop kube-apiserver || true

    sleep 10s
    if [ ! -f /run/flannel/subnet.env ]; then
      echo '/run/flannel/subnet.env not found! aborting!'
      exit 1
    fi

    apt-get install -qqy bridge-utils python-pip

    ip link set dev docker0 down || true
    brctl delbr docker0 || true

    apt-get install -qqy docker-engine

    usermod -aG docker vagrant

    start docker || true
    if [ "$HOSTNAME" == "master" ]; then
        docker pull gcr.io/google_containers/hyperkube:v1.2.4
        docker pull registry:2
        #bash /vagrant/webapp/build.sh
    #else
        #docker pull master:5000/webapp
    fi
    start kube-apiserver

    apt-get autoremove -qqy
  SHELL

  config.vm.define "master", primary: true do |master|
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = "2"
    end
    master.vm.hostname = "master"
    master.vm.network "public_network", ip: "192.168.140.50"
    master.vm.network "forwarded_port", guest: 4040, host: 4040 # kubectl proxy
    master.vm.network "forwarded_port", guest: 8080, host: 8080 # apiserver
    master.vm.network "forwarded_port", guest: 3000, host: 3000 # grafana
    master.vm.network "forwarded_port", guest: 4194, host: 4194 # cadvisor
    master.vm.network "forwarded_port", guest: 8083, host: 8083 # influxdb-web
    master.vm.network "forwarded_port", guest: 8086, host: 8086 # influxdb
    master.vm.synced_folder "kubernetes/manifests/", "/etc/kubernetes/manifests"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = "1"
  end

  config.vm.define "node-1", autostart: false do |node|
    node.vm.hostname = "node-1"
    node.vm.network "public_network"
  end

  config.vm.define "node-2", autostart: false do |node|
    node.vm.hostname = "node-2"
    node.vm.network "public_network"
  end

  config.vm.define "node-3", autostart: false do |node|
    node.vm.hostname = "node-3"
    node.vm.network "public_network"
  end
end