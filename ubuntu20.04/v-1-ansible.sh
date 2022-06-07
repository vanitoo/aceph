
sudo bash -c 'echo "vagrant ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vagrant'
sudo chmod 0440 /etc/sudoers.d/vagrant

sudo apt update && sudo apt install ansible sshpass -y

echo "PATH=$PATH:/usr/local/bin" >>~/.bashrc
source ~/.bashrc


#ssh-keygen -b 4096 -t rsa -f /home/$(whoami)/.ssh/id_rsa -q -N ""
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""

tee remote-hosts<<EOF
stor1
stor2
stor3
stor4
stor5
stor6
stor7
stor8
EOF

sudo tee -a /etc/hosts<<EOF
192.168.11.61 stor1
192.168.11.62 stor2
192.168.11.63 stor3
192.168.11.64 stor4
192.168.11.65 stor5
192.168.11.66 stor6
192.168.11.67 stor7
192.168.11.68 stor8
EOF


#sudo bash -c 'cat remote-hosts >> /etc/hosts'

ssh-keyscan -f ./remote-hosts >> ~/.ssh/known_hosts

for node_id in $(cat remote-hosts);
do sshpass -p 'vagrant' ssh-copy-id $(whoami)@$node_id; done

#sshpass -f pas.txt ssh-copy-id $(whoami)@stor228




*************


ansible all -m ping -i remote-hosts



sudo tee 0.yml<<EOF
---
- hosts: stor1
  become: yes
  tasks:
  - name: Chrony 1
    replace:
      path: /etc/chrony/chrony.conf
      regexp: 'pool'
      replace: "# pool"
  - name: Chrony 2
    lineinfile:
      path:  /etc/chrony/chrony.conf
      regexp: '^pool '
      insertafter: '^pool '
      line: server stor1
EOF
ansible-playbook -i remote-hosts 0.yml





sudo tee 1.yml<<EOF
---
- hosts: all
  become: yes
  tasks:
  - name: Install packages
    apt:
      name:
      - mc
      - chrony
      - bash-completion
      state: latest
      cache_valid_time: 3600
EOF
ansible-playbook -i remote-hosts 1.yml


sudo tee 2.yml<<EOF
---
- hosts: all
  become: yes
  tasks:
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.11.61 stor1'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.11.62 stor2'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.11.63 stor3'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.11.64 stor4'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.11.65 stor5'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.11.66 stor6'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.11.67 stor7'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.11.68 stor8'    
EOF
ansible-playbook -i remote-hosts 2.yml


sudo tee 3.yml<<EOF
---
- hosts: all
  become: yes
  tasks:
  - name: Add server strings
    lineinfile:
      path: "/etc/sudoers.d/vagrant"
      line: 'vagrant ALL=(ALL:ALL) NOPASSWD:ALL'
      create: yes
      mode: '0440'
EOF
ansible-playbook -i remote-hosts 3.yml





sudo tee 4.yml<<EOF
---
- hosts: all
  become: yes
  tasks:
  - name: Add key
    shell: 'curl --silent https://download.ceph.com/keys/release.asc | sudo apt-key add -'
    args:
      warn: no   
  - name: Download
    get_url: url=https://github.com/ceph/ceph/raw/octopus/src/cephadm/cephadm dest=/home/vagrant mode=755

  - name: start1
    shell: /home/vagrant/cephadm add-repo --release octopus

  - name: Install packages
    apt:
      name:
      - docker.io
      state: latest
      cache_valid_time: 3600
- hosts: stor1
  become: yes
  tasks:
  - name: start2
    shell: /home/vagrant/cephadm install
  - name: Creates directory
    file:
      path: /etc/ceph
      state: directory
      owner: root
      group: root
      mode: 0775
EOF
ansible-playbook -i remote-hosts 4.yml

