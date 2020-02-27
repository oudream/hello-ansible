# Playbooks
Playbooks 是 Ansible 的配置、部署、编排语言，相当于控制远程主机的一系列命令的集合，通过 YAML 语言编写。Ansible-Playbook 命令根据自上而写的顺序依次执行。 Playbook 允许传输摸个命令的状态到后面的指令，或者从一台主机的文件中获取内容并赋值变量，然后传给另外一台主机使用，这是 ansible 命令无法实现的。

## YAML 语法介绍

### 文件开始符

```
---
```
### 数组列表
列表中的所有成员都开始于相同缩进级别，并使用 `-` 来作为开头
```
- Apple
- Orange
- Mango
```

### 字典
字典是有一个简单的 `Key: value` 形式组成，注意 `:` 后面有**空格**
```
name: charlie
job: Developer
mail: charlie.cui127@gmail.com
```

在 playbook 中会有更为复杂的用法

- 字典与字典嵌套

```
martin:
    name: Martin D'vloper
    job: Developer
    skill: Elite
```

- 字典与数组的嵌套

```
-  martin:
    name: Martin D'vloper
    job: Developer
    skills:
      - python
      - perl
      - pascal
-  tabitha:
    name: Tabitha Bitumen
    job: Developer
    skills:
      - lisp
      - fortran
      - erlang
```
注意，如果变量里有 `:`,则需要加引号
```
foo: "{{ variable }}"
```

# Playbook 基本用法

最基本的 playbook 分为三部分：
1. 在什么机器上以什么身份执行
  - hosts
  - users
2. 定义 playbook 执行需要的变量
  - variable
3. 执行的任务是都有什么
  - tasks
4. 善后的任务是什么
  - handlers  


**执行 Playbook**

```
// 执行playbook
Ansible-playbook user.yaml

// 查看详细输出
ansible-playbook user.yaml --list-hosts
```

## 示例

### 官方示例

