# Ansible 性能优化
在使用 Ansible 过程中，当管理的服务器数量增加，就会有一个无法避免的问题--执行效率慢。下面是一些解决方法

## 优化前的准备--收集数据
在做性能优化之前首先要收集一些统计数据，这样才能为后面的性能优化提供数据支持，对比优化前后结果，这里推荐一个 Ansible 任务计时插件 `ansible-profile`， 安装这个插件之后， 会显示 ansible-playbook 执行每个任务话费的时间。项目地址: https://github.com/jlafon/ansible-profile 。
```
mkdir callback_plugins
cd callback_plugins
wget https://raw.githubusercontent.com/jlafon/ansible-profile/master/callback_plugins/profile_tasks.py
edit /etc/ansible/ansible.cfg
#callback_whitelist = timer, mail => callback_whitelist = profile_tasks
```

先在执行 ansible-playbook 既可以看到每个 tasks 的用时情况。
```
PLAY RECAP *********************************************************************
172.16.11.210              : ok=2    changed=0    unreachable=0    failed=0   
172.16.11.211              : ok=2    changed=0    unreachable=0    failed=0   

Sunday 18 September 2016  16:03:26 +0800 (0:00:00.204)       0:00:07.061 ******
===============================================================================
setup ------------------------------------------------------------------- 6.82s
print phone records ----------------------------------------------------- 0.20s
```

## 关闭 gathering facts
在执行 ansible-playbook 的过程中，ansible-playbook 第一步骤总是执行 gather_facts，不论你是否在 playbook 中定义这个 tasks。如果执行 playbook 不需要 fact 的数据，可以关闭 fact 数据功能，以加快 ansible-playbook 的执行速度。
```
// 在 playbook 中关闭 facts,只需要添加 `gather_facts: no`
---
- hosts: 172.16..11.210
  gather_facts: no
  remote_user: root
```

关闭执行继续执行上面的 playbook,效果十分明显
```
PLAY RECAP *********************************************************************
172.16.11.210              : ok=1    changed=0    unreachable=0    failed=0   
172.16.11.211              : ok=1    changed=0    unreachable=0    failed=0   

Sunday 18 September 2016  16:12:05 +0800 (0:00:00.195)       0:00:00.235 ******
===============================================================================
print phone records ----------------------------------------------------- 0.20s
```

## SSH PIPElinING
SSH PIPElinING 是一个加速 Ansible 执行速度的简单方法。SSH PIPElinING 默认是关闭的，因为要兼容不同的 sudo 配置，主要是 requiretty 选项。如果不适用 sudo 建议开启。打开此选项可以减少 ansible 执行没有传输时 ssh 在被控机器上执行任务的连接数，如果使用 sudo，必须关闭 requiretty 选项， 修改 `/etc/ansible/ansible.cfg` 开启 pipelineing
```
 pipelining=False =>   pipelining=True
```

## ControlPersist
ControlPersist 特性需要高版本的 SSH 才支持，CentOS 6 默认是不支持的，如果需要使用，需要自行升级 openssh。ControlPersist 即持久化 socket，一次验证，多次通信。并且只需要修改 ssh 客户端就行，也就是 Ansible 机器即可。
升级 openssh 的过程这里不做介绍。这里只介绍下 ControlPersist 设置的办法。
```
cat ~/.ssh/config
 Host *
  Compression yes
  ServerAliveInterval 60
  ServerAliveCountMax 5
  ControlMaster auto
  ControlPath ~/.ssh/sockets/%r@%h-%p
  ControlPersist 4h
```
在开启了 ControlPersist 特性后，SSH 在建立了 sockets 之后，节省了每次验证和创建的时间。在网络状况不是特别理想，尤其是跨互联网的情况下，所带来的性能提升是非常可观的。有这边需求的，试试就知道了。


# ansible-playbook 技巧

