#!/usr/bin/env bash

open https://docs.ansible.com/ansible/latest/modules/command_module.html

# shell vs. command
# 1, command 模块命令将不会使用 shell 执行. 因此, 像 $HOME 这样的变量是不可用的。还有像<, >, |, ;, &都将不可用。
# 2, shell 模块通过shell程序执行， 默认是/bin/sh, <, >, |, ;, & 可用。但这样有潜在的 shell 注入风险， 后面会详谈.
# 3, command 模块更安全，因为他不受用户环境的影响。 也很大的避免了潜在的 shell 注入风险.