要学习更多的 playbook 用法，可以通过[Playbooks 官方示例](https://github.com/ansible/ansible-examples)。

### Playbook 分享平台

Ansible 提供了一个 Playbook 的分享平台，上面的例子是有 Ansible 使用者自己上传的。
[Ansible分享平台](https://galaxy.ansible.com/)

### 简单示例

- 创建用户

```
// 新增一个用户
cat user.yaml
---
- name: create user           
  hosts: all                \\ host or group
  user: root
  gather_facts: false
  vars:                     \\ variable
  - user: "charlie"
  tasks:                     \\ tasks
  - name: create user
    user: name= "{{ user }}"
    notify: create user ok
  handlers:
    - name: create user ok
      debug: msg= "Create User OK"
```
1. name 参数对该 playbook 实现功能的一个概述，后面执行过程中会打印 name 变量值
2. hosts 参数指定了那些主机
3. user 参数执行了使用什么用户登陆远程主机
4. gather_facts 参数指定了下面任务执行前，是否先执行 setup 模块获取主机相关信息，这些后面 task 会使用 setup 获取的信息
5. vars 参数指定了变量， 变量 user，值为 charlie，值得注意的是参数要用引号
6. task 指定了一个任务，下面的 name 参数同样是对任务的描述，在执行过程中打印出来。user 指定了调用 user模块，name 是user模块中的参数，增加的用户名是上面 user 的值

执行结果
```
ansible-playbook user.yaml
PLAY [create user] *************************************************************

TASK [create user] *************************************************************
changed: [172.16.11.210]
changed: [172.16.11.211]

RUNNING HANDLER [create user] **************************************************
ok: [172.16.11.210] => {
    "msg": "Create User OK"
}
ok: [172.16.11.211] => {
    "msg": "Create User OK"
}
PLAY RECAP *********************************************************************
172.16.11.210              : ok=1    changed=1    unreachable=0    failed=0   
172.16.11.211              : ok=1    changed=1    unreachable=0    failed=0   
```

- 安装apache

```
cat apache.yaml
---
- hosts: all
 vars:
   http_port: 80
   max_clients: 2048
 user: root
 tasks:
 - name: ensure apache is at latest version
   yum: pkg=httpd state=latest
 - name: write the apache config file
   template: src=/srv/httpd.j2 dest=/etc/httpd.conf
   notify:
   - restart apache
 - name: ensure apache is running
   service: name=httpd state=started
 handlers:
   - name: restart apache
     service: name=httpd state=restarted
```

## 主机和用户 Host and User
在执行 playbook 时，可以选择操作的目标主机是那些，以那个用户执行
host 行的内容是一个或多个主机的 patterns， 以逗号分隔
```
---
- hosts: 172.16.11.210, 172.16.11.211, [all]
  remote_user: root
```

还可以在每个 task 中，定义远程执行用户
```
---
- hosts: all
  user: root
  tasks:
  - name: test connection
    ping:
    remote_user: root
```
也支持 sudo 方法,在 task中同样支持,在 sudo 需要密码时，可以加上选项 --ask-sudo-pass
```
---
- hosts: all
  remote_user: charlie
  sudo: yes
  task：
    - service： name=nginx state=started
      sudo: yes
      sudo_user: root
```

## 任务列表 Tasks
- tasks 是从上到下顺序执行，如果中间发生错误，整个 playbook 便会中断。
- 每一个 task 是对module的一次调用,通常会带有特定参数，参数可以使用变量。
- 每一个 task 必须有一个 name 属性，name 值会在命令行中输出，以提示用户，如果没有定义，aciton 的值会作为输出信息来标记task

### 语法
```
tasks:
  - name: make sure apache is running
    service: name=httpd state=running

// 如果参数过长，可以使用空格或者缩进分隔为多行
tasks:
  - name: copy ansible inventory file to client
    copy: src=/etc/ansible/hosts dest=/etc/ansible/hosts
          owner=root group=root mode=0644

// 或者使用 yaml 的字典作为参数
tasks:
  - name: copy ansible inventory file to client
    copy:
      src: /etc/ansible/hosts
      dest: /etc/ansible/hosts
      owner: root
      group: root
      mode: 0644

// 大部分的模块都是使用 `key-value` 这种格式的，其中有两个比较特殊，command 和 shell 模块。
tasks:
  - name: disable selinux
    command: /sbin/setenforce 0
tasks:
  - name: run this command and ignore the result
    shell: /usr/bin/command || /bin/true
tasks:
  - name: run some command and ignore the reslut
    shell: /usr/bin/somecommadn
    ignore_error: True
```

### 执行状态
task 中每个 action 会调用一个 module，在 module 中会去检查当前系统状态是否需要重新执行，具体判断需要有各个 module 自己来实现。
- 如果执行那么 action 会得到返回值 changed；
- 如果部执行，那么 action 会得到返回值 OK

**状态实例 以一个 copy 文件为例**
```
// playbook
copy.yaml                 
---
- name: copy a test file
  hosts: all
  user: root
  tasks:
    - name: copy a test file to /opt/ansible
      copy: src=/opt/ansible/test.txt dest=/opt/ansible/

// 第一次执行结果
ansible-playbook copy.yaml
PLAY [copy a test file] ********************************************************

TASK [setup] *******************************************************************
ok: [172.16.11.211]
ok: [172.16.11.210]

TASK [copy a test file to /opt/ansible] ****************************************
changed: [172.16.11.210]
changed: [172.16.11.211]

PLAY RECAP *********************************************************************
172.16.11.210              : ok=2    changed=1    unreachable=0    failed=0   
172.16.11.211              : ok=2    changed=1    unreachable=0    failed=0   

// 第二次执行结果
ansible-playbook copy.yaml

PLAY [copy a test file] ********************************************************

TASK [setup] *******************************************************************
ok: [172.16.11.211]
ok: [172.16.11.210]

TASK [copy a test file to /opt/ansible] ****************************************
ok: [172.16.11.210]
ok: [172.16.11.211]

PLAY RECAP *********************************************************************
172.16.11.210              : ok=2    changed=0    unreachable=0    failed=0   
172.16.11.211              : ok=2    changed=0    unreachable=0    failed=0  
```
可以看到第一次 task的状态是 changed 状态，第二次再次执行，task 状态是 OK，说明文件已经存在，避免 ansible 再次重复执行。

## 响应事件 Handler

### 什么是 handler
每个主流的变成语言都会有 event 机制，那么 handler 就是 playbook 的 event。Handler 里面的每个 handler，也是对 module 的一次调用。不同的是 handler 不会默认的按照顺序执行。
Tasks 中的任务是有状态的，changed 或者 ok。 在 Ansible 中，只有 task 的执行状态为 changed 时，才会触发，这就是 handler。

### 应用场景
如果在 tasks 中修改了某个服务的配置文件，就需要重新启动服务，重新启动服务就可以设计成为一个 handler

###  触发Handlers

**只有 action 是 changed 时，才会执行 handler**
- 第一次执行时，tasks 的状态是 changed， 回触发 handler
- 第二次执行时，task 的状态是 OK， 那么就不会触发 handler

```
// 一个 handler 最多被执行一次,在任务执行中，有多个 task notify 同一个 handler， 那么只执行一次
---
- name: handler state
  hosts: all
  remote_user: root
  vars:
    random_number1: "{{ 10 | random }}"
    random_number2: "{{ 100 | random }}"
  tasks:
  - name: Copy the /etc/hosts to /opt/ansible/host.{{ random_number1 }}
    copy: src=/etc/hosts dest=/opt/ansible/host.{{ random_number1 }}
    notify:
      - call in every action
  - name: Copy the /etc/hosts to /opt/ansible/host.{{ random_number2 }}
    copy: src=/etc/hosts dest=/opt/ansible/host.{{ random_number2 }}
    notify:
      - call in every action
  handlers:
    - name: call in every action
      debug: msg='call in every action, but execute only one time'

// 按照 handler 的定义顺序执行,handlers 是按照在 handlers 中定义的顺序执行的， 而不是按照 notify 的顺序执行的
// notify 的定义顺序是 3 > 2 > 1，而实际 handler 结果是 handler 定义的顺序 1 > 2 > 3。
cat handler_notify.yaml                 
---
- hosts: all
  gather_facts: no
  remote_user: root
  vars:
    random_number1: "{{ 10 | random }}"
    random_number2: "{{ 100 | random }}"
    random_number3: "{{ 1000 | random }}"
  tasks:
    - name: copy the /ets/hosts to /tmp/hosts.{{ random_number1 }}
      copy: src=/etc/hosts dest=/tmp/hosts.{{ random_number1 }}
      notify:
        - define the 3nd handler

    - name: copy the /ets/hosts to /tmp/hosts.{{ random_number2 }}
      copy: src=/etc/hosts dest=/tmp/hosts.{{ random_number2 }}
      notify:
        - define the 2nd handler

    - name: copy the /ets/hosts to /tmp/hosts.{{ random_number3 }}
      copy: src=/etc/hosts dest=/tmp/hosts.{{ random_number3 }}
      notify:
        - define the 1nd handler
  handlers:
    - name: define the 1nd handler
      debug: msg=" defind the 1nd handler"

    - name: define the 2nd handler
      debug: msg=" defind the 2nd handler"

    - name: define the 3nd handler
      debug: msg=" defind the 3nd handler"
```

# playbook roles 和 include
在刚开始使用 playbook 时，习惯性会把 playbook 写成一个很大的文件，然而在实际情况下， 有些文件是可以重用的。playbook 可以使用 include，把其他 playbook 文件中的 variables、tasks 或者 handlers 从其他文件拉取过来。

## 规划目录组织结构
通过目录规格，可以使 playbook 模块化，使代码易读、可以重用、层次清晰。

可以通过 `ansible-galaxy` 工具，初始化一个 role 目录
```
// init
ansible-galaxy init httpd

// tree
.
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── README.md
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml
```

## include 语句

### 普通用法

```
// 可以像其他 include 语句一样， 直接include
# possibly saved as tasks/firewall_httpd_default.yaml
- name: insert firewalld rule for httpd
  firewalld: port=80/tcp permanent=true state=enable immediate=yes

// main.yml
tasks:
  - include: tasks/firewall_httpd_default.yml
```

### 高级用法，传递参数
```
// 添加参数
tasks:
  - include: tasks/firewall.yml port=80
  - include: tasks/firewall.yml port=3306

//  支持结构化
tasks:
  - include: tasks/firewall.yml
    vars:
      wp_user: charlie
      ssh_key:
        - key/one.txt
        - key/two.txt
// json格式
tasks:
  - { include: wordpress.yml, wp_user: timmy, ssh_keys: [ 'key/one.txt', 'key/two.txt' ] }
```
### 在 handlers section 中定义
```
// handlers.yml
// this might be in a file line handlers/handlers.yml
- name: restart apache
  service: name = apache state=restarted
// 在一个 playbook 中引用 handlers.yml
handlers:
  - include: handlers/handlers.yml
```

include 语句可以和其他非 include 的 tasks 和 handlers 混合使用。

**例如：**
```
- name: this is a play at the top level of a file
  host: all
  remote_user: root
  tasks:
    - name: say hi
      tags: foo
      shell: echo "Hi "
- include: load_balancers.yml
- include: webservers.yml
- include: dbservers.yml
```

## Roles
Ansible 中还有一个比 include 更为强大的代码重用机制，那就是roles！。Roles 基于一个已知的文件结构，去自动加载某些 var_files, tasks, handlers，基于 roles 对内容进行分组，更有利于与其他用户分享 roles。
Ansible提供了一个分享role的平台, https://galaxy.ansible.com/, 在galaxy上可以找到别人写好的role.

### Roled的目录结构
在 ansible 中，通过遵循特定的目录结构，可以实现对 role 的定义。下面的目录结构是定义了两个 role， 一个名字是 common，另外一个是 webserver，并在 site.yml 中调用这两个 role。
```
// role 的目录结构
site.yml
webservers.yml
fooservers.yml
roles/
   common/
     files/
     templates/
     tasks/
     handlers/
     vars/
     defaults/
     meta/
   webservers/
     files/
     templates/
     tasks/
     handlers/
     vars/
     defaults/
     meta/

// site.yml 中使用
---
- hosts: webservers
  roles:
    - common
    - webservers
```

###  使用带参数的 role
```
---
- hosts: webservers
  roles:
    - common
    - { role: foo_app_instance, dir: '/opt/a', port: 5000 }
    - { role: foo_app_instance, dir: '/opt/b', port: 5001 }
// 设置触发条件,条件语句应用到 role 中的每个 task上。
---
- hosts: webservers
  roles:
    - { role: some_role, when: "ansible_os_family == 'RedHat'" }
// 分配 tags
---
- hosts: webservers
  roles:
    - { role: foo, tags: [ "bar" , "baz" ] }    
```
### 指定默认的参数
在指定默认参数后，如果在调用时传参数，那么就使用传入的参数值，否则使用默认参数。
```
//指定默认参数
main.yml
roles:
  role_with_var
    tasks:
      main.yml
    vars:
      main.yml
// roles/role_with_var/vars/main.yml
param: "I am the default value"
```
### 与条件语句一起执行
```
//定义只有在 RedHat 系列才执行的 role
---
- host: webservers
  roles:
    - { role: some_role, when: "ansible_os_family == 'RedHat'" }
```
