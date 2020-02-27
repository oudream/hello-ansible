#!/usr/bin/env bash

open https://docs.ansible.com/ansible/latest/user_guide/playbooks_environment.html


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


cat > debug.yml <<EOF
- hosts: master
  tasks:
    - name: Echo my_env_var
      environment:
        MY_ENV_VARIABLE: whatever_value
      shell:
        cmd: "echo XX-\$MY_ENV_VARIABLE \$\$ ++"

    - name: Echo my_env_var again
      shell:
        cmd: "echo xx-\$MY_ENV_VARIABLE \$\$ ++"
EOF
ansible-playbook -i hosts debug.yml -vv
# XX-whatever_value 24750 ++
# xx- 24770 ++


cat > debug.yml <<EOF
- hosts: master
  tasks:
    - name: Echo my_env_var
      command:
        cmd: ps -a

    - name: Echo my_env_var again
      command:
        cmd: ps -a

    - name: Echo my_env_var again
      command:
        cmd: ps -a

    - name: Echo my_env_var again
      command:
        cmd: ps -a
EOF
ansible-playbook -i hosts debug.yml -vv
#  PID TTY          TIME CMD", "25748 pts/0    00:00:00 sh", "25749 pts/0    00:00:00 python3", "25751 pts/0    00:00:00 ps
#  PID TTY          TIME CMD", "25768 pts/0    00:00:00 sh", "25769 pts/0    00:00:00 python3", "25771 pts/0    00:00:00 ps
#  PID TTY          TIME CMD", "25788 pts/0    00:00:00 sh", "25789 pts/0    00:00:00 python3", "25791 pts/0    00:00:00 ps
#  PID TTY          TIME CMD", "25808 pts/0    00:00:00 sh", "25809 pts/0    00:00:00 python3", "25811 pts/0    00:00:00 ps

