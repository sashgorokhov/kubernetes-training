# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_check_update = false

  #config.vm.network "private_network", ip: "192.168.33.10"
  #config.vm.network "public_network"
  config.vm.network "private_network", type: "dhcp"

  config.vm.define "master", primary: true do |master|
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
      vb.cpus = "4"
    end
    master.vm.hostname = "master"
    master.vm.network "forwarded_port", guest: 8080, host: 8080
    master.vm.network "forwarded_port", guest: 80, host: 8000  # reverse-proxy to webapp
    master.vm.synced_folder "kubernetes/manifests/", "/etc/kubernetes/manifests"
    master.vm.provision "docker" do |docker|
      docker.pull_images "gcr.io/google_containers/hyperkube:v1.2.4"
      docker.pull_images "quay.io/coreos/etcd:v2.2.1"
      docker.pull_images "registry"
    end
    master.vm.provision "shell", inline: <<-SHELL
      apt-get install -y nginx
      rm -f /etc/nginx/sites-enabled/default
      cp /vagrant/kubernetes/reverse-proxy.conf /etc/nginx/sites-enabled/
      service nginx restart
    SHELL
  end

  config.vm.define "node-1" do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "2"
    end
    node.vm.hostname = "node-1"
  end

  config.vm.provision "docker"
  config.vm.provision "shell", inline: <<-SHELL
    apt-get install -y bridge-utils
    mkdir -p /etc/kubernetes/manifests

    source /vagrant/kubernetes/get_kubernetes_release.sh
    source /vagrant/kubernetes/get_flannel_release.sh

    DOCKER_OPTS="--insecure-registry master:5000 --dns 8.8.8.8 --dns 8.8.4.4" #  --exec-driver=native
    sed -i "s/#?DOCKER_OPTS.*/DOCKER_OPTS='$DOCKER_OPTS'/g" /etc/default/docker
    restart docker

    cp /vagrant/kubernetes/kubelet.conf /etc/init/
    cp /vagrant/kubernetes/kube-proxy.conf /etc/init/
    start kubelet

  SHELL

end
