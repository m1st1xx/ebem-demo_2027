#!/bin/bash
hostnamectl set-hostname br-srv.au-team.irpo
cat << 'EOF' > /etc/network/interfaces
auto ens33
iface ens33 inet static
address 192.168.50.2
netmask 255.255.255.0
gateway 192.168.50.1
EOF
echo "search au-team.irpo" >> /etc/resolv.conf
echo "nameserver 192.168.100.2" >> /etc/resolv.conf
systemctl restart networking

apt install -y openssh-server sudo
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
timedatectl set-timezone Europe/Moscow

