在 ansibleplaybook 中，可以通过 JinJa2 可以生成多虚拟主机配置

## 目标配置
在实际使用中，需要通过 jinja2 模板生成多虚拟主机配置，希望最后可以生成下面配置

- apache

```
<VirtualHost *:80>
    ServerAdmin admin@czero000.com
    DocumentRoot "/data/htdocs/www.czero000.com
    ServerName www.czero000.com
    ErrorLog "logs/www.czero000.com-error_log"
    CustomLog "|/usr/local/apache/bin/rotatelogs -l /usr/local/apache/logs/www.czero000.com-access_%Y%m%d_log 86400" combined
<Directory "/data/htdocs/www.czero000.com">
        DirectoryIndex index.html index.php
        Options FollowSymLinks
        AllowOverride None
        Order allow,deny
        Allow from all
</Directory>
</VirtualHost>
```
- nginx

```
server {
        listen 80 default_server;
        server_name  www.czero000.com
        root /home/website/www.czero000.com;
        index index.html;
    location / {
          try_files $uri $uri/ /index.php?$args;
    }
    location ~ .*\.(php)?$ {
        expires 1s;
        try_files $uri = 404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        include fastcgi_params;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass 127.0.0.1:9000;
    }


        access_log logs/www.czero000.com_access.log access;
        error_log logs/www.czero000.com_error.log;
}
```

## 初始化 role
通过 ansible-galaxy 生成playbook目录

### Apache

- 添加变量
```
# Vhost
VhostDomain:
  - domain: 'www.czero000.com'
    ServerName: 'www.czero000.com'
    DocumentRoot: '/home/website/www.czero000.com'
```

- 编写 jinja2 模板
```
{% for vhost in VhostDomain %}
<VirtualHost *:80>
    ServerAdmin admin.czero000.com
    DocumentRoot {{ vhost.DocumentRoot }}
    ServerName {{ vhost.ServerName }}
    ErrorLog "logs/{{ vhost.ServerName }}-error_log"
    CustomLog "|/usr/local/apache/bin/rotatelogs -l /usr/local/apache/logs/{{ vhost.ServerName }}_%Y%m%d_log 86400" combined
<Directory "{{ vhost.DocumentRoot }}">
        DirectoryIndex index.html index.php
        Options FollowSymLinks
        AllowOverride None
        Order allow,deny
        Allow from all
</Directory>
</VirtualHost>
{% endfor %}
```
- 编写 task 文件

```
---
- name: Copy Vhost Config Files
  template: src=vhost.conf.j2 dest=/usr/local/apache/conf/vhost/{{ item.domain }}.conf owner=root group=root mode=0644
  with_items: "{{ VhostDomain }}"
  #notify: Restart Apache.Service
```

- 编写总调度文件，执行 playbook

```
cat apache_conf.yml
- name: Dynamic Create Vhost Conf
  hosts: localhost
  gather_facts: no
  roles:
    - apache_conf

// 执行 playbook 生成配置文件
ansible-playbook  apache_conf.yml   
```


### Nginx

- 添加变量

在 default/main.yml 中添加变量
```
# Vhost
VhostDomain:
  - domain: 'www.czero000.com'
    listen: '80 default_server'
    root: '/home/website/www.czero000.com'
    server_name: 'www.czero000.com'
    index: 'index.html'

Vhost_Location: |
    location / {
              try_files $uri $uri/ /index.php?$args;
        }
        location ~ .*\.(php)?$ {
            expires 1s;
            try_files $uri = 404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            include fastcgi_params;
            fastcgi_param PATH_INFO $fastcgi_path_info;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_pass 127.0.0.1:9000;
        }
```

- 编写 jinja2 模板

```
{% for vhost in VhostDomain %}
server {
        listen {{ vhost.listen | default('80 default_server') }};
{% if vhost.server_name is defined %}
        server_name  {{ vhost.server_name }}
{% endif %}
{% if vhost.root is defined %}
        root {{ vhost.root }};
{% endif %}
{% if vhost.index is defined %}
        index {{ vhost.index }};
{% endif%}

{% if Vhost_Location is defined %}
    {{ Vhost_Location}}
{% endif%}
{% if vhost.server_name is defined %}                                                                                                                                   
        access_log logs/{{ vhost.server_name }}_access.log access;
        error_log logs/{{ vhost.server_name }}_error.log;
{% endif %}
}
{% endfor %}
```

- 编写 task 文件

```
---
- name: Copy Vhost Config Files
  template: src=vhost.conf.j2 dest=/usr/local/nginx/conf/vhost/{{ item.domain }}.conf owner=root group=root mode=0644
  with_items: "{{ VhostDomain }}"
  #notify: Restart Nginx.Service
```

- 编写总调度文件，执行 playbook
```
cat ngingx_conf.yml
- name: Dynamic Create Vhost Conf
  hosts: localhost
  gather_facts: no
  roles:
    - nginx_conf

// 执行 playbook 生成配置文件
ansible-playbook  ngingx_conf.yml   
```
