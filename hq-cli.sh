#!/bin/bash
hostnamectl set-hostname hq-cli.au-team.irpo
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
systemctl restart networking
apt install vlan sudo -y
echo "8021q" >> /etc/modules
modprobe 8021q
cat << 'EOF' > /etc/network/interfaces
auto ens33.200
iface ens33.200 inet dhcp
EOF
timedatectl set-timezone Europe/Moscow
