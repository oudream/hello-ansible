#!/usr/bin/env bash


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

