# запускаем с админской машины
# добавление хоста

vmhost="vm42"

ssh-keygen -f "/root/.ssh/known_hosts" -R "$vmhost"
ssh-keyscan $vmhost >> ~/.ssh/known_hosts
sshpass -p '123qwe' ssh-copy-id $vmhost

ssh $vmhost 'apt update'
ssh $vmhost 'apt install chrony -y';
ssh $vmhost 'apt install docker.io -y';
ssh $vmhost 'apt install gpg -y';
ssh $vmhost 'apt install curl -y'; 
ssh $vmhost 'curl --silent https://download.ceph.com/keys/release.asc | sudo apt-key add - ';
ssh $vmhost 'curl --silent --remote-name --location https://github.com/ceph/ceph/raw/octopus/src/cephadm/cephadm';
ssh $vmhost 'chmod +x cephadm';
ssh $vmhost 'sudo ./cephadm add-repo --release octopus';
ssh $vmhost 'sudo ./cephadm install ceph-common';

ssh-copy-id -f -i /etc/ceph/ceph.pub $vmhost
sudo ceph orch host add $vmhost
