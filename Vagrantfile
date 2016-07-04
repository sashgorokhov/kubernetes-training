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
    config.vm.box = "sashgorokhov/trusty64-updated-kernel"

    config.vm.provision "shell", name: "Install puppet", inline: <<-SHELL
        set -ex
        if [ ! -f /home/vagrant/puppetlabs-release-pc1-trusty.deb ]; then
            cd /home/vagrant
            wget https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
            dpkg -i puppetlabs-release-pc1-trusty.deb
            apt-get update -qq
        fi
        apt-get autoremove -qqy
        puppet apply --modulepath=/vagrant/puppet/modules -e "class{'puppet::hosts':}"
        apt-get install -qqy puppet-agent
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
        end
        puppet.vm.synced_folder "puppet/manifests", "/etc/puppetlabs/code/environments/production/manifests"
        puppet.vm.synced_folder "puppet/modules", "/etc/puppetlabs/code/environments/production/modules"
        puppet.vm.hostname = "puppet." + domain
        puppet.vm.network "private_network", ip: puppet_master_ip
        #puppet.vm.provision "shell", name: "Install puppet server", inline: <<-SHELL
        #    puppet apply --modulepath=/vagrant/puppet/modules -e "class{'puppet::server':}"
        #SHELL
    end

    nodes.each do |node_config|
        config.vm.define node_config[:hostname], primary: node_config[:hostname] == 'master', autostart: node_config[:hostname] == 'master' do |node|
            node.vm.hostname = node_config[:hostname] + '.' + domain
            node.vm.network "private_network", ip: node_config[:ip]
            node.vm.provider "virtualbox" do |v|
                v.memory = node_config[:hostname] == 'master' ? 4096 : 1024
                v.cpus = node_config[:hostname] == 'master' ? 2 : 1
            end
            if node_config[:hostname] == 'master'
                node.vm.synced_folder "kubernetes/manifests", "/etc/kubernetes/manifests"
            end
            #node.vm.provision "shell", inline: <<-SHELL
            #SHELL
        end
    end

    #puppet_nodes.each do |node|
    #    config.vm.define node[:hostname] do |node_config|
    #        node_config.vm.hostname = node[:hostname] + '.' + domain
    #        node_config.vm.network :private_network, ip: node[:ip]
    #        if node[:fwdhost]
    #            node_config.vm.network :forwarded_port, guest: node[:fwdguest], host: node[:fwdhost]
    #        end
    #        if node[:master]
    #            node_config.vm.synced_folder "kubernetes/manifests/", "/etc/kubernetes/manifests"
    #        end
    #        memory = node[:ram] ? node[:ram] : 1024;
    #        node_config.vm.provider :virtualbox do |vb|
    #            vb.customize [
    #                'modifyvm', :id,
    #                '--name', node[:hostname],
    #                '--memory', memory.to_s
    #            ]
    #        end
    #        node_config.vm.provision "shell", inline: <<-SHELL
    #            if [ ! -f /home/vagrant/puppetlabs-release-trusty.deb ]; then
    #                cd /home/vagrant
    #                wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
    #                dpkg -i puppetlabs-release-trusty.deb
    #                apt-get update -qq
    #            fi
    #            if ! `lsmod | grep -q br_netfilter`; then
    #              echo "br_netfilter kernel module not found, upgrading kernel"
    #              apt-get install -y linux-image-3.19.0-33-generic linux-image-extra-3.19.0-33-generic
    #              echo "br_netfilter" | tee -a /etc/modules
    #              echo "You need to reload machine."
    #              exit 1
    #            else
    #              apt-get autoremove -qq
    #            fi
    #        SHELL
    #        node_config.vm.provision :puppet do |puppet|
    #          puppet.manifests_path = 'puppet/manifests'
    #          puppet.module_path = 'puppet/modules'
    #        end
    #    end
    #end
end