
sudo apt-get install libguestfs-tools
  export LIBGUESTFS_DEBUG=1 LIBGUESTFS_TRACE=1
libguestfs-tools
sudo chmod +r /boot/vmlinuz-`uname -r`


sudo virt-install \
  --virt-type=kvm \
  --name ubuntu2004\
  --ram 1024 \
  --vcpus=1 \
  --os-variant=ubuntu-20.04 \
  --hvm \
  --cdrom=/var/lib/libvirt/boot/ubuntu-16.04.1-server-amd64.iso \
  --network network=default,model=virtio \
  --graphics vnc \
  --disk path=/var/lib/libvirt/images/ubuntu1604.img,size=20,bus=virtio


virt-builder ubuntu-20.04 \
  --size 20G
  --format qcow2 \
  --output /raid/1.qcow2 \
  --hostname client \
  --install wget,net-tools \
  --root-password password:1111 \
  --run-command "ssh-keygen -A" \
  --run-command "sed -i \"s/.*PermitRootLogin.*/PermitRootLogin yes/g\" /etc/ssh/sshd_config" \
  --copy-in netcfg_ubn.yaml:/etc/netplan/




virt-install \
--import \
--name client \
--ram 2048 \
--disk /raid/ubuntu-20.04.qcow2 \
--network network=net_1 \
--network network=host-bridge \
--graphics vnc 

--noautoconsole


#--network network=net_1,mac=52:54:56:11:00:00 \