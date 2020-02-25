# 模板template
> 文本文件，嵌套有脚本（使用模板编程语言编写）

>Jinja2语言，使用字面量，有下面形式
字符串：使用单引号或双引号
数字：整数，浮点数
列表：`[item1, item2, ...]`
元组：`(item1, item2, ...)`
字典：`{key1:value1, key2:value2, ...}`
布尔型：`true/false`

算术运算：`+`，`-`， `*`， `/`，`//`， `%`， `**`
比较操作：`==`， `!=`，` >`， `>=`， `<`， `<=`
逻辑运算：`and`，`or`，`not`
流表达式：`for`，`if`，`when`

## 怎么用？
template功能：根据模块文件动态生成对应的配置文件
template文件必须存放于templates目录下，且命名为 `.j2` 结尾
yaml/yml 文件需和templates目录平级，目录结构如下：
```bash
./
├── temnginx.yml
└── templates
    └── nginx.conf.j2
```

示例1：利用template 同步nginx配置文件
```bash
[centos]$ cp http.conf templates/nginx.conf.j2
[centos]$ vim templates/nginx.conf.j2
    listen {{http_port}}  #这是个变量

[centos]$ vim install_httpd.yml
- hosts: websrvs
  remote_user: root
  tasks:
    - name: template config to remote hosts
      template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf

[centos]$ ansible-playbook temnginx.yml
```


示例2：Playbook中template变更替换
```bash
#修改文件nginx.conf.j2
[centos]$ cat nginx.conf.j2
worker_processes {{ ansible_processor_vcpus }};

[centos]$ cat temnginx2.yml
- hosts: websrvs remote_user: root
  tasks: 
    - name: template config to remote hosts 
      template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf

[centos]$ ansible-playbook temnginx2.yml
```

示例3：Playbook中template算术运算
```bash
[centos]$ cat nginx.conf.j2
worker_processes {{ ansible_processor_vcpus**2 }};
worker_processes {{ ansible_processor_vcpus+2 }};
```

# template的for和if
```yml
#这是写在template文件中
{% for vhost in nginx_vhosts %}
server { 
listen {{ vhost.listen | default('80 default_server') }}; 
}

{% if vhost.server_name is defined %} 
server_name {{ vhost.server_name }}; 
{% endif %} 

{% if vhost.root is defined %} 
root {{ vhost.root }}; 
{% endif %}

{% endfor %}
```

示例1
```yml
// temnginx.yml
---
- hosts: testweb
  remote_user: root
  vars:
    nginx_vhosts:
      - listen: 8080

//templates/nginx.conf.j2
{% for vhost in nginx_vhosts %}
server {
listen {{ vhost.listen }}
}
{% endfor %}

#生成的结果

server {
listen 8080
}
```

示例2
```yml
// temnginx.yml
---
- hosts: mageduweb
  remote_user: root
  vars:
    nginx_vhosts:
      - web1
      - web2
      - web3
  tasks:
    - name: template config
      template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf

// templates/nginx.conf.j2
{% for vhost in nginx_vhosts %}
server {
listen {{ vhost }}
}
{% endfor %}

#生成的结果：

server {
listen web1
}
server {
listen web2
}
server {
listen web3
}
```

示例3
```yml
// temnginx.yml
- hosts: mageduweb
  remote_user: root
  vars:
    nginx_vhosts:
      - web1:
        listen: 8080
        server_name: "web1.magedu.com"
        root: "/var/www/nginx/web1/"
      - web2:
        listen: 8080
        server_name: "web2.magedu.com"
        root: "/var/www/nginx/web2/"
      - web3:
        listen: 8080
        server_name: "web3.magedu.com"
        root: "/var/www/nginx/web3/"
  tasks:
    - name: template config
      template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf

// templates/nginx.conf.j2
{% for vhost in nginx_vhosts %}
server {
listen {{ vhost.listen }}
server_name {{ vhost.server_name }}
root {{ vhost.root }}
}
{% endfor %}

#生成结果：

server {
listen 8080
server_name web1.magedu.com
root /var/www/nginx/web1/
}
server {
listen 8080
server_name web2.magedu.com
root /var/www/nginx/web2/
}
server {
listen 8080
server_name web3.magedu.com
root /var/www/nginx/web3/
}
```

