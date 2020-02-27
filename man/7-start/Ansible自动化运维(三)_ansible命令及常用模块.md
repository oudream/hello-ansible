# ansible命令
ansible通过ssh实现配置管理、应用部署、任务执行等功能，建议配置ansible端能基于密钥认证的方式联系各被管理节点

`ansible <host-pattern> [-m module_name] [-a args]`

选项| 意义
-|-
`--version` |显示版本
`-m module` |指定模块，默认为command
`-v` |详细过程 
`–vv -vvv`|更详细
`--list-hosts` |显示主机列表，可简写 --list
`-k, --ask-pass` |提示输入ssh连接密码，默认Key验证
`-C, --check` |检查，并不执行
`-T, --timeout=TIMEOUT `|执行命令的超时时间，默认10s
`-u, --user=REMOTE_USER` |执行远程执行的用户
`-b, --become `|代替旧版的sudo 切换
`--become-user=USERNAME` |指定sudo的runas用户，默认为root
`-K, --ask-become-pass` |提示输入sudo时的口令


**`<Host-pattern> ` 匹配主机的列表**
`<Host-pattern>` | 意义 | 例子
-|-|-
`All `| 表示所有Inventory中的所有主机|`ansible all –m ping`
`*` |通配符|`ansible "*" -m ping`<br>`ansible 192.168.1.* -m ping`<br>`ansible "*srvs" -m ping`
`:` | 或关系 |`ansible "websrvs:appsrvs" -m ping`<br>`ansible "192.168.1.10:192.168.1.20" -m ping`<br>`ansible的Host-pattern`
`:&` | 逻辑与|`ansible "websrvs:&dbsrvs" –m ping`<p>在websrvs组并且在dbsrvs组中的主机
`:!` | 逻辑非 | `ansible 'websrvs:!dbsrvs' –m ping`<p>在websrvs组，但不在dbsrvs组中的主机<p>注意：此处为单引号
||正则表达式|`ansible "websrvs:&dbsrvs" –m ping`<p>`ansible "~(web|db).*\.magedu\.com" –m ping`

## ansible命令执行过程
1. 加载自己的配置文件 默认/etc/ansible/ansible.cfg
2. 加载自己对应的模块文件，如command
3. 通过ansible将模块或命令生成对应的临时py文件，并将该文件传输至远程服务器的对应执行用户`$HOME/.ansible/tmp/ansible-tmp-数字/XXX.PY`文件
4. 给文件`+x`执行
5. 执行并返回结果
6. 删除临时py文件，退出

### 执行状态：
<font color=#00ff00>绿色：</font>执行成功并且不需要做改变的操作
<font color=#ffff00>黄色：</font>执行成功并且对目标主机做变更
<font color=#ff0000>红色：</font>执行失败

### ansible使用示例
1. 以wang用户执行ping存活检测
```bash
ansible all -m ping -u wang -k
```
2. 以wang sudo至root执行ping存活检测
```bash
ansible all -m ping -u wang -k -b
```
3. 以wang sudo至mage用户执行ping存活检测
```bash
ansible all -m ping -u wang -k -b --become-user=mage
```
4. 以wang sudo至root用户执行ls
```bash
ansible all -m command -u wang -a 'ls /root' -b --become-user=root -k -K
```

## ansible常用模块
1. Command：在远程主机执行命令，默认模块，可忽略-m选项
```bash
ansible srvs -m command -a 'service vsftpd start'
ansible srvs -m command -a 'echo magedu |passwd --stdin wang'
#此命令不支持 $VARNAME < > | ; & 等，用shell模块实现
```

2. Shell：和command相似，用shell执行命令
```bash
ansible srv -m shell -a 'echo magedu |passwd –stdin wang'

#调用bash执行命令 
#类似 cat /tmp/stanley.md | awk -F'|' '{print $1,$2}' &> /tmp/example.txt 这些复杂命令，
#即使使用shell也可能会失败，
#解决办法：写到脚本，copy到远程，执行，再把需要的结果拉回执行命令的机器
```

3. Script：在远程主机上运行ansible服务器上的脚本
```bash
ansible websrvs -m script -a /data/f1.sh
```

4. Copy：从主控端复制文件到远程主机
```bash
ansible srv -m copy -a "src=/root/f1.sh dest=/tmp/f2.sh owner=wang mode=600 backup=yes"
#如目标存在，默认覆盖，此处指定先备份

ansible srv -m copy -a "content='test content\n' dest=/tmp/f1.txt" 
#指定内容，直接生成目标文件
```

5. Fetch：从远程主机提取文件至主控端，copy相反，目前不支持目录
```bash
ansible srv -m fetch -a 'src=/root/a.sh dest=/data/scripts'
```

