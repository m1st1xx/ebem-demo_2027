#!/bin/bash
hostnamectl set-hostname isp.au-team.irpo
cat << 'EOF' > /etc/network/interfaces
auto ens33
iface ens33 inet dhcp

auto ens37
iface ens37 inet static
address 172.16.1.1
netmask 255.255.255.224

auto ens38
iface ens38 inet static
address 172.16.2.1
netmask 255.255.255.224
EOF

export DEBIAN_FRONTEND=noninteractive
echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections
apt install sudo iptables iptables-persistent -y
iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE
netfilter-persistent save
touch /etc/sysctl.d/sysctl.conf
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/sysctl.conf
sysctl -p
timedatectl set-timezone Europe/Moscow
