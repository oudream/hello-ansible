# Windows下Ansible工作原理
Ansible 从 1.7+ 版本开始支持 Windows，但前提是管理机必须为 Linux 系统，远程主机的通信方式也由 SSH 变更为 PowerShell，基于 Kerberos 认证方式，同时管理机必须预安装Python 的 Winrm 模块，方可和远程 Windows 主机正常通信，但 PowerShell 需 3.0+ 版本且 `Management Framework 3.0+`版本，实测 `Windows 7 SP1` 和`Windows Server 2008 R2`及以上版本系统经简单配置可正常与 Ansible 通信。简单总结如下：

- 管理机必须为 Linux系统且需预安装 Python Winrm 模块
- 底层通信基于 PowerShell，认证基于 Kerberos
- 远程主机 PowerShell 版本为3.0+，Management Framework 版本为3.0+。

如上条件满足后，方可正常和Ansible通信。

## 系统介绍
- 管理主机: 172.16.8.247 操作系统: Ubuntu16.04
- 被控主机: 172.16.11.176 操作系统: Windows2008_R2_64

## 配置管理主机

### 安装 winrm 模块
```
apt install python-pip
pip install "pywinrm>=0.1.1"
```

### 动态目录的支持

如果 windows 主机是通过 活动目录的管理方式，管理机和被管理机基于 `kerbero`认证，需要安装 `python-kerbero` 和 `MIT krb5` 依赖库

```
apt-get install python-dev libkrb5-dev
pip install Kerberos
```

配置 Kerberos，在`/etc/krb5.conf`添加下面配置
```
[realms]
 MY.DOMAIN.COM = {
  kdc = domain-controller1.my.domain.com
  kdc = domain-controller2.my.domain.com
 }
 [domain_realm]
    .my.domain.com = MY.DOMAIN.COM
```

验证域账号认证
```
kinit user@My.DOAMIN.COM
```

### 配置 inventory 主机信息和`group_vars/windows.yml`变量信息

- inventory

```
[windows]    
172.16.11.176   
```

- group_vars

```
windows.yml
ansible_ssh_user: Administrator
ansible_ssh_password: passoword                                                                                                                                
ansible_ssh_port: 5986        
ansible_connection: winrm
ansible_winrm_server_cert_validation: ignore
```
这里的 ssh_port 不是真正的SSH协议的端口

## 被控主机 (Windows2008_R2_64)

和 Linux 发版版稍有区别，远程主机为 Windows 需预先如下配置

- 安装Framework 3.0+
- 设置PowerShell本地脚本运行权限为remotesigned
- 升级PowerShell至3.0+
- 自动设置Windows远端管理，英文全称WS-Management（WinRM）

### 安装 Framework 3.0+
如果系统已经安装可以忽略

### 设置 PowerShell 本地脚本运行权限为 remotesigned
Windows 系统默认不允许非 Adminitor 外的普通用户执行 SP 脚本，即使是管理员，如下开放 SP 脚本执行权限。

- 在 cmd 中执行 regedit.exe 打开注册表，在`HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell`新建字符串值名为`ExecutionPolicy`，值为`remotesigned` **或者**，打开 PowerShell 执行命令：`set-executionpolicy -executionpolicy unrestricted`

这里共4种权限：

- Restricted—默认的设置， 不允许任何script运行；
- AllSigned—只能运行经过数字证书签名的script；
- RemoteSigned—运行本地的script不需要数字签名，但是运行从网络上下载的script就必须要有数字签名；
- Unrestricted—允许所有的script运行。

### 升级 powershell至3.0+
`PowerShell 3.0+ ``需基于`Windows 7 Sp1`安装，Windows7 系统 Sp1 补丁升级请参考 http://windows.microsoft.com/installwindows7sp1。`Window 7 和 `Windows Server 2008 R2`默认安装的有 PowerShell，但版本号一般为`2.0`版本，所以我们需升级至3.0+，如下图中数字1部分表示PowerShell版本过低需3.0+版本，数字2部分表示当前PowerShell版本为2.0

- 查询 powershell 版本
```
//在cmd中执行命令进入powershell
powershell
// 检查powershell版本
Get-Host
```

