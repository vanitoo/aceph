#!/bin/bash
#запускаем на VM11



cephadm shell -- ceph -s   # выйти ctrl+p and ctrl+q


tee remote-hosts<<EOF
vm11
vm12
vm13
vm14

vm21
vm22
vm23
vm24

vm31
vm32
vm33
vm34

vm41
vm42
vm43
vm44
EOF

for node_id in $(cat remote-hosts);
do  ceph orch host add $node_id; done

ceph orch host label add vm11 mon
ceph orch host label add vm21 mon
ceph orch host label add vm31 mon
ceph orch host label add vm41 mon

ceph orch host ls

ceph orch apply mon label:mon

for node_id in $(cat remote-hosts);
do  ceph orch host label add $node_id osd; done
#ceph orch host label add stor1 osd

ceph orch host ls



ceph health detail

ceph orch device ls --wide --refresh
ceph orch apply osd --all-available-devices                    #вкл авто добавление
ceph orch apply osd --all-available-devices --unmanaged=true   #выкл авто добавление


ceph orch daemon add osd stor1:/dev/sdb
ceph orch daemon add osd stor2:/dev/sdb



for node_id in $(cat remote-hosts);
do
 ssh $node_id 'sudo apt install zabbix-agent -y';
done

ceph mgr module enable zabbix
https://docs.ceph.com/en/latest/mgr/zabbix/



ceph osd pool create datapool 128 128
ceph osd lspools
ceph osd pool ls detail
ceph osd pool get datapool all


#выйти из cli ceph
rbd pool init datapool
rbd create --size 500G datapool/rbdvol1
rbd map datapool/rbdvol1
rbd feature disable datapool/rbdvol1 object-map fast-diff deep-flatten
rbd map datapool/rbdvol1

rbd status datapool/rbdvol1
rbd info datapool/rbdvol1
rbd device list




rbd create --size 10G datapool/iscsi-image3
#Создайте цель scsi
tgtadm --lld iscsi --mode target --op new --tid 1 --targetname iqn.2013-15.com.example:cephtgt.target0
#Создай луну
tgtadm --lld iscsi --mode logicalunit --op new --tid 1 --lun 1 --backing-store datapool/iscsi-image3 --bstype rbd
#права
tgtadm --lld iscsi --op bind --mode target --tid 1 -I ALL
#инфо
tgtadm --lld iscsi --mode target --op show
