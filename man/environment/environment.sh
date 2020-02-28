#!/usr/bin/env bash

open https://docs.ansible.com/ansible/latest/user_guide/playbooks_environment.html


### How to get an arbitrary remote user's home directory in Ansible?
open https://stackoverflow.com/questions/33343215/how-to-get-an-arbitrary-remote-users-home-directory-in-ansible
open http://docs.ansible.com/ansible/faq.html#how-do-i-access-shell-environment-variables
# Ansible (from 1.4 onwards) already reveals environment variables for the user under the ansible_env variable.
# notice : change it to your path.


cd $PWD
cat > debug.yml <<EOF
- hosts: master
  tasks:
    - name: debug 1 ansible.env
      debug: var=ansible_env.HOME
      become: true
      become_user: "{{ user }}"

    - name: debug 2 ansible.env
      debug: var=lookup('env','HOME')
      debug: var=lookup('env','USER')
      become_user: "{{ user }}"

    - name: debug 3 ansible.env
      debug:
        msg: "{{ lookup('env','USER','HOME','SHELL') }}"
      become: true
      become_user: "{{ user }}"

    - name: debug 4 ansible.env
      debug:
        msg: "{{ ansible_env }}"
      become: true
      become_user: "{{ user }}"
EOF
ansible-playbook -i hosts debug.yml -e "user=user1"

### --- temp
cat > debug.yml <<EOF
- hosts: master
  tasks:
    - name: debug specified user's home dir through lookup on env
      shell: >
             getent passwd {{ user }}  | awk -F: '{ print $6 }'
      become: false
      become_user: user1
EOF
ansible-playbook -i hosts debug.yml -e "user=user1"


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

