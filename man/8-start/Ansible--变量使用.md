# 变量

自动化技术使得重复做事变的更加容易，当系统有所不同，Ansible 可以是使用相同的 template，通过变量来处理不同系统。
Ansible 的变量名称可以以 **`字母、数字和下划线`** 命名，变量开头要以 **字母开头**

-  在 inventory 中定义变量

可以参考 「Ansible--入门」 inventory 章节介绍

-  在 playbook 中定义变量

```
- hosts: web
  vars:
    http_port: 80
```

## 使用变量

在 template 语言 jinjia2 的语法引用，利用中括号和点号来访问子属性
```
foo['field1']
foo.field2
```

## 在 playbook 中使用变量
在 playbook 中使用，需要用 `{{}}` 引用即可。
```
---
- hosts: webservers
  vars:
    apache_config: labs.conf
  tasks:
    - name: deploy haproxy config
      template: src={{ apache_config }} dest=/etc/httpd/conf.d/{{ apache_config }}
```

在 playbook 中使用变量文件定义变量
```
---
- hosts: webservers
  vars_files:
    - vars/server_vars.yml
  tasks:
    - name: deploy haproxy config
      template: src={{ apache_config }} dest=/etc/httpd/conf.d/{{ apache_config }}
```
变量文件 `vars/server_vars.yml` 内容
```
apache_config: labs.conf
```

### YAML 陷阱
YAML 语法要求如果值以 `{{foo}}` 开头，需要讲整行用双引号扩起来，为了确保你不是在声明一个字典。
```
// 错误
---
- hosts: app_servers
  vars:
    app_path: {{ base_path }}/22
// 正确
---
- hosts: app_servers
  vars:
    app_path: "{{ base_path }}/22"
```

## 使用 Facts 获取主机系统变量
Ansible 可以通过 module_setup 收集远程主机的系统信息--facts，通过 facts 收集的信息，可以以变量形式来使用。
```
ansible all -m setup
```

### 在 playbook 中使用 facts 变量
命令会返回海量的变量数据，这些变量可以在 playbook 中直接使用
```
---
- hosts: all
  name: install some package
  user: root
  tasks:
    - name: echo system
      shell: echo {{ ansible_os_family }}
    - name: install Git on RedHat
      yum: name=git state=present
      when: ansible_os_family == "RedHat"
    - name: install Git on Debian
      apt: name=git state=installed
      when: ansible_os_family == "Debian"
```
### 使用复杂的 facts 变量
使用通过 fact 收集到复杂的、多层次的变量。
```
"ansible_eth1": {
            "active": true,
            "device": "eth1",
            "ipv4": {
                "address": "172.16.11.210",
                "broadcast": "172.16.11.255",
                "netmask": "255.255.255.0",
                "network": "172.16.11.0"
            },
            "ipv6": [
                {
                    "address": "fe80::5054:ff:fec0:b2b3",
                    "prefix": "64",
                    "scope": "link"
                }
            ],
            "macaddress": "52:54:00:c0:b2:b3",
            "module": "virtio_net",
            "mtu": 1500,
            "pciid": "virtio1",
            "promisc": false,
            "type": "ether"
        },
```
可以通过下面两种方式访问到复杂变量的自变量
```
// 中括号
{{ ansible_eth1["ipv4"]["address"] }}
// 点号
{{ ansible_eth1.ipv4.address }}
```
### 关闭facts
在 playbook 中， 可以设置是否启用 gather_facts 来获取远程系统信息
```
---
- hosts: webservers
  gather_facts: no
```

### 使用被控端自定义变量
在被控端可以在 `/etc/ansible/facts.d` 目录中，任何以 `.fact` 结尾的文件都可以在 Ansible 提供局部 facts。
```
//定义 /etc/ansible/facts.d/perferences.fact 文件
[general]
abcd=1
bcde=2

// 主控端获取变量
172.16.11.210 | SUCCESS => {
    "ansible_facts": {
        "ansible_local": {
            "perferences": {
                "general": {
                    "abcd": "1",
                    "bcde": "2"
                }
            }
        }
    },
    "changed": false
}
```
这样就可以在 playbook 中引用变量或者覆盖掉系统的 facts 值
```
---
- hosts: all
  user: root
  tasks:
    - name: create directory for ansible custom facts
      file: state=directory recurse=yes path=/etc/ansible/facts.d/
    - name: install custom ipmi fact
      copy: src=/opt/ansible/playbooks/ipmi.fact dest=/etc/ansible/facts.d
    - name: re-read facts after adding custom fact
      setup: filter=ansible_local
```

## 注册变量
可以把 tasks 运行结果作为变量，供后面的 action 使用，在运行 playbook 时，可以使用 -v 参数看到结果值，
```
---
- hosts: webservers
  tasks:
    - shell: /bin/ls
      register: result
      ignore_errors: true
    - shell: /bin/echo "{{ result.stdout }}"
      when: result.rc == 5
    - debug: msg="{{ result.stdout }}"
```

## 在文件模板中使用变量
Ansible 使用的模本是 python 的一个 jinja2 模板。在 playbook 中定义的变量，可以直接在 template 中使用。

### template 变量的定义

```
// 使用template module来拷贝文件 index.html.j2，并替换 index.html.j2 中的变量为 playbook 中定义的变量。
---
- hosts: web
  vars:
    http_port: 80
    defined_name: "Hello My name is Charlie"
  remote_user: root
  tasks:
  - name: ensure apache is at the latest version
    yum: pkg=httpd state=latest

  - name: Write the configuration file
    template: src=templates/httpd.conf.j2 dest=/etc/httpd/conf/httpd.conf
    notify:
    - restart apache

  - name: Write the default index.html file
    template: src=templates/index2.html.j2 dest=/var/www/html/index.html

  - name: ensure apache is running
    service: name=httpd state=started
  - name: insert firewalld rule for httpd
    firewalld: port={{ http_port }}/tcp permanent=true state=enabled immediate=yes

  handlers:
    - name: restart apache
      service: name=httpd state=restarted
```
###  template 变量的使用
在 template index.html.j2 中可以直接使用系统变量和用户自定义的变量

- 系统变量 **{{ ansible_hostname }}, {{ ansible_default_ipv4.address }}**
- 用户自定义变量： **{{ defined_name }}**


## 命令行中传递变量
在执行 playbook 命令时可以通过 `vars_prompt` 和 `vars_files` 传递变量.
```
---
- hosts: '{{ hosts }}'
  remote_user: '{{ user }}'
  tasks:
    - ....
// 在命令行中传递参数
ansible-playbook release.yml --extra-vars "hosts=webservers user=web"

// 使用 JSON 格式传递参数
ansible-playbook release.yml --extra-vars "{'hosts':'webservers', 'user':'web'}"

// 通过文件传递参数
ansible-playbook release.yml --extra-vars "@vars.json"
```
