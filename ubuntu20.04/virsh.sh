

hostnamectl set-hostname node1

sudo apt update
sudo apt install mc -y

lsmod | grep kvm
cat /sys/module/kvm_intel/parameters/nested
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1
sudo bash -c 'echo "options kvm_intel nested=1" >> /etc/modprobe.d/kvm.conf'

sudo apt install libvirt-clients -y
sudo virt-host-validate




# устанавливаем виртуализацию
sudo apt install libvirt-daemon-system qemu qemu-kvm virtinst -y
usermod -a -G libvirt-admin,libvirt-qemu,libvirt,disk,kvm $(whoami)

sudo apt install cockpit cockpit-machines -y
sudo systemctl enable --now cockpit.socket


******************

# устанавливаем Vagrant
curl -O https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_x86_64.deb
sudo apt install ./vagrant_2.2.19_x86_64.deb

sudo apt install vagrant -y
vagrant plugin install vagrant-libvirt


sudo apt install vagrant ruby-libvirt
sudo apt install qemu libvirt-daemon-system libvirt-clients ebtables dnsmasq-base
sudo apt install libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev
sudo apt install libguestfs-tools

 bridge-utils


sudo apt install build-essential
sudo apt install libvirt-dev



sudo apt install curl


vagrant box add "centos/7" и выбрав libvirt
vagrant init centos/7

nano ./Vagrantfile
>> add
config.vm.synced_folder ".", "/vagrant", disabled: true

vagrant up --provider=libvirt



********************


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

************


sudo fdisk /dev/vdb
g, n, enter, enter, enter, w

sudo fdisk /dev/vdc
g, n, enter, enter, enter, w

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

mount -a

**************

sudo virsh pool-define-as default1 --type dir --target /raid1
virsh pool-list --all
virsh pool-build default1
virsh pool-start default1
virsh pool-autostart default1
virsh pool-info default1

sudo virsh pool-define-as default2 --type dir --target /raid2
virsh pool-list --all
virsh pool-build default2
virsh pool-start default2
virsh pool-autostart default2
virsh pool-info default2

***************

apt install libguestfs-tools -y
apt install bridge-utils -y
libguestfs-test-tool


****************

# This is the network config written by 'subiquity'
network:
  version: 2
#  renderer: NetworkManager

  ethernets:
    eno1:
      dhcp4: no
#      addresses: [192.168.11.113/24, ]
#      gateway4: 192.168.11.1
#      nameservers:
#              addresses: [1.1.1.1, ]

  bridges:
    br0:
      interfaces: [eno1]
      addresses: [192.168.11.113/24]
      gateway4: 192.168.11.1
      mtu: 1500
      nameservers:
        addresses: [8.8.8.8]
      parameters:
        stp: true
        forward-delay: 4
      dhcp4: no
      dhcp6: no






****************


./create-vm.sh vm1 1 1 192.168.22.111



**************

echo "tzdata tzdata/Areas select Europe" | debconf-set-selections
echo "tzdata tzdata/Zones/Europe select Moscow" | debconf-set-selections
rm -f /etc/localtime /etc/timezone
dpkg-reconfigure -f noninteractive tzdata


locale-gen ru_RU ru_RU.UTF-8 ru_RU ru_RU.UTF-8
localedef -c -i ru_RU -f UTF-8 ru_RU.UTF-8
dpkg-reconfigure --frontend noninteractive locales
update-locale LANG=ru_RU.UTF-8


