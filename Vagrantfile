# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/xenial64"
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
  config.vm.network "forwarded_port", guest: 3306, host: 13306

  # We only want this to change when the remote server OS is updated
  config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = "2048"
    vb.cpus = 1
    # Xenial box is 10GB but server is currently 30GB
  end

  # Provision using Ansible
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "scripts/provision-server.yml"
    ansible.extra_vars = "scripts/variables.yml"
  end

  # Deploy using Ansible
  config.vm.provision :ansible do |ansible|
    ansible.playbook = "scripts/deploy-site.yml"
    ansible.extra_vars = "scripts/variables.yml"
  end

end
