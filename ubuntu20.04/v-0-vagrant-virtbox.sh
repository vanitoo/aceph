nodes = [
  { :hostname => 'stor1', :ip1 => '192.168.11.61', :ip2 => '192.168.21.61', :box => 'xenial64', :ram => 1024, :osd => 'yes' },
  { :hostname => 'stor2', :ip1 => '192.168.11.62', :ip2 => '192.168.21.62', :box => 'xenial64', :ram => 1024, :osd => 'yes' },
  { :hostname => 'stor3', :ip1 => '192.168.11.63', :ip2 => '192.168.21.63', :box => 'xenial64', :ram => 1024, :osd => 'yes' },
  { :hostname => 'stor4', :ip1 => '192.168.11.64', :ip2 => '192.168.21.64', :box => 'xenial64', :ram => 1024, :osd => 'yes' },
  { :hostname => 'stor5', :ip1 => '192.168.11.65', :ip2 => '192.168.21.65', :box => 'xenial64', :ram => 1024, :osd => 'yes' },
  { :hostname => 'stor6', :ip1 => '192.168.11.66', :ip2 => '192.168.21.66', :box => 'xenial64', :ram => 1024, :osd => 'yes' },
  { :hostname => 'stor7', :ip1 => '192.168.11.67', :ip2 => '192.168.21.67', :box => 'xenial64', :ram => 1024, :osd => 'yes' },
  { :hostname => 'stor8', :ip1 => '192.168.11.68', :ip2 => '192.168.21.68', :box => 'xenial64', :ram => 1024, :osd => 'yes' }
]

Vagrant.configure("2") do |config| 
  nodes.each do |node| 
    config.vm.define node[:hostname] do |nodeconfig| 
      nodeconfig.vm.box = "ubuntu-20.04" 
      nodeconfig.vm.hostname = node[:hostname] 
      nodeconfig.vm.network :public_network, ip: node[:ip1] #, bridge: "eno1"
      nodeconfig.vm.network :public_network, ip: node[:ip2] #, bridge: "eno1"
      
      memory = node[:ram] ? node[:ram] : 512; 
      nodeconfig.vm.provider :virtualbox do |vb| 
        # Размер RAM памяти
        vb.customize ["modifyvm", :id, "--memory", memory.to_s, ] 
        
        # Добавление жесткого диска, если такой указан в конфигурации
        if node[:osd] == "yes"
           # Не создавать диск, если он уже существует
           if !File.exists? ("disk_osd-#{node[:hostname]}.vdi")
               vb.customize [ "createhd", "--filename", "disk_osd-#{node[:hostname]}", "--variant", "Fixed", "--size", 20 * 1024"] 
               vb.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 3, "--device", 0, "--type", "hdd", "--medium", "disk_osd-#{node[:hostname]}.vdi" ] 
           else
               # Подключить созданный диск к поточной VM       
               vb.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 3, "--device", 0, "--type", "hdd", "--medium", "disk_osd-#{node[:hostname]}.vdi" ] 
           end
        end 
      end 
      nodeconfig.vm.provision :shell, :inline => "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config; sudo systemctl restart sshd;", run: "always"
    end
  end 
   
  #config.hostmanager.enabled = true 
  #config.hostmanager.manage_guest = true 
  # не проверять репозиторий на наличие обновлений
  config.vm.box_check_update = false

  # имя пользователя
  #config.ssh.username = 'user'

  # пароль пользователя
  #config.ssh.password = '123qwe'

  # можно подключаться по паролю
  #config.ssh.keys_only = false
end



#      nodeconfig.vm.network :public_network, ip: node[:ip] 
#      nodeconfig.vm.network :private_network, ip: node[:ip] 
#      nodeconfig.vm.synced_folder ".", "/vagrant", disabled: true
#      if node[:hostname] == "ansible"
#        #nodeconfig.vm.network "private_network", type: "dhcp"
#     #nodeconfig.vm.synced_folder "scripts/", "/vagrant", nfs: true
#     nodeconfig.vm.synced_folder "scripts/", "/vagrant", type: "rsync",  rsync__exclude: ".git/"
#     nodeconfig.vm.provision "shell", path: "1.sh", :privileged => false
#     nodeconfig.vm.provision "shell", inline: "/vagrant/1.sh", :privileged => false
#     nodeconfig.vm.provision "file", source: "data/.", destination: "/home/vagrant"
#        #nodeconfig.vm.synced_folder "data/", "/home/vagrant/data"
#        #nodeconfig.vm.provision "shell", inline: $script, :privileged => false
#      end
