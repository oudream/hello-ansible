#!/usr/bin/env bash


open https://docs.ansible.com/ansible/latest/user_guide/become.html


ansible-doc -t become -l
ansible-doc -t become su
ansible-doc -t become sudo
ansible-doc -t become doas


# Plugin List
# You can use ansible-doc -t become -l to see the list of available plugins. Use ansible-doc -t become <plugin name> to see specific documentation and examples.
doas       # – Do As user
dzdo       # – Centrify’s Direct Authorize
enable     # – Switch to elevated permissions on a network device
ksu        # – Kerberos substitute user
machinectl # – Systemd’s machinectl privilege escalation
pbrun      # – PowerBroker run
pfexec     # – profile based execution
pmrun      # – Privilege Manager run
runas      # – Run As user
sesu       # – CA Privileged Access Manager
su         # – Substitute User
sudo       # – Substitute User DO


# Ansible 1.9之前允许用户使用sudo和有限的su命令来以不同用户的身份/权限远程登陆执行task,及创建资源.
# 在1.9版本中’become’取代了之前的sudo/su,
# Ansible执行playbooks遇到需要提权的情况，除了要在yml文件里面设置become:True之外，
# 还需要在hosts配置文件配置密码或者在运行playbook命令的时候加上输入密码参数

# 1、在hosts文件添加，ansible_become_pass=password
# 2、运行命令的时候加上 –ask-become-pass

become # 等同于添加 ‘sudo:’ 或 ‘su:’ ,默认为sudo,被控主机为centos的话需要设置become_method为su
become_user # 等同于添加 ‘sudo_user:’ 或 ‘su_user:’
become_method # 可以设置的值为为：[sudo/su/pbrun/pfexec/doas]
# ansible_become、ansible_become_user、ansible_become_method、ansible_become_pass,意思同上

