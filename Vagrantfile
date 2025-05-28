# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  #  Grab a box that works with Apple Silicon
  config.vm.box = "hashicorp-education/ubuntu-24-04"
  config.vm.box_version = "0.1.0"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
  end

  #  Configure SSH on the VMs
  config.ssh.insert_key = true
  config.ssh.keys_only = true
  config.ssh.forward_agent = true

  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y docker.io
    apt-get install -y python-is-python3 python3-pip pipx
    pipx install docker-py --include-deps
    pipx ensurepath
  SHELL

  (1..6).each do |i|
    if [1,2,3].include?(i)
      config.vm.define "manager-#{i}" do |node|
        node.vm.hostname = "manager-#{i}"
        node.vm.network "private_network", ip: "192.168.33.1#{i}"
        # node.vm.network "forwarded_port", guest: 80, host: 8080
      end
    else
      config.vm.define "worker-#{i}" do |node|
        node.vm.hostname = "worker-#{i}"
        node.vm.network "private_network", ip: "192.168.33.1#{i}"
        # node.vm.network "forwarded_port", guest: 80, host: 8080
        # hack to only run once at the end
        if i == 6
          node.vm.provision "ansible" do |ansible|
            ansible.playbook = "playbooks/build_docker_swarm.yaml"
            #  ansible.playbook = "swarm.yml"
            #  ansible.playbook = "swarm-facts.yml"
            ansible.limit = "all"
            ansible.extra_vars = {
              swarm_iface: "enp0s8"
            }
            ansible.groups = {
              "managers" => ["manager-[1:3]"],
              "workers"  => ["worker-[4:6]"],
            }
            ansible.raw_arguments = [
              "-M ./library"
            ]
          end
        end
      end
    end
  end
end
