# 循环
Ansible的循环也与编程语言中的类似，循环可以帮你重复做一件事，直到它收到某一个特定结果。

## 标准循环

- 简写重复的任务

```
- name: add server users
  user: name={{ item }} state=present group=wheel
  with_items:
    - testuser1
    - testuser2
```

- 变量中使用 YAML 列表
```
// 在变量中使用 YAML 列表
with_itm_items: "{{ somelist }}"

// 等同于
- name: add_user testuser1
  user: name=testuser1 state=present group=wheel
- name: add_user testuser2
  user: name=testuser2 state=present group=wheel

// 支持哈希列表
- name: add serveral user
  user: name={{ item.name }} state=present groups={{ item.groups }}
  with_itm_items:
    - { name: 'testuser1', groups: 'wheel' }
    - { name: 'testuser2', groups: 'root'}
```

## 嵌套循环
```
- name: give users access to multiple databases
  mysql_user: name={{ item[0] }} priv={{ item[1] }}.*:ALL append_privs=yes password=foo
  with_nested:
    - [ 'alice', 'bob']
    - [ 'clientdb', 'employeedb', 'providerdb']
```
或者
```
- name: here. 'users' contains the above list of employees
  mysql_user: name={{ itme[0] }} priv={{ item[1] }}.*:ALL append_privs=yes password=foo
  with_nested:
    - "{{users}}"
    - [ 'clientdb', 'employeedb', 'providerdb' ]
```

## 对哈希表使用循环
使用 `with_dict` 来循环哈希表中的元素,下面打印用户名和电话号码
```
---
- hosts: all
  vars:
    users:
      alice:
        name: Alice Appleworth
        telephone: 123-456-789
      bob:
        name: Bob Bananarama
        telephone: 987-654-321
  tasks:
    - name: print phone records
      debug: msg="User {{ item.key }} is {{ item.value.name }} ({{ item.value.telephone }}]"
      with_dict: "{{users}}"
```

## 对文件列表使用循环
使用 `with_fileglob` 可以以非递归的方式来匹配单个目录的文件
```
---
- hosts: all
  tasks:
    # first ensure out target directory exists
    - file: dest=/tmp/fooapp state=directory
    # copy each file over that matches the given pattern
    - copy: src={{ item }} dest=/tmp/fooapp/ owner=root mode=600
      with_fileglob:
        - /opt/ansible/playbooks/fooapp/*
```

## 对并行数据使用循环
```
// 变量
alpha: ['a', 'b', 'c' 'd' ]
numbers: [ 1, 2, 3, 4 ]
// 得到 '(a,1)' 和 ‘(b,2)’,可以使用`with_together`
tasks:
  - debug: msg="{{ item.0 }} and {{ item.1 }}"
    with_together:
      - "{{ alpha }}"
      - "{{ numbers }}"
```

## 对子元素使用循环
```
---          
- name: create user
  hosts: all
  vars:      
    users:   
      - name: alice
        authorized:
          - /tmp/alice/onekey.pub
          - /tmp/alice/twokey.pub
        mysql:
          password: mysql-password
          hosts:
            - "%"
            - "127.0.0.1"
            - "::1"
            - "localhost"
          privs:
            - "*.*:SELECT"
            - "DB1.*:ALL"
      - name: bob
        authrized:
          - /tmp/bob/id_rsa.pub
        mysql:
          password: other-mysql-password
          hosts:
            - "db1"
          privs:
            - "*.*:SELECT"
            - "DB2.*:ALL"
```
对子元素使用循环
```
- user: name={{ item.name }} state=present generate_ssh_key=yes
  with_items: "{{users}}"

- authorized_key: "user={{ item.0.name }} key='{{ lookup('file', item.1) }}'"
  with_subelements:
     - users
     - authorized
```
根据mysql hosts以及预先给定的privs subkey列表,我们也可以在嵌套的subkey中迭代列表
```
- name: Setup MySQL users
  mysql_user: name={{ item.0.user }} password={{ item.0.mysql.password }} host={{ item.1 }} priv={{ item.0.mysql.privs | join('/') }}
  with_subelements:
    - users
    - mysql.hosts
```

## 对整数数组使用循环
`with-sequence` 可以以升序拍了生成一组序列，可以指定起始、终止及步长
```
---
- hosts: all

  tasks:

    # create groups
    - group: name=evens state=present
    - group: name=odds state=present

    # create some test users
    - user: name={{ item }} state=present groups=evens
      with_sequence: start=0 end=32 format=testuser%02x

    # create a series of directories with even numbers for some reason
    - file: dest=/var/stuff/{{ item }} state=directory
      with_sequence: start=4 end=16 stride=2

    # a simpler way to use the sequence plugin
    # create 4 groups
    - group: name=group{{ item }} state=present
      with_sequence: count=4
```


## 随机选择
`random_choice` 可以随机获取值
```
- debug: msg={{ item }}
  with_random_choice:
     - "go through the door"
     - "drink from the goblet"
     - "press the red button"
     - "do nothing"
```

## Do-Until 循环
```
- action: shell /usr/bin/foo
  register: result
  until: result.stdout.find("all systems go") != -1
  retries: 5
  delay: 10
```
直到结果的stdout输出包含`all systems go` 或者经过重复 5 次任务

## 查找匹配文件
```
- name: INTERFACES | Create Ansible header for /etc/network/interfaces
  template: src={{ item }} dest=/etc/foo.conf
  with_first_found:
    - "{{ansible_virtualization_type}}_foo.conf"
    - "default_foo.conf"
```

可以用于搜索路径
```
- name: some configuration template
  template: src={{ item }} dest=/etc/file.cfg mode=0444 owner=root group=root
  with_first_found:
    - files:
       - "{{inventory_hostname}}/etc/file.cfg"
      paths:
       - ../../../templates.overwrites
       - ../../../templates
    - files:
        - etc/file.cfg
      paths:
        - templates
```

## 迭代执行结果
```
- name: Example of looping over a REMOTE command result
  shell: /usr/bin/something
  register: command_result

- name: Do something with each result
  shell: /usr/bin/something_else --param {{ item }}
  with_items: "{{command_result.stdout_lines}}"
```

## 循环列表
```
- name: indexed loop demo
  debug: msg="at array position {{ item.0 }} there is a value {{ item.1 }}"
  with_indexed_items: "{{some_list}}"
```
## 循环配置文件
```
// 使用 ini 插件
- debug: msg="{{item}}"
  with_ini: value[1-2] section=section1 file=lookup.ini re=true
```

## 在循环中是用注册器
```
- hosts: 172.16.11.210  
  name: test loop register
  remote_user: root     
  tasks:                
    - name: test loop register
      shell: /bin/echo "{{ item }}"
      with_items:       
        - Hello         
        - World         
      register: echo_result
      #- debug: msg="{{ echo_result.results }}"

    - name: Fail if return code is not 0
      debug: msg="The command ({{ item.cmd }}) did not have a 0 return code."
      when: item.rc != 0                                                                                                                                    
      with_items: "{{ echo_result.results }}"
```