6. File：设置文件属性
```bash
ansible srv -m file -a "path=/root/a.sh owner=wang mode=755"
ansible web -m file -a 'src=/app/testfile dest=/app/testfile-link state=link'
```

7. unarchive：解包解压缩，有两种用法：
    + 将ansible主机上的压缩包在本地解压缩后传到远程主机上，设置copy=yes
    + 将远程主机上的某个压缩包解压缩到指定路径下，设置copy=no
    + 常见参数：
    `copy`：默认为yes，当copy=yes，拷贝的文件是从ansible主机复制到远程主机上，如果设置为copy=no，会在远程主机上寻找src源文件
    `src`：源路径，可以是ansible主机上的路径，也可以是远程主机上的路径，如果是远程主机上的路径，则需要设置copy=no
    `dest`：远程主机上的目标路径
    `mode`：设置解压缩后的文件权限

示例：
```bash
ansible srv -m unarchive -a 'src=foo.tgz dest=/var/lib/foo'
ansible srv -m unarchive -a 'src=/tmp/foo.zip dest=/data copy=no mode=0777'
ansible srv -m unarchive -a 'src=https://example.com/example.zip dest=/data copy=no'
```

8. Archive：打包压缩
```bash
ansible all -m archive -a 'path=/etc/sysconfig dest=/data/sysconfig.tar.bz2 format=bz2 owner=wang mode=0777'
```

9. Hostname：管理主机名
```bash
ansible node1 -m hostname -a "name=websrv"
```

10. Cron：计划任务
支持时间：minute，hour，day，month，weekday
```bash
#创建任务
ansible srv -m cron -a "minute=*/5 job='/usr/sbin/ntpdate 172.16.0.1 &>/dev/null' name=Synctime"

#删除任务
ansible srv -m cron -a 'state=absent name=Synctime'
```

11. Yum：管理包
```bash
#安装
ansible srv -m yum -a 'name=httpd state=present'

#删除
ansible srv -m yum -a 'name=httpd state=absent'
```

12. Service：管理服务
```bash
ansible srv -m service -a 'name=httpd state=stopped'
#开机启动
ansible srv -m service -a 'name=httpd state=started enabled=yes'
ansible srv -m service -a 'name=httpd state=reloaded'
ansible srv -m service -a 'name=httpd state=restarted'
```

13. User：管理用户
```bash
ansible srv -m user -a 'name=user1 comment="test user" uid=2048 home=/app/user1 group=root'
ansible srv -m user -a 'name=sysuser1 system=yes home=/app/sysuser1 '
ansible srv -m user -a 'name=user1 state=absent remove=yes'
#删除用户及家目录等数据
```

14. Group：管理组
```bash
#添加组
ansible srv -m group -a "name=testgroup system=yes"
#删除组
ansible srv -m group -a "name=testgroup state=absent"
```


## ansible系列命令
**1. ansible-galaxy**
（1）连接 https://galaxy.ansible.com 下载相应的roles

（2）列出所有已安装的galaxy
```bash
ansible-galaxy list
```

（3）安装galaxy
```bash
ansible-galaxy install geerlingguy.ntp
```

（4）删除galaxy
```bash
ansible-galaxy remove geerlingguy.ntp
```

**2. ansible-pull**
推送命令至远程，效率无限提升，对运维要求较高

**3. ansible-playbook**
执行playbook
示例：`ansible-playbook hello.yml`
```yaml
cat hello.yml
#hello world yml file
- hosts: websrvs
remote_user: root
tasks:
- name: hello world
command: /usr/bin/wall hello world
```

**4. ansible-vault**
功能：管理加密解密yml文件
```bash
ansible-vault encrypt hello.yml    #加密
ansible-vault decrypt hello.yml    #解密
ansible-vault view hello.yml    #查看
ansible-vault edit hello.yml   #编辑加密文件
ansible-vault rekey hello.yml  #修改口令
ansible-vault create new.yml   #创建新文件
```

**5. Ansible-console**
```bash
[101]$ ansible-console

root@test (2)[f:10] $
#执行用户@当前操作的主机组 (当前组的主机数量)[f:并发数]$
```

1. 设置并发数： forks n 例如： `forks 10`
2. 切换组： cd 主机组 例如： `cd web`
3. 列出当前组主机列表： `list`
4. 列出所有的内置命令：`?`或`help`

5. 示例：
```bash
root@all (2)[f:5]$ list
root@all (2)[f:5]$ cd appsrvs
root@appsrvs (2)[f:5]$ list
root@appsrvs (2)[f:5]$ yum name=httpd state=present
root@appsrvs (2)[f:5]$ service name=httpd state=started
```