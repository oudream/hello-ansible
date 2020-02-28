#!/bin/bash

sudo su
set -x

echo "Reading config...." >&2
source /vagrant/setup.rc

export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get install wget -y

# change root password
echo -e "vagrant\nvagrant" | passwd root
sudo sed -i "s|PermitRootLogin prohibit-password|PermitRootLogin yes|g" /etc/ssh/sshd_config
sudo sed -i "s|#PasswordAuthentication yes|PasswordAuthentication yes|g" /etc/ssh/sshd_config
service ssh restart

exit 0
