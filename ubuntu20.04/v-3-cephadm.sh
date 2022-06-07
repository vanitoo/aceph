
sudo useradd -m -s /bin/bash cephadmin
sudo passwd cephadmin
sudo bash -c 'echo "cephadmin ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/cephadmin'
sudo chmod 0440 /etc/sudoers.d/cephadmin
su - cephadmin



**** установка на всех нодах ***** автоматом


for node_id in $(cat remote-hosts);
do
 ssh $node_id 'sudo apt update';
 ssh $node_id 'sudo apt install python3 -y';
 ssh $node_id 'sudo apt install docker.io -y';
 ssh $node_id 'sudo apt install chrony -y';
 ssh $node_id 'sudo apt install lvm2 -y';
 ssh $node_id 'curl --silent https://download.ceph.com/keys/release.asc | sudo apt-key add - ';
 ssh $node_id 'curl --silent --remote-name --location https://github.com/ceph/ceph/raw/octopus/src/cephadm/cephadm';
 ssh $node_id 'chmod +x cephadm';
 ssh $node_id 'sudo cp ./cephadm /usr/sbin/cephadm'; 
 ssh $node_id 'sudo ./cephadm add-repo --release octopus';
 ssh $node_id 'sudo ./cephadm install ceph-common';
done

sudo cephadm install
sudo mkdir -p /etc/ceph
sudo cephadm bootstrap \
  --mon-ip 192.168.11.61 \
  --ssh-user vagrant \
  --initial-dashboard-user admin \
  --initial-dashboard-password 123qweASD



ssh-copy-id -f -i /etc/ceph/ceph.pub stor1
ssh-copy-id -f -i /etc/ceph/ceph.pub stor2
ssh-copy-id -f -i /etc/ceph/ceph.pub stor3
ssh-copy-id -f -i /etc/ceph/ceph.pub stor4
ssh-copy-id -f -i /etc/ceph/ceph.pub stor5
ssh-copy-id -f -i /etc/ceph/ceph.pub stor6
ssh-copy-id -f -i /etc/ceph/ceph.pub stor7
ssh-copy-id -f -i /etc/ceph/ceph.pub stor8


sudo cephadm shell

ceph orch host add stor2
ceph orch host add stor3
ceph orch host add stor4
ceph orch host add stor5
ceph orch host add stor6
ceph orch host add stor7
ceph orch host add stor8

ceph orch host label add stor1 mon
ceph orch host label add stor3 mon
ceph orch host label add stor5 mon
ceph orch host label add stor7 mon

ceph orch host ls

ceph orch apply mon label:mon

ceph orch host label add stor1 osd
ceph orch host label add stor2 osd
ceph orch host label add stor3 osd
ceph orch host label add stor4 osd
ceph orch host label add stor5 osd
ceph orch host label add stor6 osd
ceph orch host label add stor7 osd
ceph orch host label add stor8 osd

ceph orch host ls



ceph health detail


ceph orch daemon add osd stor1:/dev/sdb
ceph orch daemon add osd stor2:/dev/sdb



for node_id in $(cat remote-hosts);
do
 ssh $node_id 'sudo apt install zabbix-agent -y';
done

ceph mgr module enable zabbix
https://docs.ceph.com/en/latest/mgr/zabbix/