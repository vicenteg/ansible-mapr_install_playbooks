require 'etc'
username = Etc.getlogin

Vagrant.configure("2") do |config|
  disk_size = 24 * 1024
  memory = (8 * 1024).round
  config.vm.synced_folder ".","/vagrant", disabled: true
  config.vm.define "node1" do |node1|
  
    node1.vm.box = "ecnivny/centos-6.5"
    
    node1.vm.hostname = "node1"
    node1.vm.network :private_network, :ip =>'192.168.99.0', :auto_network => true, :type => "dhcp" 

    node1.vm.provider :virtualbox do |provider|
      provider.name = "mapr_singlenode"
      provider.cpus = 2
      provider.customize ["modifyvm", :id, "--memory", memory]
    end
  end

  config.vm.provision "ansible" do |ansible|
    ansible.inventory_path = 'vagrant_hosts'
    ansible.host_key_checking = false
    ansible.sudo = true
    ansible.extra_vars = { "mapr_disks" => [ "/dev/sdb" ] }
    ansible.playbook = "mapr_install.yml"
  end
end
