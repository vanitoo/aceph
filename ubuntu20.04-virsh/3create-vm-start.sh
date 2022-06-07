#!/bin/bash

for node_id in $(cat remote-hosts);
do
 scp create-vm.sh root@$node_id:/root;
done

ssh root@host1 './create-vm.sh vm11 2 1 192.168.22.111 30';
ssh root@host1 './create-vm.sh vm12 2 1 192.168.22.112 30';
ssh root@host1 './create-vm.sh vm13 2 1 192.168.22.113 30';
ssh root@host1 './create-vm.sh vm14 2 1 192.168.22.114 30';

ssh root@host2 './create-vm.sh vm21 2 1 192.168.22.121 30';
ssh root@host2 './create-vm.sh vm22 2 1 192.168.22.122 30';
ssh root@host2 './create-vm.sh vm23 2 1 192.168.22.123 30';
ssh root@host2 './create-vm.sh vm24 2 1 192.168.22.124 30';

ssh root@host3 './create-vm.sh vm31 2 1 192.168.22.131 30';
ssh root@host3 './create-vm.sh vm32 2 1 192.168.22.132 30';
ssh root@host3 './create-vm.sh vm33 2 1 192.168.22.133 30';
ssh root@host3 './create-vm.sh vm34 2 1 192.168.22.134 30';

ssh root@host4 './create-vm.sh vm41 2 1 192.168.22.141 30';
ssh root@host4 './create-vm.sh vm42 2 1 192.168.22.142 30';
ssh root@host4 './create-vm.sh vm43 2 1 192.168.22.143 30';
ssh root@host4 './create-vm.sh vm44 2 1 192.168.22.144 30';

