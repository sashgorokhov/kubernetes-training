# -*- mode: ruby -*-
# vi: set ft=ruby :

domain = 'example.com'

puppet_master_ip = '172.16.32.64'

nodes = [
  {:hostname => 'master',  :ip => '172.16.32.10'},
  {:hostname => 'node1', :ip => '172.16.32.11'},
  {:hostname => 'node2', :ip => '172.16.32.12'},
]
# NOTE: If you add something to nodes, dont forget to modify puppet/manifests/hosts.pp !!

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
        if [ "$HOSTNAME" == 'puppet' ]; then
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

    nodes.each do |node_config|
        config.vm.define node_config[:hostname], primary: node_config[:hostname] == 'master', autostart: node_config[:hostname] == 'master' do |node|
            node.vm.hostname = node_config[:hostname] + '.' + domain
            node.vm.network "private_network", ip: node_config[:ip]
            node.vm.provider "virtualbox" do |v|
                v.memory = node_config[:hostname] == 'master' ? 4096 : 1024
                v.cpus = node_config[:hostname] == 'master' ? 2 : 1
                v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
            end
            node.vm.synced_folder "kubernetes", "/etc/kubernetes/shared"
            if node_config[:hostname] == 'master'
                node.vm.network "forwarded_port", guest: 8080, host: 8080
            end
        end
    end
end