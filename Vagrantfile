# -*- mode: ruby -*-
# vi: set ft=ruby :

domain = 'example.com'

puppet_master_ip = '172.16.32.64'

masters = [
    {:hostname => 'master1',  :ip => '172.16.32.10'},
    {:hostname => 'master2',  :ip => '172.16.32.11'},
    {:hostname => 'master3',  :ip => '172.16.32.12'},
]

nodes = [
    {:hostname => 'node1',  :ip => '172.16.32.13'},
    {:hostname => 'node2',  :ip => '172.16.32.14'},
    {:hostname => 'node3',  :ip => '172.16.32.15'},
]

# NOTE: If you add something to nodes and masters, dont forget to modify puppet/manifests/hosts.pp !!

# if, while provisioning with puppet you getting errors like "Could not evaluate: undefined method `exist?'", then simply re-run provision.

Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/trusty64"

    config.vm.provision "shell", name: "Install puppet", inline: <<-SHELL
        set -ex
        if [ ! -f /home/vagrant/puppetlabs-release-pc1-trusty.deb ]; then
            cd /home/vagrant
            wget https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
            dpkg -i puppetlabs-release-pc1-trusty.deb
            apt-get update -qq
        fi
        apt-get autoremove -qqy
        apt-get install -qqy puppet-agent
        /opt/puppetlabs/bin/puppet apply --modulepath=/vagrant/puppet/modules -e "class{'puppet::hosts':}"
        if [[ "$HOSTNAME" == *"puppet"* ]]; then
            /opt/puppetlabs/bin/puppet apply --modulepath=/vagrant/puppet/modules -e "class{'puppet::server':}"
        else
            /opt/puppetlabs/bin/puppet apply --modulepath=/vagrant/puppet/modules -e "class{'puppet::agent':}"
        fi
    SHELL

    config.vm.define "puppet" do |puppet|
        puppet.vm.provider "virtualbox" do |v|
          v.memory = 2048
          v.cpus = 1
          v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        end
        puppet.vm.synced_folder "puppet/manifests", "/etc/puppetlabs/code/environments/production/manifests"
        puppet.vm.synced_folder "puppet/modules", "/etc/puppetlabs/code/environments/production/modules"
        puppet.vm.hostname = "puppet." + domain
        puppet.vm.network "private_network", ip: puppet_master_ip
    end

    masters.each do |master_config|
        config.vm.define master_config[:hostname], autostart: true do |master|
            master.vm.hostname = master_config[:hostname] + '.' + domain
            master.vm.network "private_network", ip: master_config[:ip]
            master.vm.synced_folder "kubernetes", "/etc/kubernetes/shared"
            master.vm.provider "virtualbox" do |v|
                v.memory = 1024
                v.cpus = 1
                v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
            end
            if master_config[:hostname] == 'master1'
                master.vm.network "forwarded_port", guest: 8080, host: 8080
            end
        end
    end

    nodes.each do |node_config|
        config.vm.define node_config[:hostname] do |node|
            node.vm.hostname = node_config[:hostname] + '.' + domain
            node.vm.network "private_network", ip: node_config[:ip]
            node.vm.synced_folder "kubernetes", "/etc/kubernetes/shared"
            node.vm.provider "virtualbox" do |v|
                v.memory = 512
                v.cpus = 1
                v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
            end
        end
    end
end