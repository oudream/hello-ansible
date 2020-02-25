# roles

> ansible自1.2版本引入的新特性，用于层次性、结构化地组织playbook。roles能够根据层次型结构自动装载变量文件、tasks以及handlers等。要使用roles只需要在playbook中使用include指令即可。简单来讲，roles就是通过分别将变量、文件、任务、模板及处理器放置于单独的目录中，并可以便捷地include它们的一种机制。角色一般用于基于主机构建服务的场景中，但也可以是用于构建守护进程等场景中

复杂场景：建议使用roles，代码复用度高
>变更指定主机或主机组
>如命名不规范维护和传承成本大
>某些功能需多个Playbook，通过includes即可实现


角色(roles)：角色集合
```bash
roles/
mysql/
httpd/
nginx/
memcached/
```

**Ansible Roles目录编排**
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190718144710299.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly90aHNvbi5ibG9nLmNzZG4ubmV0,size_16,color_FFFFFF,t_70)

## roles目录结构

每个角色，以特定的层级目录结构进行组织
```bash
playbook.yml
[101]$ tree
.
└── roles
    ├── mysql
    │   ├── default
    │   ├── fies
    │   ├── handlers
    │   ├── meta
    │   ├── tasks
    │   ├── templates
    │   └── vars
    └── nginx
        ├── default
        ├── fies
        ├── handlers
        ├── meta
        ├── tasks
        ├── templates
        └── vars
```

Roles各目录 | 作用 
- |- 
`/roles/project/ `| 项目名称,有以下子目录
`files/ `| 存放由copy或script模块等调用的文件
`templates/ `| template模块查找所需要模板文件的目录
`tasks/ `| 定义task,role的基本元素，至少应该包含一个名为main.yml的文件；其它的文件需要在此文件中通过include进行包含
`handlers/ `| 至少应该包含一个名为main.yml的文件；其它的文件需要在此文件中通过include进行包含
`vars/ `| 定义变量，至少应该包含一个名为main.yml的文件；其它的文件需要在此文件中通过include进行包含
`meta/ `| 定义当前角色的特殊设定及其依赖关系,至少应该包含一个名为main.yml的文件，其它文件需在此文件中通过include进行包含
`default/ `| 设定默认变量时使用此目录中的main.yml文件


## 创建role
(1) 创建以roles命名的目录
(2) 在roles目录中分别创建以各角色名称命名的目录，如webservers等
(3) 在每个角色命名的目录中分别创建files、handlers、meta、tasks、templates和vars目录；用不到的目录可以创建为空目录，也可以不创建
(4) 在playbook文件中，调用各角色
(5)针对大型项目使用Roles进行编排

roles的示例如下所示：
```bash
site.yml
webservers.yml
dbservers.yml
roles/
  ├──dbservers/
  │  ├── files/
  │  ├── templates/
  │  ├── tasks/
  │  ├── handlers/
  │  ├── vars/
  │  └── meta/
  │
  └──webservers/ 
     ├── files/
     ├── templates/  
     ├── tasks/
     ├── handlers/
     ├── vars/
     └── meta/
```

示例1：
```bash
nginx_role.yml  roles

#roles目录下结构
roles/
└── nginx
    ├── files
    │   └── main.yml
    ├── tasks
    │   ├── groupadd.yml
    │   ├── install.yml
    │   ├── main.yml
    │   ├── restart.yml
    │   └── useradd.yml
    └── vars
        └── main.yml
```


**调用角色方法1：**
```yml
- hosts: websrvs
  remote_user: root
  roles:
    - mysql
    - memcached
    - nginx
```

**调用角色方法2：**
传递变量给角色
```yml
- hosts:
  remote_user:
  roles:
    - mysql
    - { role: nginx, username: nginx }
```
键role用于指定角色名称
后续的k/v用于传递变量给角色

**调用角色方法3：还可基于条件测试实现角色调用**
```yml
roles:
  - { role: nginx, username: nginx, when: ansible_distribution_major_version == '7' }
```
完整的roles架构
```yml
# nginx-role.yml 顶层任务调用yml文件
---
- hosts: testweb
  remote_user: root
  roles:
    - role: nginx
    - role: httpd 可执行多个role

# roles/nginx/tasks/main.yml
---
- include: groupadd.yml
- include: useradd.yml
- include: install.yml
- include: restart.yml
- include: filecp.yml

# roles/nginx/tasks/groupadd.yml
---
- name: add group nginx
user: name=nginx state=present

# roles/nginx/tasks/filecp.yml
---
- name: file copy
copy: src=tom.conf dest=/tmp/tom.conf
```

## roles playbook tags使用
```bash
ansible-playbook --tags="nginx,httpd,mysql" nginx-role.yml
```
`nginx-role.yml`内容 
```yml
---
- hosts: testweb
  remote_user: root
  roles:
    - { role: nginx ,tags: [ 'nginx', 'web' ] ,when: ansible_distribution_major_version == "6" }
    - { role: httpd ,tags: [ 'httpd', 'web' ] }
    - { role: mysql ,tags: [ 'mysql', 'db' ] }
    - { role: marridb ,tags: [ 'mysql', 'db' ] }
    - { role: php }
```


# 推荐资料
[ansible官方网站](http://galaxy.ansible.com)
[ansible中文文档](http://ansible.com.cn/)
[ansible项目](https://github.com/ansible/ansible)
