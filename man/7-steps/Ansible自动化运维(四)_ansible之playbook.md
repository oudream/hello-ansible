# playbook
>playbook是由一个或多个"play"组成的列表
>
>play的主要功能在于将预定义的一组主机，装扮成事先通过ansible中的task定义好的角色。Task实际是调用ansible的一个module，将多个play组织在一个playbook中，即可以让它们联合起来，按事先编排的机制执行预定义的动作
>
>Playbook采用YAML语言编写

**YAML介绍**

>YAML是一个可读性高的用来表达资料序列的格式。YAML参考了其他多种语言，包括：XML、C语言、Python、Perl以及电子邮件格式RFC2822等。Clark Evans在2001年在首次发表了这种语言，另外Ingy döt Net与Oren Ben-Kiki也是这语言的共同设计者
>
>YAML Ain't Markup Language，即YAML不是XML。不过，在开发的这种语言时，YAML的意思其实是："Yet Another Markup Language"（仍是一种标记语言）


## 特性
1. YAML的可读性好
2. YAML和脚本语言的交互性好
3. YAML使用实现语言的数据类型
4. YAML有一个一致的信息模型
5. YAML易于实现
6. YAML可以基于流来处理
7. YAML表达能力强，扩展性好

[更多的内容及规范参见网站：](http://www.yaml.org)


## YAML语法简介

1. 在单一档案中，可用连续三个连字号`——`区分多个档案。另外，还有选择性的连续三个点号`...`用来表示档案结尾
2. 次行开始正常写Playbook的内容，一般建议写明该Playbook的功能
3. 使用`#`号注释代码
4. 缩进必须是统一的，不能空格和tab混用
5. 缩进的级别也必须是一致的，同样的缩进代表同样的级别，程序判别配置的级别是通过缩进结合换行来实现的
6. YAML文件内容是区别大小写的，k/v的值均需大小写敏感
7. 多个k/v可同行写也可换行写，同行使用，分隔
8. v可是个字符串，也可是另一个列表
9. 一个完整的代码块功能需最少元素需包括 name 和 task
10. 一个name只能包括一个task
11. YAML文件扩展名通常为yml或yaml

## List：列表
其所有元素均使用"-"开头
示例：
```bash
# A list of tasty fruits
- Apple
- Orange
- Strawberry
- Mango
```

## Dictionary：字典
通常由多个key与value构成
示例：
```bash
---
# An employee record
name: Example Developer
job: Developer
skill: Elite
```

也可以将key:value放置于`{}`中进行表示，用`,`分隔多个`key:value`
示例：
```bash
---
# An employee record
{name: Example Developer, job: Developer, skill: Elite}
```

YAML的语法和其他高阶语言类似，并且可以简单表达清单、散列表、标量等数据结构。其结构（Structure）通过空格来展示，序列（Sequence）里的项用"-"来代表，Map里的键值对用":"分隔
示例
```bash
name: John Smith
age: 41
gender: Male
spouse:
name: Jane Smith
age: 37
gender: Female
children:
- name: Jimmy Smith
age: 17
gender: Male
- name: Jenny Smith
age 13
gender: Female
```

## Playbook核心元素
1. `hosts` 执行的远程主机列表
2. `tasks` 任务集
3. `Varniables` 内置变量或自定义变量在playbook中调用
4. `Templates` 模板，可替换模板文件中的变量并实现一些简单逻辑的文件
5. `Handlers` 和 `notity` 结合使用，由特定条件触发的操作，满足条件方才执行，否则不执行
6. `tags` 标签 指定某条任务执行，用于选择运行playbook中的部分代码。ansible具有幂等性，因此会自动跳过没有变化的部分，即便如此，有些代码为测试其确实没有发生变化的时间依然会非常地长。此时，如果确信其没有变化，就可以通过tags跳过此些代码片断
```bash
ansible-playbook –t tagsname useradd.yml
```

## playbook基础组件

**1. Hosts：**
>playbook中的每一个play的目的都是为了让特定主机以某个指定的用户身份执行任务。hosts用于指定要执行指定任务的主机，须事先定义在主机清单中

可以是如下形式：
```yml
- hosts: one.example.com
或
- hosts: one.example.com:two.example.com
或
- hosts: 192.168.1.50
或
- hosts: 192.168.1.*
或
- hosts: Websrvs:dbsrvs 或者，两个组的并集
或
- hosts: Websrvs:&dbsrvs 与，两个组的交集
或
- hosts: webservers:!phoenix 在websrvs组，但不在dbsrvs组
```


**2. remote_user:** 
>可用于Host和task中。也可以通过指定其通过sudo的方式在远程主机上执行任务，其可用于play全局或某任务；此外，甚至可以在sudo时使用sudo_user指定sudo时切换的用户
```yml
- hosts: websrvs
  remote_user: root
  tasks:
    - name: test connection
      ping:
  remote_user: magedu
  sudo: yes  #默认sudo为root
  sudo_user: wang  #sudo为wang
```


**3. task**
>play的主体部分是task list，task list中的各任务按次序逐个在hosts中指定的所有主机上执行，即在所有主机上完成第一个任务后，再开始第二个任务
>
>task的目的是使用指定的参数执行模块，而在模块参数中可以使用变量。模块执行是幂等的，这意味着多次执行是安全的，因为其结果均一致
>
>每个task都应该有其name，用于playbook的执行结果输出，建议其内容能清晰地描述任务执行步骤。如果未提供name，则action的结果将用于输出

tasks：任务列表两种格式：
(1) action: module arguments
(2) module: arguments 建议使用
注意：shell和command模块后面跟命令，而非key=value
```yml
#注意缩进2个空格
- hosts: 192.168.99.103
  remote_user: root
  tasks:
    - name: yum
      yum: name=libaio

```

**4. notify 与 handlers**
>某任务的状态在运行后为changed时，可通过"notify"通知给相应的handlers
>Handlers
是task列表，这些task与前述的task并没有本质上的不同,用于当关注的资源发生变化时，才会采取一定的操作
>
>Notify此action可用于在每个play的最后被触发，这样可避免多次有改变发生时每次都执行指定的操作，仅在所有的变化发生完成后一次性地执行指定操作。在notify中列出的操作称为handler，也即notify中调用handler中定义的操作

示例1
```yaml
- hosts: websrvs 
  remote_user: root 
  tasks: 
    - name: Install httpd 
      yum: name=httpd state=present 
    - name: Install configure file 
      copy: src=files/httpd.conf dest=/etc/httpd/conf/ 
      notify: restart httpd
    - name: ensure apache is running
      service: name=httpd state=started enabled=yes
  handlers:
    - name: restart httpd
      service: name=httpd state=restarted
```

示例2
```yaml
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
    - name: config
      copy: src=/root/config.txt dest=/etc/nginx/nginx.conf
      notify:
        - Restart Nginx
        - Check Nginx Process
  handlers:
    - name: Restart Nginx
      service: name=nginx state=restarted enabled=yes
    - name: Check Nginx process
      shell: killall -0 nginx > /tmp/nginx.log
```
示例3
```yml
#注意缩进2个空格
- hosts: 192.168.99.103
  remote_user: root
  tasks:
    - name: yum
      yum: name=libaio
      notify: 
        - 你的名字1   #要和下面handlers下的name相同
        - 你的名字2
  handlers: 
    - name: 你的名字1
      service: name=httpd state=restarted
    - name: 你的名字2
      service: name=httpd state=restarted
```

**5. tags**

任务可以通过"tags"打标签，可在ansible-playbook命令上使用-t指定进行调用
示例1：
```yml
tasks:
  - name: disable selinux
    command: /sbin/setenforce 0
```

示例2：httpd.yml
```yml
[centos]$ vim  httpd.yml
- hosts: websrvs 
  remote_user: root 
  tasks: 
    - name: Install httpd 
      yum: name=httpd state=present 
    - name: Install configure file 
      copy: src=files/httpd.conf dest=/etc/httpd/conf/ tags: conf 
    - name: start httpd service 
      tags: service 
      service: name=httpd state=started enabled=yes
```

**执行**

```bash
[centos]$ ansible-playbook –t conf httpd.yml
```

如果命令或脚本的退出码不为零，可以使用如下方式替代
```yml
tasks:
  - name: run this command and ignore the result
    shell: /usr/bin/somecommand || /bin/true
```
或者使用ignore_errors来忽略错误信息
```yml
tasks:
  - name: run this command and ignore the result
    shell: /usr/bin/somecommand
    ignore_errors: True
```

## 运行playbook的方式
`ansible-playbook <filename.yml> ... [options]`
常见选项 | 意义 
- | -
-C | 只检测可能会发生的改变，但不真正执行操作
--list-hosts| 列出运行任务的主机
--list-tags| 列出tag
--list-tasks |列出task
--limit 主机列表 |只针对主机列表中的主机执行


示例1
```bash
ansible-playbook file.yml --check 只检测
ansible-playbook file.yml
ansible-playbook file.yml --limit websrvs
```

示例2：httpd.yml
```yaml
---
- hosts: all
  remote_user: root
  tasks:
    - name: "安装Apache"
      yum: name=httpd
    - name: "复制配置文件"
      copy: src=/tmp/httpd.conf dest=/etc/httpd/conf/
    - name: "复制配置文件"
      copy: src=/tmp/vhosts.conf dest=/etc/httpd/conf.cd/
    - name: "启动Apache，并设置开机启动"
      service: name=httpd state=started enabled=yes
```

示例3：httpd.yml
```yml
- hosts: websrvs 
  remote_user: root
  tasks: 
    - name: Install httpd 
      yum: name=httpd state=present 
    - name: Install configure file 
      copy: src=files/httpd.conf dest=/etc/httpd/conf/
    - name: start service
      service: name=httpd state=started enabled=yes
```
