#!/usr/bin/env bash


open https://docs.ansible.com/ansible/latest/user_guide/vault.html
open https://docs.ansible.com/ansible/latest/user_guide/playbooks_vault.html#playbooks-vault

# 建立加密 (Encrypted) 档案。
ansible-vault create foo.yml

# 编辑加密档案内容。
ansible-vault edit foo.yml

# 更换加密金钥 (密码)。
ansible-vault rekey foo.yml

# 对已存在的明文档案进行加密
ansible-vault encrypt foo.yml

# 解开 (Decrypt) 已加密档案。
ansible-vault decrypt foo.yml

# 检视已加密的档案内容。
ansible-vault view foo.yml

### 怎么在 Playbooks 里使用 Vault？
# 以下将借由简单的实作来展示 Playbook 搭配 Vault 的使用方法。
# 建立 Playbook。

cat >> hello_world.yml <<EOF
---
- name: say 'hello world'
 hosts: all
 vars_files:
   - defaults/main.yml
 tasks:
   - name: echo 'hello world'
     command: echo 'hello '
     register: result
   - name: print stdout
     debug:
       msg: ""
EOF

# vim: ft=ansible :
建立变数档案。

vi defaults/main.yml
world: 'ironman'
将变数档案进行加密：过程中需输入两次密码。

ansible-vault encrypt defaults/main.yml
New Vault password:
Confirm New Vault password:
Encryption successful
检视已加密的档案内容：使用刚刚输入的密码进行检视。

ansible-vault view defaults/main.yml
Vault password:
world: 'ironman'
手动输入金钥 (密码) 解密
执行 Playbook 并搭配 --ask-vault-pass 参数手动输入密码。

ansible-playbook hello_world.yml --ask-vault-pass
或通过 ansible.cfg 启用 ask_vault_pass，其预设值为 false。

设定 ansible.cfg。

vi ansible.cfg
[defaults]
ask_vault_pass = true
执行 Playbook。

ansible-playbook hello_world.yml
透过金钥 (密码) 档解密
建立密码档：此例用的密码为 bGpvxx。

echo 'bGpvxx' > secret.txt
执行 Playbook 并搭配 --vault-password-file 参数指定金钥路径。

ansible-playbook hello_world.yml --vault-password-file secret.txt
或于 ansible.cfg 里新增 vault_password_file 参数，并指定金钥路径。

vi ansible.cfg
[defaults]
vault_password_file = secret.txt


ansible-vault [-h] [--version] [-v] {create,decrypt,edit,view,encrypt,encrypt_string,rekey}


#DESCRIPTION
#       can encrypt any structured data file used by Ansible.  This can include group_vars/ or host_vars/ inventory variables,
#       variables loaded by include_vars or vars_files, or variable files passed on the ansible- playbook command line with -e
#       @file.yml or -e @file.json.  Role variables and defaults are also included!
#
#       Because Ansible tasks, handlers, and other objects are data, these can also be encrypted with vault.  If you'd like to
#       not expose what variables you are using, you can keep an individual task file entirely encrypted.
#
#COMMON OPTIONS
   --version
    #  show program's version number, config file location, configured module search  path,  module  location,  executable
    #  location and exit

   -h, --help
    #  show this help message and exit

   -v, --verbose
    #  verbose mode (-vvv for more, -vvvv to enable connection debugging)

#ACTIONS
    create 
      # create and open a file in an editor that will be encrypted with the provided vault secret when closed
    
      --ask-vault-pass
        # ask for vault password
    
      --encrypt-vault-id 'ENCRYPT_VAULT_ID'
        # the vault id used to encrypt (required if more than vault-id is provided)
    
      --vault-id
        # the vault identity to use
    
      --vault-password-file
        # vault password file
    
    decrypt
      # decrypt the supplied file using the provided vault secret
    
      --ask-vault-pass
        # ask for vault password
    
      --output 'OUTPUT_FILE'
        # output file name for encrypt or decrypt; use - for stdout
    
      --vault-id
        # the vault identity to use
    
      --vault-password-file
        # vault password file
    
    edit
      # open and decrypt an existing vaulted file in an editor, that will be encrypted again when closed
    
      --ask-vault-pass
        # ask for vault password
    
      --encrypt-vault-id 'ENCRYPT_VAULT_ID'
        # the vault id used to encrypt (required if more than vault-id is provided)
    
      --vault-id
        # the vault identity to use
    
      --vault-password-file
        # vault password file
    
    view
      # open, decrypt and view an existing vaulted file using a pager using the supplied vault secret
    
      --ask-vault-pass
        # ask for vault password
    
      --vault-id
        # the vault identity to use
    
      --vault-password-file
        # vault password file
    
    encrypt
      # encrypt the supplied file using the provided vault secret
    
      --ask-vault-pass
        # ask for vault password
    
      --encrypt-vault-id 'ENCRYPT_VAULT_ID'
        # the vault id used to encrypt (required if more than vault-id is provided)
    
      --output 'OUTPUT_FILE'
        # output file name for encrypt or decrypt; use - for stdout
    
      --vault-id
        # the vault identity to use
    
      --vault-password-file
        # vault password file
    
    encrypt_string
      # encrypt the supplied string using the provided vault secret
    
      --ask-vault-pass
        # ask for vault password
    
      --encrypt-vault-id 'ENCRYPT_VAULT_ID'
        # the vault id used to encrypt (required if more than vault-id is provided)
    
      --output 'OUTPUT_FILE'
        # output file name for encrypt or decrypt; use - for stdout
    
      --stdin-name 'ENCRYPT_STRING_STDIN_NAME'
        # Specify the variable name for stdin
    
      --vault-id
        # the vault identity to use
    
      --vault-password-file
        # vault password file
    
      -n,   --name
        # Specify the variable name
    
      -p,   --prompt
        # Prompt for the string to encrypt
    
    rekey
      # re-encrypt a vaulted file with a new secret, the previous secret is required
    
      --ask-vault-pass
        # ask for vault password
    
      --encrypt-vault-id 'ENCRYPT_VAULT_ID'
        # the vault id used to encrypt (required if more than vault-id is provided)
    
      --new-vault-id 'NEW_VAULT_ID'
        # the new vault identity to use for rekey
    
      --new-vault-password-file 'NEW_VAULT_PASSWORD_FILE'
        # new vault password file for rekey
    
      --vault-id
        # the vault identity to use
    
      --vault-password-file
        # vault password file

#ENVIRONMENT
#       The following environment variables may be specified.
#
#       ANSIBLE_CONFIG -- Specify override location for the ansible config file
#
#       Many more are available for most options in ansible.cfg
#
#       For a full list check https://docs.ansible.com/. or use the ansible-config command.
#
#FILES
#       /etc/ansible/ansible.cfg -- Config file, used if present
#
#       ~/.ansible.cfg -- User config file, overrides the default config if present
#
#       ./ansible.cfg  --  Local config file (in current working directory) assumed to be 'project specific' and overrides the
#       rest if present.
#
#       As mentioned above, the ANSIBLE_CONFIG environment variable will override all others.