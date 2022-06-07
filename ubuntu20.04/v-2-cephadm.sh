
sudo tee hosts<<EOF
stor1
stor2
stor3
stor4
stor5
stor6
stor7
stor8
EOF

for node_id in $(cat hosts);
do ssh $node_id 'sudo apt update && sudo apt install chrony -y'; done

#vim /etc/chrony/chrony.conf
#systemctl restart chronyd


for node_id in $(cat hosts);
do ssh $node_id 'date'; done



sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/#g' /etc/ssh/sshd_config
systemctl restart ssh



useradd cephadmin
echo '12345678' | passwd --stdin cephadmin # Установить пароль шифрования
echo "cephadmin ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephadmin #sudo Пароль не требуется
chmod 0440 /etc/sudoers.d/cephadmin # Невозможно удалить этого пользователя


sudo useradd -m -s /bin/bash cephadmin
sudo passwd cephadmin

sudo bash -c 'echo "cephadmin ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/cephadmin'
sudo chmod 0440 /etc/sudoers.d/cephadmin


su - cephadmin
sudo cephadm bootstrap --mon-ip 192.168.11.61

docker ps



************* установка на главной ноде ****** в ручную

sudo apt update
sudo apt install docker.io -y
curl --silent https://download.ceph.com/keys/release.asc | sudo apt-key add -
curl --silent --remote-name --location https://github.com/ceph/ceph/raw/octopus/src/cephadm/cephadm
chmod +x cephadm
sudo ./cephadm add-repo --release octopus
sudo ./cephadm install

sudo mkdir -p /etc/ceph

sudo ./cephadm cephadm bootstrap \
  --mon-ip 192.168.11.61 \
  --ssh-user vagrant \
  --initial-dashboard-user admin \
  --initial-dashboard-password 123qweASD



************* установка на всех нодах ****** в ручную

sudo apt update
sudo apt install docker.io -y
curl --silent https://download.ceph.com/keys/release.asc | sudo apt-key add -
curl --silent --remote-name --location https://github.com/ceph/ceph/raw/octopus/src/cephadm/cephadm
chmod +x cephadm
sudo ./cephadm add-repo --release octopus
sudo ./cephadm install ceph-common

**** установка на всех нодах ***** автоматом

for node_id in $(cat remote-hosts);
do
 ssh $node_id 'sudo apt update';
 ssh $node_id 'sudo apt install chrony -y';
 ssh $node_id 'sudo apt install docker.io -y';
 ssh $node_id 'curl --silent https://download.ceph.com/keys/release.asc | sudo apt-key add - ';
 ssh $node_id 'curl --silent --remote-name --location https://github.com/ceph/ceph/raw/octopus/src/cephadm/cephadm';
 ssh $node_id 'chmod +x cephadm';
 ssh $node_id 'sudo ./cephadm add-repo --release octopus';
 ssh $node_id 'sudo ./cephadm install ceph-common';
done

sudo mkdir -p /etc/ceph
sudo ./cephadm bootstrap --mon-ip 192.168.11.61


ssh-copy-id -f -i /etc/ceph/ceph.pub stor2
ssh-copy-id -f -i /etc/ceph/ceph.pub stor3
ssh-copy-id -f -i /etc/ceph/ceph.pub stor4
ssh-copy-id -f -i /etc/ceph/ceph.pub stor5
ssh-copy-id -f -i /etc/ceph/ceph.pub stor6
ssh-copy-id -f -i /etc/ceph/ceph.pub stor7
ssh-copy-id -f -i /etc/ceph/ceph.pub stor8

sudo ceph orch host add stor2
sudo ceph orch host add stor3
sudo ceph orch host add stor4
sudo ceph orch host add stor5
sudo ceph orch host add stor6
sudo ceph orch host add stor7
sudo ceph orch host add stor8




vagrant@stor1:~$ sudo ceph orch host add stor2
Error EINVAL: Failed to connect to stor2 (stor2).
Please make sure that the host is reachable and accepts connections using the cephadm SSH key

To add the cephadm SSH key to the host:
> ceph cephadm get-pub-key > ~/ceph.pub
> ssh-copy-id -f -i ~/ceph.pub root@stor2

To check that the host is reachable:
> ceph cephadm get-ssh-config > ssh_config
> ceph config-key get mgr/cephadm/ssh_identity_key > ~/cephadm_private_key
> chmod 0600 ~/cephadm_private_key
> ssh -F ssh_config -i ~/cephadm_private_key root@stor2
vagrant@stor1:~$ cat /etc/ceph/




 sudo ceph health detail
