# -*- mode: ruby -*-
# vi: set ft=ruby :

domain = 'example.com'
box = 'ubuntu/trusty64'

puppet_nodes = [
  {:hostname => 'puppet',  :ip => '172.16.32.10', :fwdhost => 8140, :fwdguest => 8140, :ram => 4096, :master => true},
  {:hostname => 'node1', :ip => '172.16.32.11'},
#  {:hostname => 'node2', :ip => '172.16.32.12'},
]
# NOTE: If you add something to puppet_nodes, dont forget to modify puppet/manifests/hosts.pp !!

# if, while provisioning with puppet you getting errors like "Could not evaluate: undefined method `exist?'", then simply re-run provision.

Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/trusty64"

    puppet_nodes.each do |node|
        config.vm.define node[:hostname] do |node_config|
            node_config.vm.hostname = node[:hostname] + '.' + domain
            node_config.vm.network :private_network, ip: node[:ip]
            if node[:fwdhost]
                node_config.vm.network :forwarded_port, guest: node[:fwdguest], host: node[:fwdhost]
            end
            if node[:master]
                node_config.vm.synced_folder "kubernetes/manifests/", "/etc/kubernetes/manifests"
            end
            memory = node[:ram] ? node[:ram] : 1024;
            node_config.vm.provider :virtualbox do |vb|
                vb.customize [
                    'modifyvm', :id,
                    '--name', node[:hostname],
                    '--memory', memory.to_s
                ]
            end
            node_config.vm.provision "shell", inline: <<-SHELL
                if [ ! -f /home/vagrant/puppetlabs-release-trusty.deb ]; then
                    cd /home/vagrant
                    wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
                    dpkg -i puppetlabs-release-trusty.deb
                    apt-get update -qq
                fi
                if ! `lsmod | grep -q br_netfilter`; then
                  echo "br_netfilter kernel module not found, upgrading kernel"
                  apt-get install -y linux-image-3.19.0-33-generic linux-image-extra-3.19.0-33-generic
                  echo "br_netfilter" | tee -a /etc/modules
                  echo "You need to reload machine."
                  exit 1
                else
                  apt-get autoremove -qq
                fi
            SHELL
            node_config.vm.provision :puppet do |puppet|
              puppet.manifests_path = 'puppet/manifests'
              puppet.module_path = 'puppet/modules'
            end
        end
    end
end