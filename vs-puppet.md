
[from](https://blog.csdn.net/wn_hello/article/details/52130573)

工具	        语言	    架构	            协议
Puppet	    Ruby	C/S	            HTTP
Chef	    Ruby	C/S	            HTTP
Ansible	    Python	无Client	    SSH
Saltstack	Python	C/S(可无Client)	SSH/ZMQ/RAET


### 一、ansible安装配置步骤（CentOS）
- 1、设置EPEL仓库
```
检查是否已安装python2.5以上版本。
在http://dl.fedoraproject.org上安装升级对应版本的rpm包。
```

- 2、使用yum安装ansible
```bash
yum install ansible
```

- 3、设置ssh密钥
```
在ansible服务器端执行ssh-keygen生成密钥，将公钥复制到客户端。（可选）
在inventory文件中定义客户端信息，然后使用ping模块进行测试连接。
```

### 二、puppet安装配置步骤（CentOS）
- 1、设置EPEL仓库
```
预安装ruby、ruby-libs、ruby-shadow。
在http://dowbkowad.fedora.rethat.com上安装升级对应版本的rpm包。
```

- 2、使用yum安装puppet
```
在服务器端，yum安装puppet和puppet-server。
在客户端，yum安装puppet。
```

- 3、配置master和agent
```
在master和agent端分别配置puppet.conf。
agent端发送认证给master，master端sign后，才能对agent进行操作。
```

### 三、ansible和puppet比较
- 1、服务器端：
    - puppet：至少包含一个或多个puppetmaster服务器，每个客户端安装agent包。
    - ansible：不需要master和agent，只需要一个节点列表（inventory），允许使用SSH，就可以连接各个节点。

- 2、拉取/推送模式（pull/push）：
    - puppet：客户端会定期向服务器端确认，接收或者”拉取”需要被应用的配置。
    - ansible：通过ssh协议将命令发送到远程主机，客户端除了python以外不需要安装其他东西。

- 3、模块：
    - puppet：使用一些比较基本的组件(资源、类、定义、文件、模板等)自己组合成模块。
    - ansible：在安装时，包含了扩展的自动化模块。

- 4、使用语言：
    - puppet：基于Ruby搭建，语法格式采用基于Ruby的DSL语言（puppet自己的语言），template模板采用Ruby的ERB。
    - ansible：基于python搭建，语法格式采用YAML格式，模板采用Jinja2语言。

- 5、DevOps工具支持：
    - 都非常好的支持开发运维工具，比如Vagrant, Packer, and Jenkins。

- 6、依赖关系：
    - puppet：puppet 的manifest中定义的资源在执行时，不是按照顺序依次执行的，是按照任意顺序执行的，除非明确使用了before、require等关键字或者定义依赖关系。
    - ansible：ansible的playbook按照定义的顺序，依次执行。


