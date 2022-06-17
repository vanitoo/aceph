#!/bin/bash
#запускаем на DELL (HOST)



# Создаем ключ и распространяем на все ноды
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""

tee remote-hosts<<EOF
host1
host2
host3
host4
EOF


for node_id in $(cat remote-hosts);
do
  sed -i '/^'$node_id'/d' ~/.ssh/known_hosts
  sudo sed -i '/'$node_id'/d' /etc/hosts
done


#sudo bash -c 'cat /etc/hosts | grep 22.10 || true | echo "192.168.22.10 host1" >> /etc/hosts'
#sudo bash -c 'cat /etc/hosts | grep 22.20 || true | echo "192.168.22.20 host2" >> /etc/hosts'
#sudo bash -c 'cat /etc/hosts | grep 22.30 || true | echo "192.168.22.30 host3" >> /etc/hosts'
#sudo bash -c 'cat /etc/hosts | grep 22.40 || true | echo "192.168.22.40 host4" >> /etc/hosts'

sudo tee -a /etc/hosts<<EOF
192.168.22.110 host1
192.168.22.120 host2
192.168.22.130 host3
192.168.22.140 host4
EOF

ssh-keyscan -f ./remote-hosts >> ~/.ssh/known_hosts

sudo apt install sshpass -y

for node_id in $(cat remote-hosts);
do sshpass -p '123qwe' ssh-copy-id root@$node_id; done



# Русификация
for node_id in $(cat remote-hosts);
do
  ssh root@$node_id 'sudo apt update';
  ssh root@$node_id 'echo "tzdata tzdata/Areas select Europe" | debconf-set-selections';
  ssh root@$node_id 'echo "tzdata tzdata/Zones/Europe select Moscow" | debconf-set-selections';
  ssh root@$node_id 'rm -f /etc/localtime /etc/timezone';
  ssh root@$node_id 'dpkg-reconfigure -f noninteractive tzdata';

  ssh root@$node_id 'locale-gen ru_RU ru_RU.UTF-8 ru_RU ru_RU.UTF-8';
  ssh root@$node_id 'localedef -c -i ru_RU -f UTF-8 ru_RU.UTF-8';
  ssh root@$node_id 'dpkg-reconfigure --frontend noninteractive locales';
  ssh root@$node_id 'update-locale LANG=ru_RU.UTF-8';
done



# Устанавливаем компоненты KVM
for node_id in $(cat remote-hosts);
do
  ssh root@$node_id 'apt install chrony -y';
  ssh root@$node_id 'apt install libvirt-clients -y';
  ssh root@$node_id 'virt-host-validate';
  ssh root@$node_id 'apt install libvirt-daemon-system qemu qemu-kvm virtinst -y';
  ssh root@$node_id 'usermod -a -G libvirt-qemu,libvirt,disk,kvm $(whoami)';
  ssh root@$node_id 'apt install cockpit cockpit-machines -y';
  ssh root@$node_id 'systemctl enable --now cockpit.socket';
done



# Создаем Бридж
tee host-bridge.xml<<EOF
<network>
  <name>host-bridge</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
EOF

for node_id in $(cat remote-hosts);
do
  scp host-bridge.xml root@$node_id:/root;
  ssh root@$node_id 'virsh net-define host-bridge.xml';
  ssh root@$node_id 'virsh net-start host-bridge';
  ssh root@$node_id 'virsh net-autostart host-bridge';
  ssh root@$node_id 'virsh net-list --all';
done



# Размечаем и подключаем диски
for node_id in $(cat remote-hosts);
do
  ssh root@$node_id '/sbin/parted /dev/vdb mklabel gpt --script';
  ssh root@$node_id '/sbin/parted /dev/vdb mkpart primary 0% 100% --script';

  ssh root@$node_id '/sbin/parted /dev/vdc mklabel gpt --script';
  ssh root@$node_id '/sbin/parted /dev/vdc mkpart primary 0% 100% --script';

  ssh root@$node_id 'mkfs.ext4 /dev/vdb1';
  ssh root@$node_id 'mkfs.ext4 /dev/vdc1';

  ssh root@$node_id 'mkdir /raid1';
  ssh root@$node_id 'mkdir /raid2';
  ssh root@$node_id 'chmod 700 /raid1';
  ssh root@$node_id 'chmod 700 /raid2';

  ssh root@$node_id 'echo "/dev/vdb1   /raid1   ext4   defaults   1 1" >> /etc/fstab';
  ssh root@$node_id 'echo "/dev/vdc1   /raid2   ext4   defaults   1 1" >> /etc/fstab';

  ssh root@$node_id 'mount -a';
done



# Создаем пулы на этих дисках
for node_id in $(cat remote-hosts);
do
  ssh root@$node_id 'virsh pool-define-as default1 --type dir --target /raid1';
  ssh root@$node_id 'virsh pool-build default1';
  ssh root@$node_id 'virsh pool-start default1';
  ssh root@$node_id 'virsh pool-autostart default1';
  ssh root@$node_id 'virsh pool-info default1';
  ssh root@$node_id 'virsh pool-list --all';

  ssh root@$node_id 'virsh pool-define-as default2 --type dir --target /raid2';
  ssh root@$node_id 'virsh pool-build default2';
  ssh root@$node_id 'virsh pool-start default2';
  ssh root@$node_id 'virsh pool-autostart default2';
  ssh root@$node_id 'virsh pool-info default2';
  ssh root@$node_id 'virsh pool-list --all';
done



for node_id in $(cat remote-hosts);
do
  ssh root@$node_id 'apt install libguestfs-tools -y';
  ssh root@$node_id 'libguestfs-test-tool';
done



for node_id in $(cat remote-hosts);
do
  ssh root@$node_id 'echo "# Turn off IPv6" >> /etc/sysctl.conf';
  ssh root@$node_id 'echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf';
  ssh root@$node_id 'echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf';
  ssh root@$node_id 'echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf';

  ssh root@$node_id 'echo "# Turn CEPH" >> /etc/sysctl.conf';  
  ssh root@$node_id 'echo "kernel.pid_max = 4194303" >> /etc/sysctl.conf';
  ssh root@$node_id 'echo "fs.aio-max-nr=1048576" >> /etc/sysctl.conf';
  ssh root@$node_id 'sysctl -p';
done

