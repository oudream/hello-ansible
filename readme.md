
---
### Ansible（软件）
- Ansible是一种开源软件供应，配置管理和应用程序部署工具。[2]它可以在许多类Unix系统上运行，
并且可以配置类Unix系统以及Microsoft Windows。它包括自己的描述性语言来描述系统配置。
Ansible由Michael DeHaan编写，并于2015年被Red Hat收购。Ansible是无代理的，
可以通过SSH或远程PowerShell进行远程临时连接以执行其任务。

[wiki](https://en.wikipedia.org/wiki/Ansible_(software))

---
### 结构模式
- 推模式
- 拉模式

#### 拉模式 (puppet)
- 这种模式主张去中心化的设计思路，典型代表 puppet。一般实现多为在每个节点上部署 agent，定时获取该节点的配置信息，
根据配置信息配置本节点。如果一次配置失败了，那么下次继续尝试，直到地老天荒。这个节点完全不管其他节点的执行情况，
一心只顾做好自己的事情。

- 所以它比较适合这种场景：
- 对配置何时生效不敏感，不关心的。你知道它总是会生效的，可能是下一分钟，也可能是下个小时，但是对你没什么影响。
节点和节点之间不需要协作的。比如这种 场景就不合适： A 先升级，然后 B 在升级。即使某一次拉取信息失败了，下一次还能补上，
所以比较适合跨地域的大规模部署。


#### 推模式 (ansible)(其实ansible也支持agent的方式，即所谓的“pull”的模式)
- 推模式有一个中心节点，用于将最新的配置信息推到各个节点上，典型代表 ansible。很明显，推模式的瓶颈就在中心节点，
如果同一时间有 10000 个节点需要更新配置，那么中心节点如何稳定的工作就比较有学问。

- 它比较适合这种场景：
对配置生效的时间敏感，十分关心。必须让他们即可生效，如果不生效，立马要采取行动让他们生效。
配置生效的顺序十分关心和敏感。比如需要这10个节点一起生效，或者按照依次生效。



[man/7-steps](https://github.com/jibill/myblog)
[examples/frpaulas-iphod-ansible](https://github.com/frpaulas/iphod)
[https://github.com/welliamcao/OpsManage](https://github.com/welliamcao/OpsManage)

