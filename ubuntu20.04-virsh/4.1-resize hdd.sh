#!/bin/bash
#запускаем на DELL (HOST)

  ssh root@host1 'virsh blockresize vm11 /raid1/vm11.qcow2 20G'
  ssh root@host1 'virsh blockresize vm12 /raid1/vm12.qcow2 20G'
  ssh root@host1 'virsh blockresize vm13 /raid1/vm13.qcow2 20G'
  ssh root@host1 'virsh blockresize vm14 /raid1/vm14.qcow2 20G'

  ssh root@host2 'virsh blockresize vm21 /raid1/vm21.qcow2 20G'
  ssh root@host2 'virsh blockresize vm22 /raid1/vm22.qcow2 20G'
  ssh root@host2 'virsh blockresize vm23 /raid1/vm23.qcow2 20G'
  ssh root@host2 'virsh blockresize vm24 /raid1/vm24.qcow2 20G'

  ssh root@host3 'virsh blockresize vm31 /raid1/vm31.qcow2 20G'
  ssh root@host3 'virsh blockresize vm32 /raid1/vm32.qcow2 20G'
  ssh root@host3 'virsh blockresize vm33 /raid1/vm33.qcow2 20G'
  ssh root@host3 'virsh blockresize vm34 /raid1/vm34.qcow2 20G'

  ssh root@host4 'virsh blockresize vm41 /raid1/vm41.qcow2 20G'
  ssh root@host4 'virsh blockresize vm42 /raid1/vm42.qcow2 20G'
  ssh root@host4 'virsh blockresize vm43 /raid1/vm43.qcow2 20G'
  ssh root@host4 'virsh blockresize vm44 /raid1/vm44.qcow2 20G'



#запускаем на VM11 (192.168.22.111)

for node_id in $(cat remote-hosts);
do
  ssh root@$node_id 'uname -n';
  ssh root@$node_id 'lsblk | grep vda5';
  ssh root@$node_id 'apt install cloud-guest-utils -y';
  ssh root@$node_id 'growpart /dev/vda 2';
  ssh root@$node_id 'growpart /dev/vda 5';
  ssh root@$node_id 'resize2fs /dev/vda5';
  ssh root@$node_id 'lsblk | grep vda5';
done



for node_id in $(cat remote-hosts);
do
  ssh root@$node_id 'uname -n';
  ssh root@$node_id 'lsblk | grep vda5';
done






virsh list --all

virsh shutdown vm11
ping 127.0.0.1 -c 20
qemu-img resize /raid1/vm11.qcow2 +10G
virsh start vm11

virsh blockresize vm42 /raid1/vm42.qcow2 16G


apt install cloud-guest-utils -y
growpart /dev/vda 2
growpart /dev/vda 5
resize2fs /dev/vda5


ceph tell osd.3 bench