示例4
```yml
// temnginx.yml
- hosts: mageduweb
  remote_user: root
  vars:
    nginx_vhosts:
      - web1:
        listen: 8080
        root: "/var/www/nginx/web1/"
      - web2:
        listen: 8080
        server_name: "web2.magedu.com"
        root: "/var/www/nginx/web2/"
      - web3:
        listen: 8080
        server_name: "web3.magedu.com"
        root: "/var/www/nginx/web3/"
  tasks:
    - name: template config to
      template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf

// templates/nginx.conf.j2
{% for vhost in nginx_vhosts %}
server {
listen {{ vhost.listen }}
{% if vhost.server_name is defined %}
server_name {{ vhost.server_name }}
{% endif %}
root {{ vhost.root }}
}
{% endfor %}

#生成的结果

server {
listen 8080
root /var/www/nginx/web1/
}
server {
listen 8080
server_name web2.magedu.com
root /var/www/nginx/web2/
}
server {
listen 8080
server_name web3.magedu.com
root /var/www/nginx/web3/
}
```

# 条件测试:
>如果需要根据变量、facts或此前任务的执行结果来做为某task执行与否的前提时要用到条件测试,通过when语句实现，在task中使用，jinja2的语法格式

when语句: 在task后添加when子句即可使用条件测试；when语句支持Jinja2表达式语法

示例1：when条件判断
```yml
- hosts: 192.168.99.101
  tasks:
    - name: "shutdown RedHat flavored systems"
      command: /sbin/shutdown -h now
      when: ansible_os_family == "RedHat"
```

示例2：when条件判断
```yml
- hosts: websrvs
  remote_user: root
  tasks:
    - name: add group nginx
      tags: user
      user: name=nginx state=present
    - name: add user nginx
      user: name=nginx state=present group=nginx
    - name: Install Nginx
      yum: name=nginx state=present
    - name: restart Nginx
      service: name=nginx state=restarted
      when: ansible_distribution_major_version == "6"
```

示例3：when条件判断
```yml
- hosts: 192.168.99.101
  tasks:
    - name: install conf file to centos7
      template: src=nginx.conf.c7.j2 dest=/etc/nginx/nginx.conf
      when: ansible_distribution_major_version == "7"
    - name: install conf file to centos6
      template: src=nginx.conf.c6.j2 dest=/etc/nginx/nginx.conf
      when: ansible_distribution_major_version == "6"
```


# 迭代：with_items

>迭代：当有需要重复性执行的任务时，可以使用迭代机制
对迭代项的引用，固定变量名为"item"
要在task中使用with_items给定要迭代的元素列表

列表格式：字符串、字典


示例1：with_items
```yml
- hosts: all
  tasks:
    - name: add several users
      user: name={{ item }} state=present groups=wheel
      with_items:
        - testuser1
        - testuser2

#上面语句的功能等同于下面的语句：
- hosts: all
  tasks:
    - name: add user testuser1
      user: name=testuser1 state=present groups=wheel
    - name: add user testuser2
      user: name=testuser2 state=present groups=wheel
```


示例2：将多个文件进行copy到被控端
```yml
---
- hosts: testsrv
  remote_user: root
  tasks:
    - name: Create rsyncd config 
      copy: src={{ item }} dest=/etc/{{ item }} 
      with_items: 
        - rsyncd.secrets 
        - rsyncd.conf
```

示例3：迭代
```yml
- hosts: websrvs
  remote_user: root
  tasks:
    - name: copy file
      copy: src={{ item }} dest=/tmp/{{ item }}
      with_items:
        - file1
        - file2
        - file3
    - name: yum install httpd
      yum: name={{ item }} state=present
      with_items:
        - apr
        - apr-util
        - httpd
```

示例4：迭代
```yml
- hosts：websrvs
  remote_user: root
  tasks
    - name: install some packages
      yum: name={{ item }} state=present
      with_items:
        - nginx
        - memcached
        - php-fpm
```

示例5：多变量迭代
```yml
- hosts：websrvs
  remote_user: root
  tasks:
    - name: add some groups
      group: name={{ item }} state=present
      with_items:
        - group1
        - group2
        - group3
    - name: add some users
      user: name={{ item.name }} group={{ item.group }} state=present
      with_items:
        - { name: 'user1', group: 'group1' }
        - { name: 'user2', group: 'group2' }
        - { name: 'user3', group: 'group3' }
```
