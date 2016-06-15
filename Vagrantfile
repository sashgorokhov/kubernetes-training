# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_check_update = false

  config.vm.network "private_network", type: "dhcp"

  config.vm.provision "shell", inline: <<-SHELL
    set -ex

    if [ ! "$HOSTNAME" == "master" ]; then
        if ! `cat /etc/hosts | grep -q master`; then
            echo "172.28.128.8 master" | tee -a /etc/hosts
        fi
        touch /home/vagrant/.bashrc
        if ! `cat /home/vagrant/.bashrc | grep -q "alias kubectl"`; then
            echo 'alias kubectl="kubectl --server http://master:8080"' | tee -a /home/vagrant/.bashrc
        fi
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

    stop kubelet || true
    stop docker || true
    stop flanneld || true

    if [ "$HOSTNAME" == "master" ]; then
      stop etcd || true
      start etcd
      sleep 5s
      etcdctl set /coreos.com/network/config < /vagrant/kubernetes/system/flannel-config.json
    fi

    start flanneld || true
    stop kubelet || true

    sleep 10s
    if [ ! -f /run/flannel/subnet.env ]; then
      echo '/run/flannel/subnet.env not found! aborting!'
      exit 1
    fi

    apt-get update -qq
    apt-get install -qqy bridge-utils

    if ! `lsmod | grep -q br_netfilter`; then
        echo br_netfilter module not found. Updating linux kernel
        apt-get install -qqy linux-generic-lts-vivid
        echo You should restart $HOSTNAME
    else
        echo br_netfilter module found! Loading
        modprobe br_netfilter
        restart kube-proxy || true
    fi

    apt-get autoremove -qqy
    echo 'Dpkg::Options {"--force-confdef";"--force-confold";}' > /etc/apt/apt.conf.d/local

    stop docker || true
    ip link set dev docker0 down || true
    brctl delbr docker0 || true

  SHELL
  config.vm.provision "docker"
  config.vm.provision "shell", inline: <<-SHELL
    set -ex
    start docker || true
    if [ "$HOSTNAME" == "master" ]; then
        docker pull gcr.io/google_containers/hyperkube:v1.2.4
        docker pull registry:2
        #bash /vagrant/webapp/build.sh
    #else
        #docker pull master:5000/webapp
    fi
    start kubelet
  SHELL

  config.vm.define "master", primary: true do |master|
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = "2"
    end
    master.vm.hostname = "master"
    master.vm.network "forwarded_port", guest: 8080, host: 8080
    master.vm.network "forwarded_port", guest: 80, host: 8000  # reverse-proxy to webapp
    master.vm.synced_folder "kubernetes/manifests/", "/etc/kubernetes/manifests"
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = "1"
  end

  config.vm.define "node-1" do |node|
    node.vm.hostname = "node-1"
  end

  config.vm.define "node-2", autostart: false do |node|
    node.vm.hostname = "node-2"
  end

  config.vm.define "node-3", autostart: false do |node|
    node.vm.hostname = "node-3"
  end
end