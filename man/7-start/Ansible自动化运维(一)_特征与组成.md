# 运维自动化之ANSIBLE

## 云计算运维工程师核心职能
**平台架构组建**
>负责参与并审核架构设计的合理性和可运维性，搭建运维平台技术架构，通过开源解决方案，以确保在产品发布之后能高效稳定的运行，保障并不断提升服务的可用性，确保用户数据安全，提升用户体验。

**日常运营保障**
>负责用运维技术或者运维平台确保产品可以高效的发布上线，负责保障产品7*24H稳定运行，在此期间对出现的各种问题可以快速定位并解决；在日常工作中不断优化系统架构和部署的合理性，以提升系统服务的稳定性。

**性能、效率优化**
>用自动化的工具/平台提升软件在研发生命周期中的工程效率。不断优化系统架构、提升部署效率、优化资源利用率支持产品的不断迭代，需要不断的进行架构优化调整。以确保整个产品能够在功能不断丰富和复杂的条件下，同时保持高可用性。


**Linux运维工程师职能划分**
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711195236956.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly90aHNvbi5ibG9nLmNzZG4ubmV0,size_16,color_FFFFFF,t_70)


## 企业实际应用场景分析
1. Dev开发环境
>**使用者**：程序员
**功能**：程序员开发软件，测试BUG的环境
**管理者**：程序员

2. 测试环境
>**使用者**：QA测试工程师
**功能**：测试经过Dev环境测试通过的软件的功能
**管理者**：运维
>
>说明：测试环境往往有多套,测试环境满足测试功能即可，不宜过多
1、测试人员希望测试环境有多套,公司的产品多产品线并发，即多个版本，意味着多个版本同步测试
2、通常测试环境有多少套和产品线数量保持一样

3. 发布环境：代码发布机，有些公司为堡垒机（安全屏障）
>**使用者**：运维
**功能**：发布代码至生产环境
**管理者**：运维（有经验）
**发布机**：往往需要有2台（主备）

4. 生产环境
>**使用者**：运维，少数情况开放权限给核心开发人员，极少数公司将权限完全开放给开发人员并其维护
**功能**：对用户提供公司产品的服务
**管理者**：只能是运维
**生产环境服务器数量**：一般比较多，且应用非常重要。往往需要自动工具协助部署配置应用

5. 灰度环境（生产环境的一部分）
>**使用者**：运维
**功能**：在全量发布代码前将代码的功能面向少量精准用户发布的环境,可基于主机或用户执行灰度发布
**案例**：共100台生产服务器，先发布其中的10台服务器，这10台服务器就是灰度服务器
**管理者**：运维
**灰度环境**：往往该版本功能变更较大，为保险起见特意先让一部分用户优化体验该功能，待这部分用户使用没有重大问题的时候，再全量发布至所有服务器


## 程序发布

1. 程序发布要求：
不能导致系统故障或造成系统完全不可用
不能影响用户体验

2. 预发布验证：
新版本的代码先发布到服务器（跟线上环境配置完全相同，只是未接入到调度器）

3. 灰度发布：
基于主机，用户，业务

4. 发布路径：
/webapp/tuangou
/webapp/tuangou1-1.1

5. 发布过程：
在调度器上下线一批主机(标记为maintanance状态) --> 关闭服务 --> 部署新版本的应用程序 --> 启动服务 --> 在调度器上启用这一批服务器

6. 自动化灰度发布：脚本、发布平台


### 自动化运维应用场景
1. 文件传输
2. 应用部署
3. 配置管理
4. 任务流编排


## 常用自动化运维工具
1. `Ansible`：python，Agentless，中小型应用环境
2. `Saltstack`：python，一般需部署agent，执行效率更高
3. `Puppet`：ruby, 功能强大，配置复杂，重型,适合大型环境
4. `Fabric`：python，agentless
5. `Chef`：ruby，国内应用少
6. `Cfengine`
7. `func` 


# Ansible发展史
>创始人，Michael DeHaan（ Cobbler 与 Func 的作者）
2012-03-09: 发布0.0.1版
2015-10-17: Red Hat宣布收购


**同类自动化工具GitHub关注程度**
自动化运维工具 | Watch（关注）| Star（点赞）| Fork（复制）| Contributors(贡献者)
- | - | - | - | -
Ansible | 1387 | 17716 | 5356 | 1428
Saltstack | 530 | 6678 | 3002 | 1520 
Puppet | 463 | 4044 | 1678 | 425
Chef | 383 | 4333 | 1806 | 464 
Fabric | 379 | 7334 | 1235 | 116

## Ansible特性
1. 模块化：调用特定的模块，完成特定任务
2. 有Paramiko，PyYAML，Jinja2（模板语言）三个关键模块
3. 支持自定义模块
4. 基于Python语言实现
5. 部署简单，基于python和SSH(默认已安装)，agentless
6. 安全，基于OpenSSH
7. 支持playbook编排任务
8. 幂等性：一个任务执行1遍和执行n遍效果一样，不因重复执行带来意外情况
9. 无需代理不依赖PKI（无需ssl）
10. 可使用任何编程语言写模块
11. YAML格式，编排任务，支持丰富的数据结构
12. 较强大的多层解决方案


**ansible架构**
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711200017623.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly90aHNvbi5ibG9nLmNzZG4ubmV0,size_16,color_FFFFFF,t_70)

**Ansible工作原理**
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190711200034358.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly90aHNvbi5ibG9nLmNzZG4ubmV0,size_16,color_FFFFFF,t_70)


## Ansible主要组成
1. `ANSIBLE PLAYBOOKS`：任务剧本（任务集），编排定义Ansible任务集的配置文件，由Ansible顺序依次执行，通常是JSON格式的YML文件
2. `INVENTORY`：Ansible管理主机的清单/etc/anaible/hosts
3. `MODULES`：Ansible执行命令的功能模块，多数为内置核心模块，也可自定义
4. `PLUGINS`：模块功能的补充，如连接类型插件、循环插件、变量插件、过滤插件等，该功能不常用
5. `API`：供第三方程序调用的应用程序编程接口
7. `ANSIBLE`：组合INVENTORY、API、MODULES、PLUGINS的绿框，可以理解为是ansible命令工具，其为核心执行工具


### Ansible命令执行来源：
1. USER，普通用户，即SYSTEM ADMINISTRATOR
2. CMDB（配置管理数据库） API 调用
3. PUBLIC/PRIVATE CLOUD API调用

USER--> Ansible Playbook --> Ansibile


### 利用ansible实现管理的方式：
1. ansible命令，主要用于临时命令使用场景
2. Ansible-playbook 主要用于长期规划好的，大型项目的场景，需要有前期的规划过程


## Ansible主要组成部分
1. Ansible-playbook（剧本）执行过程
    将已有编排好的任务集写入Ansible-Playbook，通过ansible-playbook命令分拆任务集至逐条ansible命令，按预定规则逐条执行
2. Ansible主要操作对象
    `HOSTS主机`或`NETWORKING网络设备`

**注意事项**
    1. 执行ansible的主机一般称为主控端，中控，master或堡垒机
    2. 主控端Python版本需要2.6或以上
    3. 被控端Python版本小于2.4需要安装python-simplejson
    4. 被控端如开启SELinux需要安装libselinux-python
    5. windows不能做为主控端

