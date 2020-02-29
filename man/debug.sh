#!/usr/bin/env bash





cat > debug.yml <<EOF
- hosts: master
  become: yes

  environment:
    PATH: /usr/bin

  tasks:
    - name: debug specified user's home dir through lookup on env
      become: yes
      become_user: user1
      # become_flags: -H
      command:
        cmd: env
EOF
ansible-playbook -i hosts debug.yml -vv


cat >> debug.yml <<EOF
- hosts: masters
  become: yes
  gather_facts: false
  tasks:
    - name: get join command
      shell: ps
      register: join_command_raw

    - name: set join command
      set_fact:
        join_command: "{{ join_command_raw.stdout_lines[0] }}"


- hosts: workers
  become: yes
  tasks:
    - name: join cluster
      shell: "{{ hostvars['master1'].join_command }} >> node_joined.txt"
      args:
        chdir: \$HOME
        creates: node_joined.txt
EOF
# 通过运行本地执行Playbook：
ansible-playbook -i hosts ~/kube-cluster/workers.yml