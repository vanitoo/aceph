#! /usr/bin/env bash
echo "Installing"

#su vagrant

#sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-add-repository ppa:ansible/ansible-2.6 -y

sudo apt update && sudo apt install ansible -y

ssh-keygen -b 2048 -t rsa -f /home/vagrant/.ssh/id_rsa -q -N ""

tee -a remote-hosts.txt<<EOF
mon1
mon2
mon3
osd1
osd2
osd3
EOF

sudo tee -a /etc/hosts<<EOF
192.168.11.91 mon1
192.168.11.92 mon2
192.168.11.93 mon3
192.168.11.95 osd1
192.168.11.96 osd2
192.168.11.97 osd3
EOF

ssh-keyscan -f ./remote-hosts.txt >> ~/.ssh/known_hosts

echo vagrant > pas.txt

sudo apt install sshpass -y
sshpass -f pas.txt ssh-copy-id $(whoami)@mon1
sshpass -f pas.txt ssh-copy-id $(whoami)@mon2
sshpass -f pas.txt ssh-copy-id $(whoami)@mon3
sshpass -f pas.txt ssh-copy-id $(whoami)@osd1
sshpass -f pas.txt ssh-copy-id $(whoami)@osd2
sshpass -f pas.txt ssh-copy-id $(whoami)@osd3


sudo apt install git -y
git clone https://github.com/ceph/ceph-ansible.git
cd ceph-ansible/
git checkout stable-3.2
cd ..
sudo cp -a ceph-ansible/* /etc/ansible/

sudo apt install python-pip -y
sudo pip install notario netaddr -q

sudo cp hosts /etc/ansible/hosts

sudo cp ceph /etc/ansible/group_vars/ceph
sudo cp osds /etc/ansible/group_vars/osds
sudo mkdir /etc/ansible/fetch
sudo chown vagrant /etc/ansible/fetch

cd /etc/ansible
sudo mv site.yml.sample site.yml

ansible-playbook site.yml
