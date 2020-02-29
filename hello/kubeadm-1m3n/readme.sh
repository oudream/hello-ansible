#!/usr/bin/env bash
#has notice

open https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
open https://github.com/coreos/flannel
open https://www.digitalocean.com/community/tutorials/how-to-create-a-kubernetes-cluster-using-kubeadm-on-ubuntu-18-04
open https://en.llycloud.com/archives/1438


ansible -i hosts all -m ping
ansible -i hosts all -m command -a 'echo $HOME'


ansible -i hosts all -m shell -a 'tar zcvf /opt/log1.tar.gz /var/log/*.log'


### 安装前检查
# 确保每个节点上 MAC 地址和 product_uuid 的唯一性
ansible -i hosts all -m command -a 'ip link'
ansible -i hosts all -m command -a 'cat /sys/class/dmi/id/product_uuid'

控制平面节点
#    协议	方向	端口范围	    作用	                        使用者
#master
#    TCP	入站	6443*	    Kubernetes API 服务器 	    所有组件
#    TCP	入站	2379-2380	etcd server client API	    kube-apiserver, etcd
#    TCP	入站	10250	    Kubelet API	                kubelet 自身、控制平面组件
#    TCP	入站	10251	    kube-scheduler	            kube-scheduler 自身
#    TCP	入站	10252	    kube-controller-manager	    kube-controller-manager 自身
#node
#    TCP	入站	10250	    Kubelet API	                kubelet 自身、控制平面组件
#    TCP	入站	30000-32767	NodePort 服务**	            所有组件


# 确保 iptables 工具不使用 nftables 后端
# 在 Linux 中，nftables 当前可以作为内核 iptables 子系统的替代品。 iptables 工具可以充当兼容性层，
#   其行为类似于 iptables 但实际上是在配置 nftables。 nftables 后端与当前的 kubeadm 软件包不兼容：
#   它会导致重复防火墙规则并破坏 kube-proxy。
# Debian 10 (Buster)、Ubuntu 19.04、Fedora 29 和较新的发行版本中会出现这种问题
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
update-alternatives --set arptables /usr/sbin/arptables-legacy
update-alternatives --set ebtables /usr/sbin/ebtables-legacy



ansible master1 -m command -a 'echo $HOME'
ansible master1 -m command -a 'ls -l $HOME'
ansible master1 -m command -a 'chdir $HOME && echo $PWD'
ansible master1 -m command -a 'chdir $HOME && cat cluster_initialized.txt'



### referto
open https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl



### after install kubernetes and flannel
kubectl create deployment nginx --image=nginx
# 创建名为nginx将公开公开应用程序的服务。它将通过NodePort实现，该方案将通过在群集的每个节点上打开的任意端口访问pod
kubectl expose deploy nginx --port 80 --target-port 80 --type NodePort
kubectl get services
# 如果要删除Nginx应用程序，请先nginx从主节点删除该服务：
kubectl delete service nginx
kubectl delete deployment nginx
kubectl get deployments

unable to recognize "https://raw.githubusercontent.com/giantswarm/prometheus/master/manifests-all.yaml": no matches for kind "Deployment" in version "extensions/v1beta1"
unable to recognize "https://raw.githubusercontent.com/giantswarm/prometheus/master/manifests-all.yaml": no matches for kind "Deployment" in version "extensions/v1beta1"
unable to recognize "https://raw.githubusercontent.com/giantswarm/prometheus/master/manifests-all.yaml": no matches for kind "Deployment" in version "extensions/v1beta1"
unable to recognize "https://raw.githubusercontent.com/giantswarm/prometheus/master/manifests-all.yaml": no matches for kind "Deployment" in version "extensions/v1beta1"
unable to recognize "https://raw.githubusercontent.com/giantswarm/prometheus/master/manifests-all.yaml": no matches for kind "DaemonSet" in version "extensions/v1beta1"
unable to recognize "https://raw.githubusercontent.com/giantswarm/prometheus/master/manifests-all.yaml": no matches for kind "DaemonSet" in version "extensions/v1beta1"


### prepare
cat >> /etc/hosts <<EOF
10.128.0.20 master1
10.128.0.30 master2
10.128.0.31 master3
10.128.0.19 node1
10.128.0.21 node2
10.128.0.22 node3
10.128.0.23 node4
EOF

### step1
# 创建~/kube-cluster在本地Client的主目录中指定的目录并将其cd放入其中：
# 该目录将成为本教程其余部分的工作区，并包含所有Ansible playbooks。
rm -rf ~/kube-cluster
mkdir ~/kube-cluster
cd ~/kube-cluster

