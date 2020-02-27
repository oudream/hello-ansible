
---

### The configuration file
Changes can be made and used in a configuration file which will be searched for in the following order:

- ANSIBLE_CONFIG (environment variable if set)
- ansible.cfg (in the current directory)
- ~/.ansible.cfg (in the home directory)
- /etc/ansible/ansible.cfg


### Inventory文件
- Ansible 可同时操作属于一个组的多台主机,组和主机之间的关系通过 inventory 文件配置. 默认的文件路径为 
``
/etc/ansible/hosts
``

- 除默认文件外,你还可以同时使用多个 inventory 文件(后面会讲到),也可以从动态源,或云上拉取 inventory 配置信息.详见 [动态 Inventory](http://www.ansible.com.cn/docs/intro_dynamic_inventory.html).

---
### reference
[http://www.ansible.com.cn/docs/intro_inventory.html](http://www.ansible.com.cn/docs/intro_inventory.html)
[https://docs.ansible.com/ansible/latest/reference_appendices/config.html](https://docs.ansible.com/ansible/latest/reference_appendices/config.html)




