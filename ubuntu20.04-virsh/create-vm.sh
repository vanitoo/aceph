#!/bin/bash

if [ $# -ne 5 ] ; then
    echo "Usage: $0 <NAME> <RAM_GB> <CPUs> <IP> <HDD1_GB>"
    exit 1
fi

NAME=$1
RAM_MB=$(($2*1024))
VCPUS=$3
IP=$4
HDD1_GB=$5'G'


tee 01-netcfg.yaml<<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      addresses:
        - $IP/24
      gateway4: 192.168.22.1
      nameservers:
              addresses: [1.1.1.1, ]

EOF


if virsh list --all | grep -q " $NAME "; then
    if virsh domstate $NAME | grep -q "running"; then
      virsh destroy $NAME
    fi
    virsh undefine $NAME --snapshots-metadata --remove-all-storage
fi


virt-builder ubuntu-20.04      \
 --format qcow2                \
 --output /raid1/$NAME.qcow2   \
 --hostname $NAME              \
 --install mc,net-tools        \
 --root-password password:123qwe \
 --run-command "ssh-keygen -A" \
 --run-command "sed -i \"s/.*PermitRootLogin.*/PermitRootLogin yes/g\" /etc/ssh/sshd_config" \
 --copy-in 01-netcfg.yaml:/etc/netplan/


qemu-img create -f qcow2 /raid2/$NAME.qcow2 $HDD1_GB


virt-install                    \
 --autostart                    \
 --connect qemu:///system       \
 --virt-type=kvm                \
 --os-type=linux                \
 --os-variant=ubuntu20.04       \
 --name=$NAME                   \
 --ram=$RAM_MB                  \
 --arch=x86_64                  \
 --disk=/raid1/$NAME.qcow2,format=qcow2,bus=virtio   \
 --disk=/raid2/$NAME.qcow2,format=qcow2,bus=virtio  \
 --network bridge=br0,model=virtio                   \
 --vcpus=$VCPUS                 \
 --cpu host                     \
 --check-cpu                    \
 --graphics vnc,listen=0.0.0.0  \
 --noautoconsole                \
 --boot hd                      \
 --import

