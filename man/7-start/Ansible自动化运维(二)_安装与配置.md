# Ansible安装
**方式1：** rpm包安装: EPEL源
```bash
yum install ansible
```
**方式2：** 编译安装:
```bash
yum -y install python-jinja2 PyYAML python-paramiko python-babel python-crypto
tar xf ansible-1.5.4.tar.gz
cd ansible-1.5.4
python setup.py build
python setup.py install
mkdir /etc/ansible
cp -r examples/* /etc/ansible
```

**方式3：** Git方式:
```bash
git clone git://github.com/ansible/ansible.git --recursive
cd ./ansible
source ./hacking/env-setup
```

**方式4：** pip安装： pip是安装Python包的管理器，类似yum
```bash
yum install python-pip python-devel
yum install gcc glibc-devel zibl-devel rpm-bulid openssl-devel
pip install --upgrade pip
pip install ansible --upgrade
```

+ 确认安装：
```bash
ansible --version
```

## 相关文件
1. 配置文件
```bash
/etc/ansible/ansible.cfg   #主配置文件，配置ansible工作特性
/etc/ansible/hosts    #主机清单
/etc/ansible/roles/   #存放角色的目录
```

2. 程序
```bash
/usr/bin/ansible   #主程序，临时命令执行工具
/usr/bin/ansible-doc   #查看配置文档，模块功能查看工具
/usr/bin/ansible-galaxy    #下载/上传优秀代码或Roles模块的官网平台
/usr/bin/ansible-playbook  #定制自动化任务，编排剧本工具/usr/bin/ansible-pull 远程执行命令的工具
/usr/bin/ansible-vault  #文件加密工具
/usr/bin/ansible-console  #基于Console界面与用户交互的执行工具
```

### 主机清单inventory
>ansible的主要功用在于批量主机操作，为了便捷地使用其中的部分主机，可以在inventory file中将其分组命名

1. 默认的inventory file为`/etc/ansible/hosts`
2. inventory file可以有多个，且也可以通过Dynamic Inventory来动态生成
3. /etc/ansible/hosts文件格式
```bash
#inventory文件遵循INI文件风格，中括号中的字符为组名。
#可以将同一个主机同时归并到多个不同的组中；
#此外，当如若目标主机使用了非默认的SSH端口，
#还可以在主机名称之后使用冒号加端口号来标明

ntp.magedu.com
[webservers]
www1.magedu.com:2222
www2.magedu.com
[dbservers]
db1.magedu.com
db2.magedu.com
db3.magedu.com
```

如果主机名称遵循相似的命名模式，还可以使用列表的方式标识各主机
```bash
示例：
[websrvs]
www[1:100].example.com
[dbsrvs]
db-[a:f].example.com
```


## ansible 配置文件
Ansible 配置文件`/etc/ansible/ansible.cfg` （一般保持默认）
```bash
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
```


模块将在下节讲，这里先了解下ansible-doc这个命令，可以用来显示模块
+ ansible-doc: 显示模块帮助
`ansible-doc [options] [module...]`
```bash
-a 显示所有模块的文档
-l, --list 列出可用模块
-s, --snippet显示指定模块的playbook片段
```
+ 示例：
```bash
ansible-doc -l   #列出所有模块
ansible-doc ping  #查看指定模块帮助用法
ansible-doc -s ping  #查看指定模块帮助用法
```

