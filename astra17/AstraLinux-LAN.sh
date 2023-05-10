sudo mcedit /etc/network/interfaces


auto eth0
iface eth0 inet static
    address 10.2.15.1
    netmask 255.255.255.0

auto eth1
iface eth1 inet static
    address 10.2.15.2
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.2.15.3
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 192.168.1.11
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 192.168.1.1


sudo service networking restart


sudo mcedit /etc/apt/sources.list
 sudo apt remove network-manager-gnome

sudo apt install bridge-utils
sudo apt install ifenslave iperf
