# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_check_update = false
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 80, host: 8000  # reverse-proxy to webapp
  config.vm.synced_folder "kubernetes/manifests/", "/etc/kubernetes/manifests"

  #config.vm.network "private_network", ip: "192.168.33.10"
  #config.vm.network "public_network"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
    vb.cpus = "4"
  end

  config.vm.provision "docker" do |docker|
    docker.pull_images "gcr.io/google_containers/hyperkube:v1.2.4"
    docker.pull_images "quay.io/coreos/etcd:v2.2.1"
    docker.pull_images "registry"
  end

  config.vm.provision "shell", inline: <<-SHELL
    RELEASE_PATH='/vagrant/kubernetes/release'
    RELEASE_TAR="$RELEASE_PATH/kubernetes.tar.gz"
    RELEASE_EXTRACTED="$RELEASE_PATH/kubernetes"
    BINARIES_DIR="$RELEASE_EXTRACTED/server/bin"

    apt-get update
    apt-get install -y bridge-utils

    if [ ! -f $RELEASE_TAR ] && [ ! -d $RELEASE_EXTRACTED ]; then
        sudo apt-get update > /dev/null
        sudo apt-get install -y wget > /dev/null
        wget --progress=bar:force -nc -O $RELEASE_TAR https://github.com/kubernetes/kubernetes/releases/download/v1.2.4/kubernetes.tar.gz
    fi
    if [ ! -d $RELEASE_EXTRACTED ]; then
        mkdir -p $RELEASE_EXTRACTED
        tar -C $RELEASE_EXTRACTED --strip-components 1 -xzf $RELEASE_TAR 2>/dev/null || true
    fi
    if [ ! -d $BINARIES_DIR ]; then
        tar -C $RELEASE_EXTRACTED --strip-components 1 -xzf $RELEASE_EXTRACTED/server/kubernetes-server-linux-amd64.tar.gz 2>/dev/null || true
    fi
    if [ ! -f  /usr/bin/hyperkube ]; then
        cp $BINARIES_DIR/hyperkube /usr/bin/hyperkube
        chmod +x /usr/bin/hyperkube
    fi
    if [ ! -f  /usr/bin/kubectl ]; then
        cp $BINARIES_DIR/kubectl /usr/bin/kubectl
        chmod +x /usr/bin/kubectl
    fi

    cp /vagrant/kubernetes/kubelet.conf /etc/init/
    cp /vagrant/kubernetes/kube-proxy.conf /etc/init/
    start kubelet

  SHELL

end
