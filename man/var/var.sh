#!/usr/bin/env bash

open https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
open https://blog.csdn.net/felix_yujing/article/details/76792933

# ansible使用变量的优先级顺序从高到低为：
# host_vars下定义变量
# inventory中单个主机定义变量
# group_vars下定义变量
# inventory中组定义变量

ansible-playbook test.yml -e "keyvalue=inputed"


cat > debug.yml <<EOF
- hosts: all
  tasks:
    - name: get user home directory
      shell: >
             getent passwd {{ user }}  | awk -F: '{ print $6 }'
      changed_when: false
      register: user_home

    - name: debug output
      debug:
        var: user_home.stdout
EOF
ansible-playbook -i hosts debug.yml -e "user=user1"

