#!/bin/bash
hostnamectl set-hostname br-rtr.au-team.irpo
echo "ip_gre" >> /etc/modules
modprobe ip_gre
cat << 'EOF' > /etc/network/interfaces
auto ens33
iface ens33 inet static
address 172.16.2.2
netmask 255.255.255.224
gateway 172.16.2.1
auto ens37
iface ens37 inet static
address 192.168.40.1
netmask 255.255.255.252
EOF
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
systemctl restart networking

export DEBIAN_FRONTEND=noninteractive
echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections
apt install sudo iptables iptables-persistent -y
iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE
netfilter-persistent save
touch /etc/sysctl.d/sysctl.conf
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/sysctl.conf
sysctl -p
systemctl restart networking

useradd -m -u 2027 -s /bin/bash net_admin
echo "net_admin:12345678" | chpasswd
echo "net_admin ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/net_admin
chmod 440 /etc/sudoers.d/net_admin
visudo -c
