Vagrant.configure("2") do |config|
  #config.ssh.private_key_path = "~/.ssh/id_rsa"
  #config.ssh.forward_agent = true
  #config.vm.synced_folder ".", "/infrastructure"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 4
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    v.customize ["modifyvm", :id, "--ioapic", "on"]
  end
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.hostname = "zero-manager-0"
  config.vm.define "zero-manager-0"
  config.vm.network "private_network", ip: "10.16.73.20"

  config.vm.provision "ansible" do |ansible|
    ansible.verbose = ""
    ansible.playbook = "provision.yml"
    ansible.become = true
    ansible.compatibility_mode = "2.0"
    
    ansible.extra_vars = {
      ingress_ip: "10.16.73.20",
      base_domain: "zero.ns0.co",
      private_iface: "eth0",
      public_iface: "eth1"
    }
    galaxy_role_file = "requirements.yml"
    # https://www.vagrantup.com/docs/provisioning/ansible_intro.html
    ansible.groups = {
      "manager" => ["zero-manager-0"],
      "runner" => ["zero-manager-0"],
      "all_groups:children" => ["manager", "runner"],
    }

  end
end