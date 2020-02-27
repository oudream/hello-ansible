#!/usr/bin/env bash

# ansible-galaxy - Perform various Role and Collection related operations.

ansible-galaxy [-h] [--version] [-v] TYPE ...

#DESCRIPTION
#       command  to  manage  Ansible roles in shared repositories, the default of which is Ansible Galaxy https://galaxy.ansi‐
#       ble.com.
#
#COMMON OPTIONS
   --version
      # show program's version number, config file location, configured module search  path,  module  location,  executable
      # location and exit

   -h, --help
      # show this help message and exit

   -v, --verbose
      # verbose mode (-vvv for more, -vvvv to enable connection debugging)

#ACTIONS
#       collection
#              Perform the action on an Ansible Galaxy collection. Must be combined with a further action like init/install as
#              listed below.
#
#       role   Perform the action on an Ansible Galaxy role. Must be combined with a further action  like  delete/install/init
#              as listed below.
#
#ENVIRONMENT
#       The following environment variables may be specified.
#
#       ANSIBLE_CONFIG -- Specify override location for the ansible config file
#
#       Many more are available for most options in ansible.cfg
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