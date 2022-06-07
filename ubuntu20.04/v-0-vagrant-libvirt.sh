# -*k mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'


nodes = [
  { :hostname => 'stor1', :ip1 => '192.168.11.61', :ip2 => '192.168.21.61', :box => 'xenial64', :ram => 4*1024, :osd => 'yes' },
  { :hostname => 'stor2', :ip1 => '192.168.11.62', :ip2 => '192.168.21.62', :box => 'xenial64', :ram => 4*1024, :osd => 'yes' },
  { :hostname => 'stor3', :ip1 => '192.168.11.63', :ip2 => '192.168.21.63', :box => 'xenial64', :ram => 4*1024, :osd => 'yes' },
  { :hostname => 'stor4', :ip1 => '192.168.11.64', :ip2 => '192.168.21.64', :box => 'xenial64', :ram => 4*1024, :osd => 'yes' },
  { :hostname => 'stor5', :ip1 => '192.168.11.65', :ip2 => '192.168.21.65', :box => 'xenial64', :ram => 4*1024, :osd => 'yes' },
  { :hostname => 'stor6', :ip1 => '192.168.11.66', :ip2 => '192.168.21.66', :box => 'xenial64', :ram => 4*1024, :osd => 'yes' },
  { :hostname => 'stor7', :ip1 => '192.168.11.67', :ip2 => '192.168.21.67', :box => 'xenial64', :ram => 4*1024, :osd => 'yes' },
  { :hostname => 'stor8', :ip1 => '192.168.11.68', :ip2 => '192.168.21.68', :box => 'xenial64', :ram => 4*1024, :osd => 'yes' }
]

Vagrant.configure("2") do |config|.
  nodes.each do |node|.
    config.vm.define node[:hostname] do |nodeconfig|.
#      nodeconfig.vm.box = "ubuntu-20.04"
#      nodeconfig.vm.box = "bento/ubuntu-20.04"
      nodeconfig.vm.box = "generic/ubuntu2004"

      nodeconfig.vm.box_check_update = false

      nodeconfig.vm.hostname = node[:hostname].

      nodeconfig.vm.network :public_network,
      :dev => "br0",
      :mode => "bridge",
      :type => "bridge",
      ip: node[:ip1]

#      nodeconfig.vm.network :public_network, ip: node[:ip1] , bridge: "eno1"
#      nodeconfig.vm.network :public_network, ip: node[:ip2] #, bridge: "eno1"

#      nodeconfig.vm.network :public_network, :dev => "br0", :mode => "bridge", :type => "bridge", ip: node[:ip1]
#      nodeconfig.vm.network :private_network, :ip => "10.20.30.40"

#       nodeconfig.vm.network :public_network #, :dev => "br0", :mode => "bridge", :type => "bridge", ip: node[:ip1]

#       nodeconfig.vm.network "public_network", :dev => "bridge0", :mode => "bridge", :type => "bridge"

#    config.vm.network "private_network", ip: "192.168.1.10"
#     nodeconfig.vm.network "private_network", libvirt__network_name: "external", ip: "192.168.11.62", bridge: "eno1"


      memory = node[:ram] ? node[:ram] : 512;.
#      nodeconfig.vm.provider :virtualbox do |vb|
      nodeconfig.vm.provider :libvirt do |vb|

        # Размер RAM памяти
        vb.memory = memory.to_s
        vb.cpus = 2
        vb.storage_pool_name = 'vagrant'

#    vb.host = node[:hostname]

#   v.storage :file, :size => '20G'
#    v.storage :file, :size => '40G', :bus => 'scsi', :type => 'raw', :discard => 'unmap', :detect_zeroes => 'on'



        # Добавление жесткого диска, если такой указан в конфигурации
        if node[:osd] == "yes"
            vb.storage :file, :size => '20G'
#            vb.storage :file, :size => '40G', :bus => 'scsi', :type => 'raw', :discard => 'unmap', :detect_zeroes => 'on'
#            vb.storage :file, :size => '20G', :path => './my_shared_disk.img', :allow_existing => true, :shareable => true, :type => 'raw'


#           # Не создавать диск, если он уже существует
#           if !File.exists? ("disk_osd-#{node[:hostname]}.vdi")
#               vb.customize [ "createhd", "--filename", "//raid/disk_osd-#{node[:hostname]}", "--variant", "Fixed", "--size", 20 * 1024]
#               vb.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 3, "--device", 0, "--type", "hdd", "--medium", "//raid/disk_osd-#{node[:hostname]}.vdi" ]
#           else
#               # Подключить созданный диск к поточной VM
#               vb.customize [ "storageattach", :id, "--storagectl", "SATA Controller", "--port", 3, "--device", 0, "--type", "hdd", "--medium", "//raid/disk_osd-#{node[:hostname]}.vdi" ]
#           end
        end.
      end.
#      nodeconfig.vm.provision :shell, :inline => "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config; sudo systemctl restart sshd;", run: "always"
    end
  end.

  #config.hostmanager.enabled = true.
  #config.hostmanager.manage_guest = true.

  # не проверять репозиторий на наличие обновлений
  config.vm.box_check_update = false

  # можно подключаться по паролю
  #config.ssh.keys_only = false
end


