
nodes = [ 
  { :hostname => 'mon1', :ip => '192.168.11.91', :box => 'xenial64' }, 
  { :hostname => 'mon2', :ip => '192.168.11.92', :box => 'xenial64' }, 
  { :hostname => 'mon3', :ip => '192.168.11.93', :box => 'xenial64' }, 
  { :hostname => 'osd1',  :ip => '192.168.11.95', :box => 'xenial64', :ram => 1024, :osd => 'yes' }, 
  { :hostname => 'osd2',  :ip => '192.168.11.96', :box => 'xenial64', :ram => 1024, :osd => 'yes' }, 
  { :hostname => 'osd3',  :ip => '192.168.11.97', :box => 'xenial64', :ram => 1024, :osd => 'yes' }, 
  { :hostname => 'ansible', :ip => '192.168.11.90', :box => 'xenial64' }
] 
 
Vagrant.configure("2") do |config| 
  nodes.each do |node| 
    config.vm.define node[:hostname] do |nodeconfig| 
#     nodeconfig.vm.box = "bento/ubuntu-18.10" 
#	    nodeconfig.vm.box = "bento/ubuntu-16.04" 
      nodeconfig.vm.box = "bento/debian-10" 
      nodeconfig.vm.hostname = node[:hostname] 
      nodeconfig.vm.network :public_network, ip: node[:ip] 
#      nodeconfig.vm.network :private_network, ip: node[:ip] 
      nodeconfig.vm.synced_folder ".", "/vagrant", disabled: true


      if node[:hostname] == "ansible"
        nodeconfig.vm.synced_folder "scripts/", "/home/vagrant", type: "rsync",  rsync__exclude: ".git/"
# =>    nodeconfig.vm.provision "shell", inline: "/vagrant/1.sh", :privileged => false
      end
 
      memory = node[:ram] ? node[:ram] : 512; 
      nodeconfig.vm.provider :virtualbox do |vb| 
        vb.customize [ 
          "modifyvm", :id, 
          "--memory", memory.to_s, 
        ] 
        if node[:osd] == "yes"         
          vb.customize [ "createhd", "--filename", "disk_osd-#{node[:hostname]}", "--size", "10000" ] 
          vb.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 3, "--device", 0, "--type", "hdd", "--medium", "disk_osd-#{node[:hostname]}.vdi" ] 
        end 
      end 
    end 
    #config.hostmanager.enabled = true 
    #config.hostmanager.manage_guest = true 
	
	
  end 
end
