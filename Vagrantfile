Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.hostname = "zero-1"
  config.vm.define "zero-1"
  config.vm.network "private_network", ip: "10.16.73.20"
  config.vm.provision "ansible" do |ansible|
    ansible.verbose = "v"
    ansible.playbook = "provision.yml"
    ansible.become = true
    
    ansible.extra_vars = {
      ingress_ip: "10.16.73.20",
      private_iface: "eth0",
      public_iface: "eth1"
    }
    galaxy_role_file = "requirements.yml"
    # https://www.vagrantup.com/docs/provisioning/ansible_intro.html
    ansible.groups = {
      "manager" => ["zero-1"],
      "runner" => ["zero-1"],
      "all_groups:children" => ["manager", "runner"],
    }

  end
end