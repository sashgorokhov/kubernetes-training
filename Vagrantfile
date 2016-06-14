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
    #master.vm.network "forwarded_port", guest: 80, host: 8000  # reverse-proxy to webapp
    master.vm.synced_folder "kubernetes/manifests/", "/etc/kubernetes/manifests"

    master.vm.provision "shell", inline: <<-SHELL
        echo 'Dpkg::Options {"--force-confdef";"--force-confold";}' > /etc/apt/apt.conf.d/local
        source /vagrant/kubernetes/system/get-all.sh
        cp /vagrant/kubernetes/system/master/init/*.conf /etc/init/
        cp /vagrant/kubernetes/system/master/default/* /etc/default/
    SHELL
    master.vm.provision "docker" do |docker|
      docker.pull_images "gcr.io/google_containers/hyperkube:v1.2.4"
      docker.pull_images "registry:2"
    end
    master.vm.provision "shell", inline: <<-SHELL
      stop docker || true

      apt-get update -qq
      apt-get install -qqy bridge-utils
      apt-get autoremove -qqy

      ip link set dev docker0 down || true
      brctl delbr docker0 || true

      stop kubelet || true
      stop docker || true
      stop flanneld || true
      stop etcd || true
      #if ( status kubelet | grep running ); then stop kubelet fi
      #if ( status docker | grep running ); then stop docker fi
      #if ( status flanneld | grep running ); then stop flanneld fi
      #if ( status etcd | grep running ); then stop etcd fi

      start etcd && stop flanneld
      echo Started etcd, waiting 10 seconds for it to launch
      sleep 10s

      #etcdctl rm --recursive /coreos.com/network
      etcdctl set /coreos.com/network/config < /vagrant/kubernetes/system/flannel-config.json
      etcdctl get /coreos.com/network/config

      start flanneld
      echo Started flanneld, waiting 10 seconds for it to launch
      sleep 10s

      if [ ! -f /run/flannel/subnet.env ]; then
        echo '/run/flannel/subnet.env not found! aborting!'
        exit 1
      fi
      start docker

    SHELL
    master.vm.provision "shell", inline: <<-SHELL
        docker build --rm=true --force-rm -t master:5000/webapp /vagrant/webapp
        echo Sleeping 30s until docker registry starts
        sleep 30s
        docker push master:5000/webapp
    SHELL
    #master.vm.provision "shell", inline: <<-SHELL
    #  apt-get install -y nginx
    #  rm -f /etc/nginx/sites-enabled/default
    #  cp /vagrant/kubernetes/reverse-proxy.conf /etc/nginx/sites-enabled/
    #  service nginx restart
    #SHELL
  end

  config.vm.define "node-1" do |node|
    node.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "2"
    end
    node.vm.hostname = "node-1"
    node.vm.provision "shell", inline: <<-SHELL
        if ! `cat /etc/hosts | grep -q master`; then
            echo "172.28.128.5 master" | tee -a /etc/hosts
        fi
        touch /home/vagrant/.bashrc
        if ! `cat /home/vagrant/.bashrc | grep -q "alias kubectl"`; then
            echo 'alias kubectl="kubectl --server http://master:8080"' | tee -a /home/vagrant/.bashrc
        fi
        echo 'Dpkg::Options {"--force-confdef";"--force-confold";}' > /etc/apt/apt.conf.d/local
        source /vagrant/kubernetes/system/get-all.sh
        cp /vagrant/kubernetes/system/node/init/*.conf /etc/init/
        cp /vagrant/kubernetes/system/node/default/* /etc/default/
        mkdir -p /etc/kubernetes/manifests
    SHELL
    node.vm.provision "docker" do |docker|
        docker.pull_images "master:5000/webapp"
    end
    node.vm.provision "shell", inline: <<-SHELL
      stop docker || true

      apt-get update -qq
      apt-get install -qqy bridge-utils
      apt-get autoremove -qqy

      ip link set dev docker0 down || true
      brctl delbr docker0 || true

      start flanneld
      echo Started flanneld, waiting 10 seconds for it to launch
      sleep 10s
      if [ ! -f /run/flannel/subnet.env ]; then
        echo '/run/flannel/subnet.env not found! aborting!'
        exit 1
      fi
      start docker
    SHELL
  end

  #config.vm.provision "docker"
  #config.vm.provision "shell", inline: <<-SHELL
  #  apt-get install -y bridge-utils
  #  mkdir -p /etc/kubernetes/manifests
  #  source /vagrant/kubernetes/get_kubernetes_release.sh
  #  source /vagrant/kubernetes/get_flannel_release.sh
  #  restart docker
  #  cp /vagrant/kubernetes/*.conf /etc/init/
  #  cp /vagrant/kubernetes/flanneld /etc/default/
  #  start kubelet
  #SHELL

end