# notice, notice, notice：ansible_host=自己的真实 IP
cat > ~/kube-cluster/hosts <<EOF
[masters]
master1 ansible_host=master1 ansible_user=root

[workers]
worker1 ansible_host=node1 ansible_user=root
worker3 ansible_host=node3 ansible_user=root

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

ansible -i hosts all -m ping


### step2
# 创建非root用户user1。
# 配置sudoers文件以允许user1用户在sudo没有密码提示的情况下运行命令。
# 将本地计算机中的公钥（通常~/.ssh/id_rsa.pub）添加到远程user1用户的授权密钥列表中。这将允许以user1用户身份SSH到每个服务器。
cat > ~/kube-cluster/initial.yml <<EOF
- hosts: all
  become: yes
  tasks:
    - name: create the 'user1' user
      user: name=user1 append=yes state=present createhome=yes shell=/bin/bash

    - name: allow 'user1' to have passwordless sudo
      lineinfile:
        dest: /etc/sudoers
        line: 'user1 ALL=(ALL) NOPASSWD: ALL'
        validate: 'visudo -cf %s'

    - name: set up authorized keys for the user1 user
      authorized_key: user=user1 key="{{item}}"
      with_file:
        - ~/.ssh/id_rsa.pub
EOF

# 通过本地运行执行playbook：
ansible-playbook -i hosts ~/kube-cluster/initial.yml
# 验证 user1
ansible -i hosts all -m shell -a "getent passwd user1  | awk -F: \"{ print \$6 }\""


### step3
# 安装Docker，容器运行时。
# 安装apt-transport-https，允许将外部HTTPS源添加到APT源列表。
# 添加Kubernetes APT存储库的apt-key进行密钥验证。
# 将Kubernetes APT存储库添加到远程服务器的APT源列表中。
# 安装kubelet和kubeadm。
cat > ~/kube-cluster/kube-dependencies.yml <<EOF
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
       name: kubelet=1.17.2-00
       state: present
       update_cache: true

   - name: install kubeadm
     apt:
       name: kubeadm=1.17.2-00
       state: present

- hosts: master1
  become: yes
  tasks:
   - name: install kubectl
     apt:
       name: kubectl=1.17.2-00
       state: present
       force: yes
EOF

# 通过本地运行执行playbook：
ansible-playbook -i hosts ~/kube-cluster/kube-dependencies.yml



### step4
# 第一个任务通过运行初始化集群kubeadm init。传递参数–pod-network-cidr=10.244.0.0/16指定将从中分配pod IP的私有子网。
#       Flannel默认使用上述子网; 我们告诉kubeadm使用相同的子网。
# 第二个任务创建一个.kube目录/home/user1。此目录将保存配置信息，例如连接到群集所需的管理密钥文件以及群集的API地址。
# 第三个任务将/etc/kubernetes/admin.conf生成的文件复制kubeadm init到非root用户的主目录。
#       这将允许用于kubectl访问新创建的群集。
# 最后一个任务运行kubectl apply安装Flannel。kubectl apply -f descriptor.[yml|json]是告诉kubectl
#       创建descriptor.[yml|json]文件中描述的对象的语法。该kube-flannel.yml文件包含Flannel在群集中设置所需对象的说明。
cat > ~/kube-cluster/master1.yml <<EOF
- hosts: master1
  become: yes
  tasks:
    - name: initialize the cluster
      shell: kubeadm init --pod-network-cidr=10.244.0.0/16 >> cluster_initialized.txt
      args:
        chdir: \$HOME
        creates: cluster_initialized.txt

    - name: create .kube directory
      become: yes
      become_user: user1
      file:
        path: \$HOME/.kube
        state: directory
        mode: 0755

    - name: copy admin.conf to user's kube config
      copy:
        src: /etc/kubernetes/admin.conf
        dest: /home/user1/.kube/config
        remote_src: yes
        owner: user1

    - name: install Pod network
      become: yes
      become_user: user1
      shell: kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml >> pod_network_setup.txt
      args:
        chdir: \$HOME
        creates: pod_network_setup.txt
EOF
# 通过运行本地执行Playbook：
ansible-playbook -i hosts ~/kube-cluster/master1.yml


### step5
cat >> ~/kube-cluster/workers.yml <<EOF
- hosts: master1
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
      shell: "{{ hostvars['master1'].join_command }} >> node_joined.txt"
      args:
        chdir: \$HOME
        creates: node_joined.txt
EOF
# 通过运行本地执行Playbook：
ansible-playbook -i hosts ~/kube-cluster/workers.yml

