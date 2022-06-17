#!/bin/bash
#запускаем на VM11



sudo tee 5.yml<<EOF
---
- hosts: all
  become: yes
  tasks:
  - name: Install packages
    apt:
      name:
      - python3
      - docker.io
#      - docker-ce  # более новая версия
# docker-ce docker-ce-cli containerd.io docker-compose-plugin
# sudo apt install apt-transport-https ca-certificates curl gnupg software-properties-common
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      - lvm2
      - curl
      - gpg
      state: latest
      cache_valid_time: 3600

  - name: Add an Apt signing key, uses whichever key is at the URL
#    ansible.builtin.apt_key:
    apt_key:
      url: https://download.ceph.com/keys/release.asc
      state: present

  - name: Download
    get_url: url=https://github.com/ceph/ceph/raw/octopus/src/cephadm/cephadm dest=/usr/sbin/ mode=755

  - name: start1
    shell: 'cephadm add-repo --release octopus'

  - name: start2
    shell: 'cephadm install ceph-common'
EOF
ansible-playbook -i remote-hosts 5.yml




cephadm install
mkdir -p /etc/ceph
cephadm bootstrap \
  --mon-ip 192.168.22.111 \
  --ssh-user root \
  --initial-dashboard-user admin \
  --initial-dashboard-password 123qweQWE



for node_id in $(cat remote-hosts);
do ssh-copy-id -f -i /etc/ceph/ceph.pub $node_id; done


for node_id in $(cat remote-hosts);
do ssh root@$node_id 'uname -n && date'; done



sudo tee -a /etc/ceph/ceph.conf<<EOF
monitor_interface: enp1s0
public_network: 192.168.22.0/24
cluster_network: 192.168.22.0/24
EOF


### cephadm rm-cluster --fsid e569bb72-edd3-11ec-8d7f-7d70f905d892 --force ### Удаление кластера
