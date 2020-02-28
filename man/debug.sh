#!/usr/bin/env bash




become_flags
      become_flags: '-H'
      become_user: user1

cat > debug.yml <<EOF
- hosts: master
  become: yes

  environment:
    PATH: /usr/bin

  tasks:
    - name: debug specified user's home dir through lookup on env
      become: yes
      become_user: user1
      command:
        cmd: env
EOF
ansible-playbook -i hosts debug.yml -vv


