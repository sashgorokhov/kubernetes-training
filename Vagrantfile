# -*- mode: ruby -*-
# vi: set ft=ruby :

domain = 'example.com'

master_ip = '172.16.32.10'

nodes = [
    {:hostname => 'node1',  :ip => '172.16.32.13'},
    {:hostname => 'node2',  :ip => '172.16.32.14'},
    {:hostname => 'node3',  :ip => '172.16.32.15'},
]

# NOTE: If you add something to nodes, dont forget to modify puppet/modules/puppet/manifests/hosts.pp !!

Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/xenial64"

    config.vm.provision "shell", name: "Install puppet", inline: <<-SHELL
        set -ex
        if [ ! -f /home/vagrant/puppetlabs-release-pc1-xenial.deb ]; then
            mkdir -p /home/vagrant
            cd /home/vagrant
            wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
            dpkg -i puppetlabs-release-pc1-xenial.deb
            apt-get update -q
        fi
        apt-get autoremove -qy
        apt-get install -qy puppet-agent
        /opt/puppetlabs/bin/puppet apply --modulepath=/vagrant/puppet/modules /vagrant/puppet/manifests/default.pp
    SHELL

    config.vm.define 'master', autostart: true do |master|
        master.vm.hostname = 'master' + '.' + domain
        master.vm.network "private_network", ip: master_ip
        master.vm.network "forwarded_port", guest: 8080, host: 8080
        master.vm.synced_folder "kubernetes", "/etc/kubernetes/shared"
        master.vm.synced_folder "kubernetes/addons", "/etc/kubernetes/addons"
        master.vm.provider "virtualbox" do |v|
            v.memory = 4096
            v.cpus = 2
            v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        end
        # Not working with puppet 4.*
        #master.vm.provision "puppet" do |puppet|
        #  puppet.manifests_path = "puppet/manifests"
        #  puppet.manifest_file = "master.pp"
        #  puppet.module_path = "puppet/modules"
        #  puppet.binary_path = "/opt/puppetlabs/bin"
        #end
    end

    nodes.each do |node_config|
        config.vm.define node_config[:hostname] do |node|
            node.vm.hostname = node_config[:hostname] + '.' + domain
            node.vm.network "private_network", ip: node_config[:ip]
            node.vm.synced_folder "kubernetes", "/etc/kubernetes/shared"
            node.vm.provider "virtualbox" do |v|
                v.memory = 2048
                v.cpus = 2
                v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
            end
            # Not working with puppet 4.*
            #node.vm.provision "puppet" do |puppet|
            #  puppet.manifests_path = "puppet/manifests"
            #  puppet.manifest_file = "node.pp"
            #  puppet.module_path = "puppet/modules"
            #  puppet.binary_path = "/opt/puppetlabs/bin"
            #end
        end
    end
end