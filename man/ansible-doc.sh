#!/usr/bin/env bash

open https://docs.ansible.com/ansible/latest/cli/ansible-doc.html


ansible-doc ping


ansible-doc [-h] [--version] [-v] [-M MODULE_PATH]
                [--playbook-dir BASEDIR]
                [-t {become,cache,callback,cliconf,connection,httpapi,inventory,lookup,netconf,shell,module,strategy,vars}]
                [-j] [-F | -l | -s | --metadata-dump]
                [plugin [plugin ...]]
# Description
# displays information on modules installed in Ansible libraries. It displays a terse listing of plugins and their short descriptions, provides a printout of their DOCUMENTATION strings, and it can create a short “snippet” which can be pasted into a playbook.

# Common Options
--metadata-dump
# For internal testing only Dump json metadata for all plugins.

--playbook-dir <BASEDIR>
# Since this tool does not use playbooks, use this as a substitute playbook directory.This sets the relative path for many features including roles/ group_vars/ etc.

--version
# show program’s version number, config file location, configured module search path, module location, executable location and exit

-F, --list_files
# Show plugin names and their source files without summaries (implies –list)

-M, --module-path
# prepend colon-separated path(s) to module library (default=~/.ansible/plugins/modules:/usr/share/ansible/plugins/modules)

-h, --help
# show this help message and exit

-j, --json
# Change output into json format.

-l, --list
# List available plugins

-s, --snippet
# Show playbook snippet for specified plugin(s)

-t <TYPE>, --type <TYPE>
# Choose which plugin type (defaults to “module”). Available plugin types are : (‘become’, ‘cache’, ‘callback’, ‘cliconf’, ‘connection’, ‘httpapi’, ‘inventory’, ‘lookup’, ‘netconf’, ‘shell’, ‘module’, ‘strategy’, ‘vars’)

-v, --verbose
# verbose mode (-vvv for more, -vvvv to enable connection debugging)

##    Environment
##    The following environment variables may be specified.
##    ANSIBLE_CONFIG – Override the default ansible config file
##    Many more are available for most options in ansible.cfg
##    Files
/etc/ansible/ansible.cfg # – Config file, used if present
~/.ansible.cfg           # – User config file, overrides the default config if present

