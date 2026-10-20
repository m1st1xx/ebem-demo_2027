#!/bin/bash
hostnamectl set-hostname hq-srv.au-team.irpo
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
systemctl restart networking
apt install vlan sudo -y
echo "8021q" >> /etc/modules
modprobe 8021q
cat << 'EOF' > /etc/network/interfaces
auto ens33.100
iface ens33.100 inet static
address 192.168.100.2
netmask 255.255.255.224
gateway 192.168.100.1
vlan-raw-device ens33
EOF
systemctl restart networking
useradd -m -u 2027 -s /bin/bash sshuser
echo "sshuser:12345678" | chpasswd
echo "sshuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sshuser
chmod 440 /etc/sudoers.d/sshuser
visudo -c

echo "PermitRootLogin no
PasswordAuthentication yes
Port 2027" >> /etc/ssh/sshd_config
echo "AllowUsers sshuser
MaxAuthTries 2
Banner /etc/ssh/banner" >> /etc/ssh/sshd_config
touch /etc/ssh/banner
cat << "EOF" > /etc/ssh/banner
########################
#AUTHORIZED ACCESS ONLY#
########################
EOF
systemctl restart ssh
systemctl restart sshd
