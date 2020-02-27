#!/usr/bin/env bash

#
ansible all -m ping
# specify inventory host path or comma separated host list.
ansible -i hosts all -m ping
ansible '10.128.0.9' -m ping
#
ansible all -m command -a "ls -l ~/tmp/"
# 显示时间
ansible all -m command -a 'uptime'
# copy模块，可以将本地文件一键复制到远程服务器；-a后跟上参数，参数中指定本地文件和远端路径；
ansible all -m copy -a "src=/opt/tmp/a.txt dest=~/tmp/"
#
ansible all -m command -a "cat ~/tmp/a.txt"
# 列出要执行的主机,不执行任何操作
ansible all --list-hosts
# 批量检测主机
ansible all -m ping
# 批量执行命令
ansible all -m command -a 'id' -k
# 批量部署证书文件
ansible all -m authorized_key -a "user=root exclusive=true manage_dir=true key='$(</root/.ssh/authorized_keys)'" -k -v


### guide, start
open https://github.com/ansible/ansible
open https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html
open https://github.com/ansible/tower-example


# - Define and run a single task 'playbook' against a set of hosts
ansible [-h] [--version] [-v] [-b] [--become-method BECOME_METHOD]
      [--become-user  BECOME_USER] [-K] [-i INVENTORY] [--list-hosts] [-l SUBSET] [-P POLL_INTERVAL] [-B SECONDS] [-o]
      [-t TREE] [-k] [--private-key PRIVATE_KEY_FILE] [-u REMOTE_USER] [-c CONNECTION] [-T TIMEOUT] [--ssh-common-args
      SSH_COMMON_ARGS]   [--sftp-extra-args   SFTP_EXTRA_ARGS]   [--scp-extra-args  SCP_EXTRA_ARGS]  [--ssh-extra-args
      SSH_EXTRA_ARGS]  [-C]  [--syntax-check]  [-D]  [-e  EXTRA_VARS]  [--vault-id  VAULT_IDS]   [--ask-vault-pass   |
      --vault-password-file  VAULT_PASSWORD_FILES]  [-f  FORKS]  [-M  MODULE_PATH]  [--playbook-dir  BASEDIR] [-a MOD‐
      ULE_ARGS] [-m MODULE_NAME] pattern

#DESCRIPTION
#   is an extra-simple tool/framework/API for doing 'remote things'.  this command allows you to define and  run  a  single
#   task 'playbook' against a set of hosts

# COMMON OPTIONS
    # host pattern

   --ask-vault-pass
    # ask for vault password

   --become-method 'BECOME_METHOD'
    # privilege escalation method to use (default=%(default)s), use ansible-doc -t become -l to list valid choices.

   --become-user 'BECOME_USER'
    # run operations as this user (default=root)

   --list-hosts
    # outputs a list of matching hosts; does not execute anything else

   --playbook-dir 'BASEDIR'
    # Since  this tool does not use playbooks, use this as a substitute playbook directory.This sets the relative path for
    # many features including roles/ group_vars/ etc.

   --private-key 'PRIVATE_KEY_FILE', --key-file 'PRIVATE_KEY_FILE'
    # use this file to authenticate the connection

   --scp-extra-args 'SCP_EXTRA_ARGS'
    # specify extra arguments to pass to scp only (e.g. -l)

   --sftp-extra-args 'SFTP_EXTRA_ARGS'
    # specify extra arguments to pass to sftp only (e.g. -f, -l)

   --ssh-common-args 'SSH_COMMON_ARGS'
    # specify common arguments to pass to sftp/scp/ssh (e.g. ProxyCommand)

   --ssh-extra-args 'SSH_EXTRA_ARGS'
    # specify extra arguments to pass to ssh only (e.g. -R)

   --syntax-check
    # perform a syntax check on the playbook, but do not execute it

   --vault-id
    # the vault identity to use

   --vault-password-file
    # vault password file

   --version
    # show program's version number, config file location, configured module  search  path,  module  location,  executable
    # location and exit

   -B 'SECONDS', --background 'SECONDS'
    # run asynchronously, failing after X seconds (default=N/A)

   -C, --check
    # don't make any changes; instead, try to predict some of the changes that may occur

   -D, --diff
    # when changing (small) files and templates, show the differences in those files; works great with --check

   -K, --ask-become-pass
    # ask for privilege escalation password

   -M, --module-path
    # prepend  colon-separated  path(s)  to  module  library  (default=~/.ansible/plugins/modules:/usr/share/ansible/plug‐
    # ins/modules)

   -P 'POLL_INTERVAL', --poll 'POLL_INTERVAL'
    # set the poll interval if using -B (default=15)

   -T 'TIMEOUT', --timeout 'TIMEOUT'
    # override the connection timeout in seconds (default=10)

   -a 'MODULE_ARGS', --args 'MODULE_ARGS'
    # module arguments

   -b, --become
    # run operations with become (does not imply password prompting)

   -c 'CONNECTION', --connection 'CONNECTION'
    # connection type to use (default=smart)

   -e, --extra-vars
    # set additional variables as key=value or YAML/JSON, if filename prepend with @

   -f 'FORKS', --forks 'FORKS'
    # specify number of parallel processes to use (default=5)

   -h, --help
    # show this help message and exit

   -i, --inventory, --inventory-file
    # specify inventory host path or comma separated host list. --inventory-file is deprecated

   -k, --ask-pass
    # ask for connection password

   -l 'SUBSET', --limit 'SUBSET'
    # further limit selected hosts to an additional pattern

   -m 'MODULE_NAME', --module-name 'MODULE_NAME'
    # module name to execute (default=command)

   -o, --one-line
    # condense output

   -t 'TREE', --tree 'TREE'
    # log output to this directory

   -u 'REMOTE_USER', --user 'REMOTE_USER'
    # connect as this user (default=None)

   -v, --verbose
    # verbose mode (-vvv for more, -vvvv to enable connection debugging)

#ENVIRONMENT
#   The following environment variables may be specified.
#
#   ANSIBLE_CONFIG -- Specify override location for the ansible config file
#
#   Many more are available for most options in ansible.cfg
#
#   For a full list check https://docs.ansible.com/. or use the ansible-config command.
#
#FILES
#   /etc/ansible/ansible.cfg -- Config file, used if present
#
#   ~/.ansible.cfg -- User config file, overrides the default config if present
#
#   ./ansible.cfg -- Local config file (in current working directory) assumed to be 'project specific'  and  overrides  the
#   rest if present.
#
#   As mentioned above, the ANSIBLE_CONFIG environment variable will override all others.
#



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

