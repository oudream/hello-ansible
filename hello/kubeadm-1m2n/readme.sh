#!/usr/bin/env bash
#has notice

ssh ubuntu@10.128.0.12
ssh ubuntu@10.128.0.13
ssh ubuntu@10.128.0.14


open https://www.digitalocean.com/community/tutorials/how-to-create-a-kubernetes-cluster-using-kubeadm-on-ubuntu-18-04
open https://en.llycloud.com/archives/1438


ansible -i hosts all -m command -a 'echo $HOME'

ansible '10.128.0.12' -m command -a 'echo $HOME'
ansible '10.128.0.12' -m command -a 'ls -l $HOME'
ansible '10.128.0.12' -m command -a 'chdir $HOME && echo $PWD'
ansible '10.128.0.12' -m command -a 'chdir $HOME && cat cluster_initialized.txt'


### after install kubernetes and flannel
kubectl create deployment nginx --image=nginx
# 创建名为nginx将公开公开应用程序的服务。它将通过NodePort实现，该方案将通过在群集的每个节点上打开的任意端口访问pod
kubectl expose deploy nginx --port 80 --target-port 80 --type NodePort
kubectl get services
# 如果要删除Nginx应用程序，请先nginx从主节点删除该服务：
kubectl delete service nginx
kubectl delete deployment nginx
kubectl get deployments


### step1
# 创建~/kube-cluster在本地Client的主目录中指定的目录并将其cd放入其中：
# 该目录将成为本教程其余部分的工作区，并包含所有Ansible playbooks。
mkdir ~/kube-cluster
cd ~/kube-cluster

# notice, notice, notice：ansible_host=自己的真实 IP
cat >> ~/kube-cluster/hosts <<EOF
[masters]
master ansible_host=10.128.0.12 ansible_user=root

[workers]
worker1 ansible_host=10.128.0.13 ansible_user=root
worker2 ansible_host=10.128.0.14 ansible_user=root

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF



### step2
# 创建非root用户ubuntu。
# 配置sudoers文件以允许ubuntu用户在sudo没有密码提示的情况下运行命令。
# 将本地计算机中的公钥（通常~/.ssh/id_rsa.pub）添加到远程ubuntu用户的授权密钥列表中。这将允许以ubuntu用户身份SSH到每个服务器。
cat > ~/kube-cluster/initial.yml <<EOF
- hosts: all
  become: yes
  tasks:
    - name: create the 'ubuntu' user
      user: name=ubuntu append=yes state=present createhome=yes shell=/bin/bash

    - name: allow 'ubuntu' to have passwordless sudo
      lineinfile:
        dest: /etc/sudoers
        line: 'ubuntu ALL=(ALL) NOPASSWD: ALL'
        validate: 'visudo -cf %s'

    - name: set up authorized keys for the ubuntu user
      authorized_key: user=ubuntu key="{{item}}"
      with_file:
        - ~/.ssh/id_rsa.pub
EOF

# 通过本地运行执行playbook：
ansible-playbook -i hosts ~/kube-cluster/initial.yml



### step3
# 安装Docker，容器运行时。
# 安装apt-transport-https，允许将外部HTTPS源添加到APT源列表。
# 添加Kubernetes APT存储库的apt-key进行密钥验证。
# 将Kubernetes APT存储库添加到远程服务器的APT源列表中。
# 安装kubelet和kubeadm。
cat >> ~/kube-cluster/kube-dependencies.yml <<EOF
- hosts: all
  become: yes
  tasks:
   - name: install Docker
     apt:
       name: docker.io
       state: present
       update_cache: true

   - name: install APT Transport HTTPS
     apt:
       name: apt-transport-https
       state: present

   - name: add Kubernetes apt-key
     apt_key:
       url: https://packages.cloud.google.com/apt/doc/apt-key.gpg
       state: present

   - name: add Kubernetes' APT repository
     apt_repository:
      repo: deb http://apt.kubernetes.io/ kubernetes-xenial main
      state: present
      filename: 'kubernetes'

   - name: install kubelet
     apt:
       name: kubelet=1.14.0-00
       state: present
       update_cache: true

   - name: install kubeadm
     apt:
       name: kubeadm=1.14.0-00
       state: present

- hosts: master
  become: yes
  tasks:
   - name: install kubectl
     apt:
       name: kubectl=1.14.0-00
       state: present
       force: yes
EOF

# 通过本地运行执行playbook：
ansible-playbook -i hosts ~/kube-cluster/kube-dependencies.yml



### step4
# 第一个任务通过运行初始化集群kubeadm init。传递参数–pod-network-cidr=10.244.0.0/16指定将从中分配pod IP的私有子网。
#       Flannel默认使用上述子网; 我们告诉kubeadm使用相同的子网。
# 第二个任务创建一个.kube目录/home/ubuntu。此目录将保存配置信息，例如连接到群集所需的管理密钥文件以及群集的API地址。
# 第三个任务将/etc/kubernetes/admin.conf生成的文件复制kubeadm init到非root用户的主目录。
#       这将允许用于kubectl访问新创建的群集。
# 最后一个任务运行kubectl apply安装Flannel。kubectl apply -f descriptor.[yml|json]是告诉kubectl
#       创建descriptor.[yml|json]文件中描述的对象的语法。该kube-flannel.yml文件包含Flannel在群集中设置所需对象的说明。
cat > ~/kube-cluster/master.yml <<EOF
- hosts: master
  become: yes
  tasks:
    - name: initialize the cluster
      shell: kubeadm init --pod-network-cidr=10.244.0.0/16 >> cluster_initialized.txt
      args:
        chdir: $HOME
        creates: cluster_initialized.txt

    - name: create .kube directory
      become: yes
      become_user: ubuntu
      file:
        path: /home/ubuntu/.kube
        state: directory
        mode: 0755

    - name: copy admin.conf to user's kube config
      copy:
        src: /etc/kubernetes/admin.conf
        dest: /home/ubuntu/.kube/config
        remote_src: yes
        owner: ubuntu

    - name: install Pod network
      become: yes
      become_user: ubuntu
      shell: kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml >> pod_network_setup.txt
      args:
        chdir: /home/ubuntu
        creates: pod_network_setup.txt
EOF
# 通过运行本地执行Playbook：
ansible-playbook -i hosts ~/kube-cluster/master.yml


### step5
cat >> ~/kube-cluster/workers.yml <<EOF
- hosts: master
  become: yes
  gather_facts: false
  tasks:
    - name: get join command
      shell: kubeadm token create --print-join-command
      register: join_command_raw

    - name: set join command
      set_fact:
        join_command: "{{ join_command_raw.stdout_lines[0] }}"


- hosts: workers
  become: yes
  tasks:
    - name: join cluster
      shell: "{{ hostvars['master'].join_command }} >> node_joined.txt"
      args:
        chdir: $HOME
        creates: node_joined.txt
EOF
# 通过运行本地执行Playbook：
ansible-playbook -i hosts ~/kube-cluster/workers.yml



