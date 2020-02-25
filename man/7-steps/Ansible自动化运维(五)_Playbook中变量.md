# Playbook中变量使用
>变量名：仅能由字母、数字和下划线组成，且只能以字母开头

## 变量来源：

1. `ansible setup facts` 远程主机的所有变量都可直接调用
+ 查看远程主机变量
```bash
ansible 192.168.99.102 -m setup -a 'filter="ansible_*version*"'
```

2. 在/etc/ansible/hosts中定义
普通变量：主机组中主机单独定义，优先级高于公共变量
公共（组）变量：针对主机组中所有主机定义统一变量
```ini
[websrvs]
192.168.99.101
192.168.99.102
[webservs:vars]
suf=txt
```

3. 通过命令行指定变量，优先级最高
```sh
ansible-playbook –e varname=value
```

4. 在playbook中定义
```yml
- hosts: 192.168.99.102
  vars:
    - var1: value1
    - var2: value2
```

5. 在独立的变量YAML文件中定义
```yml
[centos]$ cat varrr.yml
var1: httpd
var2: nginx

#在其它yml中引用
- hosts: 192.168.99.101
  vars_files: varrr.yml
```

6. 在role中定义


## 变量命名
>变量名仅能由字母、数字和下划线组成，且只能以字母开头

**变量定义：**
1. key=value
```bash
http_port=80
```
2. ansible-playbook –e 选项指定
```bash
ansible-playbook test.yml -e "hosts=www user=magedu"
```

**变量调用方式：**
1. 通过{{ variable_name }} 调用变量，且变量名前后必须有空格，有时用"{{ variable_name }}"才生效


示例1：使用setup变量
```yml
- hosts: websrvs
  remote_user: root
  tasks:
    - name: create log file
      file: name=/var/log/ {{ ansible_fqdn }} state=touch

#运行
ansible-playbook var.yml
```

示例2：变量
```yml
- hosts: websrvs
  remote_user: root
  tasks:
    - name: install package
      yum: name={{ pkname }} state=present

#运行
ansible-playbook –e pkname=httpd var.yml
```

示例3：变量
```yml
- hosts: websrvs
  remote_user: root
  vars:
    - username: user1
    - groupname: group1
  tasks:
    - name: create group
      group: name={{ groupname }} state=present
    - name: create user
      user: name={{ username }} state=present

#运行
ansible-playbook -e "username=user2 groupname=group2" var2.yml
```



### 主机变量
> 可以在inventory中定义主机时为其添加主机变量以便于在playbook中使用

示例1：
```ini
[websrvs]
www1.magedu.com http_port=80 maxRequestsPerChild=808
www2.magedu.com http_port=8080 maxRequestsPerChild=909
```


### 组变量
>组变量是指赋予给指定组内所有主机上的在playbook中可用的变量

示例：变量
```ini
[websrvs]
www1.magedu.com
www2.magedu.com
[websrvs:vars]
ntp_server=ntp.magedu.com
nfs_server=nfs.magedu.com
```


### 普通变量
```ini
[websrvs] 
192.168.99.101 http_port=8080 hname=www1 
192.168.99.102 http_port=80 hname=www2
```
### 公共（组）变量
```ini
#配置文件
[websvrs:vars] 
http_port=808
mark="_" 
[websrvs] 
192.168.99.101 http_port=8080 hname=www1 
192.168.99.102 http_port=80 hname=www2

#运行
ansible websvrs –m hostname –a 'name={{ hname }}{{ mark }}{{ http_port }}'
```

### 命令行指定变量：
```bash
ansible websvrs –e "http_port=8000" –m hostname –a 'name={{ hname }}{{ mark }}{{ http_port }}'
```

### 使用变量文件

变量文件
```bash
[centos]$ cat vars.yml
var1: httpd
var2: nginx
```

示例
```yml
[centos]$ cat var.yml
- hosts: web
  remote_user: root
  vars_files:
    - vars.yml
  tasks:
    - name: create httpd log
      file: name=/app/{{ var1 }}.log state=touch
    - name: create nginx log
      file: name=/app/{{ var2 }}.log state=touch
```