## 获取命令行输出
在使用 ansible-playbook 中，当使用 common 或者 shell 模块执行自定义脚本，这些脚本都会有输出，用来表示执行正常或者是失败，在 ansible-playbook 中， 可以使用 register 来存储执行命令输出结果，将结果保存到变量中，在通过访问这个变量来获取输出结果。
```
---                    
- hosts: all           
  gather_facts: no     
  tasks:               
    - name: echo date  
      command: date    
      register: date_output
    - name: echo data_output
      command: echo 30
      notify: Hello      
      when: date_output.stdout.split(' ')[2] == "18"
  handlers:            
    - name: Hello        
      debug: msg="Hello"   
```

## delegate_to 任务委派
当要在 A 组服务器上执行 playbook 时，需要同时在另外一个不在 A 组的　B 服务器上执行另外操作，这里就可以使用 delegate_to 功能，用来委派任务给 B 服务器。
```
tasks:
  - name: add host records
    shell: 'echo "172.16.11.1 api.abc.com" >> /etc/hosts'
  - name: add hosts records to center Server
    shell: ‘echo "172.16.11.1 api.abc.com" >> /etc/hosts’
    delegate_to: 172.16.11.211
```

## 本地操作功能
ansible 默认只会对定义好的被控机执行命令，如果要在本地也执行操作，可以使用 delegate_to 功能，当然还有另外一种更好的方式：`local_action`
```

// local_action
- name: add host record to center server
  local_action: shell 'echo "192.168.1.100 test.xyz.com " >> /etc/hosts'
// 当然您也可以使用 connection:local
- name: add host record to center server
  shell: 'echo "192.168.1.100 test.xyz.com " >> /etc/hosts'
```

## check 模式
使用 check 参数运行 ansible-playbook时，不会对远端主机做任何操作，并带有检测功能，报告 playbook 会对主机做出什么操作。如果 playbook 中带有执行条件，检查就会出错了。

## 使用 tag 来选择性执行
可能由于某些原因， 在一个大型的 playbook 中，只想执行其中的特定部分，这样就会用到 tag 功能。
```
- name: yun install package
  yum: name={{ item }} state=installed
  with_items:
     - httpd
     - memcached
  tags:
     - packages

- name: configuration modity
  template: src=templates/src.j2 dest=/etc/foo.conf
  tags:
      - configuration
```
如果你只想运行 playbook 中的 `configuration` 和 `packages`，你可以这样做
```
ansible-playbook example.yml -tags “configuration,packages”
```

## 错误处理
ansible 默认会检查命令和模块的返回状态，并进行相应的错误处理，默认遇到错误就会中断执行 playbook，当然这些是可以更改的

- 忽略错误

common 和 shell 模块执行的命令如果返回非零的状态码则 ansible 判断模块执行失败，通过 `ignore_errors` 忽略返回码
```
- name: this will not be counted as a filure
  command: /bin/false
  ignore_errors: true
```

- 自定义错误判定条件

命令不依赖返回状态码来判定是否执行失败，而是要查看命令返回内容来决定，比如返回内容中包括 failed 字符串，则判定为失败。示例如下：
```
- name: this command prints FAILED when it fails
  command: /usr/bin/example-command -x -y -z
  register: command_result
  failed_when: "'FAILED' in command_result.stderr"
```
ansible 会自动判断模块执行状态，command、shell 及其它模块如果修改了远程主机状态则被判定为 change 状态，不过也可以自己决定达到 changed 状态的条件，示例如下：
```
- name: copy in nginx conf
  template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf

- name: validate nginx conf
  shell: "/data/app/nginx/sbin/nginx -t"
  register: command_result
  changed_when: command_result.stdout.find('successful')
```
命令返回中有“successful”字符串，则为 changed 状态，下面这个设定将永远也不会达到 changed 状态。
```
- name: validate nginx conf
  shell: "/data/app/nginx/sbin/nginx -t"
  changed_when: false
```
