#!/usr/bin/env bash



### install
open https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

# ubuntu
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

# Installing Ansible with pip
# Ansible can be installed with pip, the Python package manager. If pip isn’t already available on your system of Python, run the following commands to install it:
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user
# Then install Ansible [1]:
pip install --user ansible
# Or if you are looking for the development version:
pip install --user git+https://github.com/ansible/ansible.git@devel
# If you are installing on macOS Mavericks (10.9), you may encounter some noise from your compiler. A workaround is to do the following:
CFLAGS=-Qunused-arguments CPPFLAGS=-Qunused-arguments pip install --user ansible
# In order to use the paramiko connection plugin or modules that require paramiko, install the required module [2]:
pip install --user paramiko
# Ansible can also be installed inside a new or existing virtualenv:
python -m virtualenv ansible  # Create a virtualenv if one does not already exist
source ansible/bin/activate   # Activate the virtual environment
pip install ansible
# If you wish to install Ansible globally, run the following commands:
sudo python get-pip.py
sudo pip install ansible

# 从源码安装的步骤
git clone git://github.com/ansible/ansible.git --recursive
cd ./ansible
# 使用 Bash:
source ./hacking/env-setup
# 使用 Fish:
. ./hacking/env-setup.fish