![powershell_version](http://ofc9x1ccn.bkt.clouddn.com/ansible/powershell_version.png)

- 升级 powershell

[下载](https://codeload.github.com/cchurch/ansible/zip/devel)或者[克隆](https://github.com/cchurch/ansible.git)升级脚本

选择使用 powershell 执行`ansible-devel\examples\scripts\upgrade_to_ps3` 脚本，执行后重启服务器，再次检查 powershell 版本。

![powershell_version3](http://ofc9x1ccn.bkt.clouddn.com/ansible/powershell_version3.png)

- 设置Windows远端管理（WS-Management，WinRM）

选择使用 powershell 执行`ansible-devel\examples\scripts\ConfigureRemotingForAnsible.ps1` 脚本,执行结果没有返回值即为正常。如执行出现“由于此计算机上的网络连接类型之一设置为公用，因此 WinRM 防火墙例外将不运行”类似报错，请在 PowerShell 中执行命令 Enable-PSRemoting – SkipNetworkProfileCheck –Force 尝试解决。

##  验证配置

- 验证连接

```
curl -vk -d " " -u "administrator:passowrd" https://172.16.11.176:5986/wsman
*   Trying 172.16.11.176...
* Connected to 172.16.11.176 (172.16.11.176) port 5986 (#0)
* found 173 certificates in /etc/ssl/certs/ca-certificates.crt
* found 694 certificates in /etc/ssl/certs
* ALPN, offering http/1.1
* SSL connection using TLS1.0 / RSA_AES_128_CBC_SHA1
*        server certificate verification SKIPPED
*        server certificate status verification SKIPPED
*        common name: WIN-J33CVNTPJ41 (does not match '172.16.11.176')
*        server certificate expiration date OK
*        server certificate activation date OK
*        certificate public key: RSA
*        certificate version: #3
*        subject: CN=WIN-J33CVNTPJ41
*        start date: Mon, 24 Oct 2016 22:26:13 GMT
*        expire date: Tue, 24 Oct 2017 22:26:13 GMT
*        issuer: CN=WIN-J33CVNTPJ41
*        compression: NULL
* ALPN, server did not agree to a protocol
* Server auth using Basic with user 'administrator'
> POST /wsman HTTP/1.1
> Host: 172.16.11.176:5986
> Authorization: Basic YWRtaW5pc3RyYXRvcjo4cWw2LHloWQ==
> User-Agent: curl/7.47.0
> Accept: */*
> Content-Length: 1
> Content-Type: application/x-www-form-urlencoded
>
* upload completely sent off: 1 out of 1 bytes
< HTTP/1.1 415
< Server: Microsoft-HTTPAPI/2.0
< Date: Wed, 26 Oct 2016 04:19:36 GMT
< Connection: close
< Content-Length: 0
<
* Closing connection 0
```


- 在 linux 控制主机上执行命令

```
ansible windows -m win_ping
172.16.11.176 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

```
ansible windows -m setup
172.16.11.176 | SUCCESS => {
    "ansible_facts": {
        "ansible_architecture": "64-bit",
        "ansible_date_time": {
            "date": "2016/10/25",
            "day": "25",
            "hour": "23",
            "iso8601": "2016-10-25T23:21:26",
            "minute": "21",
            "month": "10",
            "year": "2016"
        },
        "ansible_distribution": "Microsoft Windows NT 6.1.7601 Service Pack 1",
        "ansible_distribution_version": "6.1.7601.65536",
        "ansible_env": {
            "ALLUSERSPROFILE": "C:\\ProgramData",
            "APPDATA": "C:\\Users\\Administrator\\AppData\\Roaming",
            "COMPUTERNAME": "WIN-J33CVNTPJ41",
            "ComSpec": "C:\\Windows\\system32\\cmd.exe",
            "CommonProgramFiles": "C:\\Program Files\\Common Files",
            "CommonProgramFiles(x86)": "C:\\Program Files (x86)\\Common Files",
            "CommonProgramW6432": "C:\\Program Files\\Common Files",
            "FP_NO_HOST_CHECK": "NO",
            "HOMEDRIVE": "C:",
            "HOMEPATH": "\\Users\\Administrator",
            "LOCALAPPDATA": "C:\\Users\\Administrator\\AppData\\Local",
            "LOGONSERVER": "\\\\WIN-J33CVNTPJ41",
            "MODULE_COMPLEX_ARGS": "{\"_ansible_version\": \"2.1.2.0\", \"_ansible_selinux_special_fs\": [\"fuse\", \"nfs\", \"vboxsf\", \"ramfs\"], \"_ansible_no_log\": false, \"_ansible_verbosity\": 0, \"_ansible_syslog_facility\": \"LOG_USER\", \"_ansible_diff\": false, \"_ansible_debug\": false, \"_ansible_check_mode\": false}",
            "NUMBER_OF_PROCESSORS": "4",
            "OS": "Windows_NT",
            "PATHEXT": ".COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC;.CPL",
            "PROCESSOR_ARCHITECTURE": "AMD64",
            "PROCESSOR_IDENTIFIER": "Intel64 Family 6 Model 13 Stepping 3, GenuineIntel",
            "PROCESSOR_LEVEL": "6",
            "PROCESSOR_REVISION": "0d03",
            "PROMPT": "$P$G",
            "PSExecutionPolicyPreference": "Unrestricted",
            "PSModulePath": "C:\\Users\\Administrator\\Documents\\WindowsPowerShell\\Modules;C:\\Windows\\system32\\WindowsPowerShell\\v1.0\\Modules",
            "PUBLIC": "C:\\Users\\Public",
            "Path": "C:\\Windows\\system32;C:\\Windows;C:\\Windows\\System32\\Wbem;C:\\Windows\\System32\\WindowsPowerShell\\v1.0",
            "ProgramData": "C:\\ProgramData",
            "ProgramFiles": "C:\\Program Files",
            "ProgramFiles(x86)": "C:\\Program Files (x86)",
            "ProgramW6432": "C:\\Program Files",
            "SystemDrive": "C:",
            "SystemRoot": "C:\\Windows",
            "TEMP": "C:\\Users\\ADMINI~1\\AppData\\Local\\Temp",
            "TMP": "C:\\Users\\ADMINI~1\\AppData\\Local\\Temp",
            "USERDOMAIN": "WIN-J33CVNTPJ41",
            "USERNAME": "Administrator",
            "USERPROFILE": "C:\\Users\\Administrator",
            "windir": "C:\\Windows",
            "windows_tracing_flags": "3",
            "windows_tracing_logfile": "C:\\BVTBin\\Tests\\installpackage\\csilogfile.log"
        },
        "ansible_fqdn": "WIN-J33CVNTPJ41",
        "ansible_hostname": "WIN-J33CVNTPJ41",
        "ansible_interfaces": [
            {
                "default_gateway": "42.62.9.1",
                "dns_domain": null,
                "interface_index": 11,
                "interface_name": "Intel(R) PRO/1000 MT Network Connection"
            },
            {
                "default_gateway": null,
                "dns_domain": null,
                "interface_index": 12,
                "interface_name": "Intel(R) PRO/1000 MT Network Connection #2"
            }
        ],
        "ansible_ip_addresses": [
            "42.62.9.176",
            "fe80::cd71:a280:1406:de71",
            "172.16.11.176",
            "fe80::304d:48c:4d4f:67d9"
        ],
        "ansible_lastboot": "2016-10-25 22:15:20Z",
        "ansible_os_family": "Windows",
        "ansible_os_name": "Microsoft Windows Server 2008 R2 Enterprise",
        "ansible_powershell_version": 3,
        "ansible_system": "Win32NT",
        "ansible_totalmem": 8589524992,
        "ansible_uptime_seconds": 3966,
        "ansible_win_rm_certificate_expires": "2017-10-24 18:26:13"
    },
    "changed": false
}

```
## windows 下可用的模块

与 linux 系统相比， windows 下可以使用的模块就很少了，下面是常用的一些模块

- scripts,raw,slurp,setup模块在Windows 下可正常使用
- win_acl (E) —设置文件/目录属主属组权限
- win_copy—拷贝文件到远程Windows主机
- win_file —创建，删除文件或目录
- win_lineinfile—匹配替换文件内容
- win_package (E) —安装/卸载本地或网络软件包
- win_ping —Windows系统下的ping模块，常用来测试主机是否存活
- win_service—管理Windows Services服务
- win_user —管理Windows本地用户

更多模块介绍可以参考 [ansible官网模块页面](http://docs.ansible.com/ansible/list_of_windows_modules.html)

## windows ansible 模块实践

### 传输文件到指定目录

```
ansible windows -m win_copy -a 'src=/root/windows/files/helloworld.ps1 dest=C:/files/helloworld.ps1'   
172.16.11.176 | SUCCESS => {
    "changed": true,
    "checksum": "e53fa06a2ab5313165632e7c99a04af587cc6b47",
    "operation": "file_copy",
    "original_basename": "helloworld.ps1",
    "size": 112
}
```

### 删除指定文件
```
ansible windows -m win_file -a 'path=c:/files/helloworld.sp1 state=absent'
172.16.11.176 | SUCCESS => {
    "changed": false
}
```

### 执行远程脚本
```
ansible windows -m script -a '/root/windows/files/helloworld.ps1'
172.16.11.176 | SUCCESS => {
    "changed": true,
    "rc": 0,
    "stderr": "",
    "stdout": "\nHello World!\nGood-bye World! \n\n",
    "stdout_lines": [
        "",
        "Hello World!",
        "Good-bye World! ",
        ""
    ]
}
```

### 用户管理
```
ansible windows -m win_user -a 'name=Czero password=Line.kong group=Administrators'   
172.16.11.176 | SUCCESS => {
   "account_disabled": false,
   "account_locked": false,
   "changed": true,
   "description": "",
   "fullname": "Czero",
   "groups": [],
   "name": "Czero",
   "password_expired": false,
   "password_never_expires": false,
   "path": "WinNT://WORKGROUP/WIN-J33CVNTPJ41/Czero",
   "sid": "S-1-5-21-459422901-1284336649-1347501021-1002",
   "state": "present",
   "user_cannot_change_password": false
}
```

### playbook

- copy 文件

```
vim copy.yml
---                                                                   
- name: copy file on windows                                          
  hosts: windows                                                      
  tasks:                                                              
    - name: copy file on remote windows                               
      win_file: src=/root/windows/files/helloworld.ps1 dest=c:/files/helloworld.ps1

ansible-playbook copy.yml

PLAY [copy file on windows] ****************************************************

TASK [setup] *******************************************************************
Wednesday 26 October 2016  11:38:27 +0800 (0:00:00.038)       0:00:00.038 *****
ok: [172.16.11.176]

TASK [copy file on remote windows] *********************************************
Wednesday 26 October 2016  11:38:31 +0800 (0:00:04.071)       0:00:04.110 *****
ok: [172.16.11.176]

PLAY RECAP *********************************************************************

172.16.11.176              : ok=2    changed=0    unreachable=0    failed=0   
Wednesday 26 October 2016  11:38:33 +0800 (0:00:02.329)       0:00:06.439 *****
===============================================================================
setup ------------------------------------------------------------------- 4.07s
copy file on remote windows --------------------------------------------- 2.33s
```

- 执行命令

```
vim test_raw.yml
- name: test raw module  
  hosts: windows         
  tasks:                 
    - name: run ipconfig
      raw: ipconfig      
      register: ipconfig
    - debug: var=ipconfig        

ansible-playbook test_raw.yml

PLAY [test raw module] *********************************************************

TASK [setup] *******************************************************************
Wednesday 26 October 2016  11:45:30 +0800 (0:00:00.037)       0:00:00.037 *****
ok: [172.16.11.176]

TASK [run ipconfig] ************************************************************
Wednesday 26 October 2016  11:45:34 +0800 (0:00:04.076)       0:00:04.114 *****
ok: [172.16.11.176]

TASK [debug] *******************************************************************
Wednesday 26 October 2016  11:45:35 +0800 (0:00:00.688)       0:00:04.803 *****
ok: [172.16.11.176] => {
    "ipconfig": {
        "changed": false,
        "rc": 0,
        "stderr": "",
        "stdout": "\r\nWindows IP Configuration\r\n\r\n\r\nEthernet adapter �������� 2:\r\n\r\n   Connection-specific DNS Suffix  . : \r\n   Link-local IPv6 Address . . . . . : fe80::304d:48c:4d4f:67d9%12\r\n   IPv4 Address. . . . . . . . . . . : 172.16.11.176\r\n   Subnet Mask . . . . . . . . . . . : 255.255.255.0\r\n   Default Gateway . . . . . . . . . : \r\n\r\nEthernet adapter ��������:\r\n\r\n   Connection-specific DNS Suffix  . : \r\n   Link-local IPv6 Address . . . . . : fe80::cd71:a280:1406:de71%11\r\n   IPv4 Address. . . . . . . . . . . : 42.62.9.176\r\n   Subnet Mask . . . . . . . . . . . : 255.255.255.0\r\n   Default Gateway . . . . . . . . . : 42.62.9.1\r\n\r\nTunnel adapter isatap.{9ED2F327-7AD8-488B-9D74-F8E3E8B5E2B1}:\r\n\r\n   Media State . . . . . . . . . . . : Media disconnected\r\n   Connection-specific DNS Suffix  . : \r\n\r\nTunnel adapter isatap.{AB02B80C-75A3-4F59-B19B-8AE4F8103DF8}:\r\n\r\n   Media State . . . . . . . . . . . : Media disconnected\r\n   Connection-specific DNS Suffix  . : \r\n\r\nTunnel adapter 6TO4 Adapter:\r\n\r\n   Connection-specific DNS Suffix  . : \r\n   IPv6 Address. . . . . . . . . . . : 2002:2a3e:9b0::2a3e:9b0\r\n   Default Gateway . . . . . . . . . : \r\n",
        "stdout_lines": [
            "",
            "Windows IP Configuration",
            "",
            "",
            "Ethernet adapter �������� 2:",
            "",
            "   Connection-specific DNS Suffix  . : ",
            "   Link-local IPv6 Address . . . . . : fe80::304d:48c:4d4f:67d9%12",
            "   IPv4 Address. . . . . . . . . . . : 172.16.11.176",
            "   Subnet Mask . . . . . . . . . . . : 255.255.255.0",
            "   Default Gateway . . . . . . . . . : ",
            "",
            "Ethernet adapter ��������:",
            "",
            "   Connection-specific DNS Suffix  . : ",
            "   Link-local IPv6 Address . . . . . : fe80::cd71:a280:1406:de71%11",
            "   IPv4 Address. . . . . . . . . . . : 42.62.9.176",
            "   Subnet Mask . . . . . . . . . . . : 255.255.255.0",
            "   Default Gateway . . . . . . . . . : 42.62.9.1",
            "",
            "Tunnel adapter isatap.{9ED2F327-7AD8-488B-9D74-F8E3E8B5E2B1}:",
            "",
            "   Media State . . . . . . . . . . . : Media disconnected",
            "   Connection-specific DNS Suffix  . : ",
            "",
            "Tunnel adapter isatap.{AB02B80C-75A3-4F59-B19B-8AE4F8103DF8}:",
            "",
            "   Media State . . . . . . . . . . . : Media disconnected",
            "   Connection-specific DNS Suffix  . : ",
            "",
            "Tunnel adapter 6TO4 Adapter:",
            "",
            "   Connection-specific DNS Suffix  . : ",
            "   IPv6 Address. . . . . . . . . . . : 2002:2a3e:9b0::2a3e:9b0",
            "   Default Gateway . . . . . . . . . : "
        ]
    }
}

PLAY RECAP *********************************************************************
172.16.11.176              : ok=3    changed=0    unreachable=0    failed=0   

Wednesday 26 October 2016  11:45:35 +0800 (0:00:00.062)       0:00:04.866 *****
===============================================================================
setup ------------------------------------------------------------------- 4.08s
run ipconfig ------------------------------------------------------------ 0.69s
debug ------------------------------------------------------------------- 0.06s
```
