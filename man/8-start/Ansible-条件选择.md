# 条件选择
Ansible 有类似于变成语言的条件判断语法，用于控制执行流。

## When 语句

###  当有一个操作是要某个主机达到某个特定条件才会触发的 tasks，Ansible 可以使用 When 语句来实现。

```
// 当主机为 Debian Linux 时立即关机
tasks:
  - name: "shutdown Debian flavored system"
    command: /sbin/shutdown -t now
    when: ansible_os_family == "Debian"
```

### 根据 action 执行结果，来决定接下来要执行的 action

```
tasks:
  - command: /bin/false
    register: result
    ignore_error: True
  - command: /bin/something
    when: result|failed
  - command: /bin/something_else
    when: result|success
  - command: /bin/still/something_else
    when: result|skipped
```

### 根据系统变量 fact 作为 when 条件，使用 `|int`还可以转换返回值的类型

```
---
  - hosts: webservers
    tasks:
      - debug: msg="only on Red Hat 6, derivatives, and later"
        when: ansible_os_family == "RedHat" and ansible_lsb.major_release|int >=6
```

## 条件表达式
在 playbooks 和 inventory 中定义的变量，可以根据布尔值来决定是否被执行
```
vars:
  epic: true
```

- 使用布尔值
```
//  真
tasks：
  - shell: echo "This certainly is epic!"
    when: epic
// 假
tasks:
  - shell: echo "This certainly isn't epic"
    when: not epic
// 定义变量
tasks:
  - shell: echo "I've got '{{ foo }}' and am not afraid to use it!"
    when: foo is defined
  - fail: msg="Bailing out, this play require 'bar'"
    when: bar is not defined
// 数值判断
tasks:
  - command: echo {{ item }}
    with_item: { 0, 2, 4, 6, 8, 10 }
    when: item > 5
```

## 加载客户事件
```
tasks:
  - name: gather site specific fact data
    action: site_facts
  - command: /usr/bin/thingy
    when: my_custom_fact_just_retrieved_from_the_remote_system == '1234'
```

## 在 roles 和 include 中使用 when 语句

- include

```
- include: tasks/sometasks.yml
  when: "'reticulating splines' in output"
```

- roles

```
- hosts: webservers
  roles:
    - { role: debian_stock_config, when: ansible_os_family == 'Debian'  }
```

## 条件导入
在某个特定条件下，你需要根据特定标准来以不同方式处理同一事件，比如是用同一 playbook 在不同操作系统安装同一个软件包

```
// playbook
---
- hosts: all
  remote_user: root
  vars_files:
    - "vars/common.yml"
    - [ "vars/{{ ansible_os_family }}.yml", "vars/os_defaults.yml" ]
  tasks:
    - name: make sure apache is running
      service: name={{ apache }} state=running      

//for vars/CentOS.yml
---
apache: httpd
somethingelse: 42
```

## 注册变量
在 playbook 中，存储某个命令的结果在变量中，以供后面使用。 使用`register` 关键词决定将结果存放到那个变量中。
```
- name: test playbook
  hosts: all
  tasks:
    - shell: cat /etc/motd
      register: motd_contents
    - shell: echo "motd contains the word hi"
      when: motd_contents.stdout.find('hi') != -1
```
参数的内容通过 `stdout` 可以被访问。
