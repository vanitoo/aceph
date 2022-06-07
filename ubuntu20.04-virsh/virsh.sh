
./create-host.sh host1 10 4 192.168.22.110 50 150
./create-host.sh host2 10 4 192.168.22.120 50 150
./create-host.sh host3 10 4 192.168.22.130 50 150
./create-host.sh host4 10 4 192.168.22.140 50 150

./create-vm.sh vm11 2 1 192.168.22.111 30
./create-vm.sh vm12 2 1 192.168.22.112 30

./create-vm.sh vm21 2 1 192.168.22.121 30
./create-vm.sh vm22 2 1 192.168.22.122 30





#подготовка HOST


#************** Устанавливаем русскую локаль
echo "tzdata tzdata/Areas select Europe" | debconf-set-selections
echo "tzdata tzdata/Zones/Europe select Moscow" | debconf-set-selections
rm -f /etc/localtime /etc/timezone
dpkg-reconfigure -f noninteractive tzdata


locale-gen ru_RU ru_RU.UTF-8 ru_RU ru_RU.UTF-8
localedef -c -i ru_RU -f UTF-8 ru_RU.UTF-8
dpkg-reconfigure --frontend noninteractive locales
update-locale LANG=ru_RU.UTF-8



#*************
hostnamectl set-hostname node1

sudo apt update
sudo apt install mc -y

lsmod | grep kvm
cat /sys/module/kvm_intel/parameters/nested
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1
sudo bash -c 'echo "options kvm_intel nested=1" >> /etc/modprobe.d/kvm.conf'



# ************
sudo apt install libvirt-clients -y
sudo virt-host-validate



# устанавливаем виртуализацию
sudo apt install libvirt-daemon-system qemu qemu-kvm virtinst -y
usermod -a -G libvirt-qemu,libvirt,disk,kvm $(whoami)

sudo apt install cockpit cockpit-machines -y
sudo systemctl enable --now cockpit.socket



#******************** настраиваем сеть для виртуализации
tee host-bridge.xml<<EOF
<network>
  <name>host-bridge</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
EOF

virsh net-define host-bridge.xml
virsh net-start host-bridge
virsh net-autostart host-bridge
virsh net-list --all



#************ форматируем и размечаем диски
sudo /sbin/parted /dev/vdb mklabel gpt --script
sudo /sbin/parted /dev/vdb mkpart primary 0% 100% --script

sudo /sbin/parted /dev/vdc mklabel gpt --script
sudo /sbin/parted /dev/vdc mkpart primary 0% 100% --script

sudo mkfs.ext4 /dev/vdb1
sudo mkfs.ext4 /dev/vdc1

mkdir /raid1
mkdir /raid2
chmod 700 /raid1
chmod 700 /raid2

tee -a /etc/fstab<<EOF
/dev/vdb1               /raid1           ext4    defaults        1 1
/dev/vdc1               /raid2           ext4    defaults        1 1
EOF

echo "/dev/vdb1   /raid1   ext4   defaults   1 1" >> /etc/fstab
echo "/dev/vdc1   /raid1   ext4   defaults   1 1" >> /etc/fstab

mount -a



#************** создаем пулы
sudo virsh pool-define-as default1 --type dir --target /raid1
virsh pool-build default1
virsh pool-start default1
virsh pool-autostart default1
virsh pool-info default1
virsh pool-list --all

sudo virsh pool-define-as default2 --type dir --target /raid2
virsh pool-build default2
virsh pool-start default2
virsh pool-autostart default2
virsh pool-info default2
virsh pool-list --all



#***************

sudo apt install libguestfs-tools -y
libguestfs-test-tool

#устанавливаем VM на HOST
mcedit create-vm.sh
chmod u+x create-vm.sh
./create-vm.sh vm21 2 1 192.168.22.121 30

