#!/usr/bin/env bash

### Ansible 配置文件`/etc/ansible/ansible.cfg` （一般保持默认）
cat >> ansible.cfg <<EOF
[defaults]
inventory = /etc/ansible/hosts # 主机列表配置文件
library = /usr/share/my_modules/ # 库文件存放目录
remote_tmp = $HOME/.ansible/tmp #临时py命令文件存放在远程主机目录
local_tmp = $HOME/.ansible/tmp # 本机的临时命令执行目录
forks = 5 # 默认并发数
sudo_user = root # 默认sudo 用户
ask_sudo_pass = True #每次执行ansible命令是否询问ssh密码
ask_pass = True
remote_port = 22
host_key_checking = False  # 检查对应服务器的host_key，建议取消注释
log_path=/var/log/ansible.log #日志文件
module_name = command #默认模块
module_set_locale = False   #
EOF

