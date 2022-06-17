#!/bin/bash
#запускаем на VM11



sudo apt update && sudo apt install ansible sshpass -y

ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""

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

sudo tee -a /etc/hosts<<EOF
192.168.22.111 vm11
192.168.22.112 vm12
192.168.22.113 vm13
192.168.22.114 vm14

192.168.22.121 vm21
192.168.22.122 vm22
192.168.22.123 vm23
192.168.22.124 vm24

192.168.22.131 vm31
192.168.22.132 vm32
192.168.22.133 vm33
192.168.22.134 vm34

192.168.22.141 vm41
192.168.22.142 vm42
192.168.22.143 vm43
192.168.22.144 vm44
EOF

ssh-keyscan -f ./remote-hosts >> ~/.ssh/known_hosts

for node_id in $(cat remote-hosts);
do sshpass -p '123qwe' ssh-copy-id $(whoami)@$node_id; done


####*************


ansible all -m ping -i remote-hosts



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
      line: server vm11
EOF
ansible-playbook -i remote-hosts 2.yml



sudo tee 3.yml<<EOF
---
- hosts: all
  become: yes
  tasks:
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.111 vm11'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.112 vm12'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.113 vm13'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.114 vm14'

  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.121 vm21'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.122 vm22'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.123 vm23'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.124 vm24'    

  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.131 vm31'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.132 vm32'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.133 vm33'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.134 vm34'    

  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.141 vm41'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.142 vm42'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.143 vm43'    
  - name: Add server strings
    lineinfile:
      path: "/etc/hosts"
      line: '192.168.22.144 vm44'    

EOF
ansible-playbook -i remote-hosts 3.yml



sudo tee 4.yml<<EOF
---
- hosts: all
  become: yes
  tasks:
  - name: set timezone to Europe/Moscow
    timezone:
      name: Europe/Moscow

  - name: Set default locale to ru_RU.UTF-8
    debconf:
      name: locales
      question: locales/default_environment_locale
      value: ru_RU.UTF-8
      vtype: select      
EOF
ansible-playbook -i remote-hosts 4.yml



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

