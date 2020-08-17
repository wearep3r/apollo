#!/usr/bin/env python3
import os
import sys
import argparse
import subprocess

try:
    import json
except ImportError:
    import simplejson as json


class ZeroInventory(object):

    def __init__(self):
        self.inventory = {}
        self.read_cli_args()

        # Called with `--list`.
        if self.args.list:
            self.inventory = self.apollo_inventory()
        # Called with `--host [hostname]`.
        elif self.args.host:
            # Not implemented, since we return _meta info `--list`.
            self.inventory = self.apollo_inventory()
        # If no groups or vars are present, return an empty inventory.
        else:
            self.inventory = self.empty_inventory()

        print(self.inventory)

    # Example inventory for testing.
    def apollo_inventory(self):
        inventory = {
            "all": {
                "hosts": []
            },
            "_meta": {
                "hostvars": {}
            }  
        }

        if0_environment = os.getenv('IF0_ENVIRONMENT', 'apollo')
        apollo_space = os.getenv('APOLLO_SPACE', if0_environment)
        zero_provider = os.getenv('ZERO_PROVIDER', 'generic')
        apollo_provider = os.getenv('APOLLO_PROVIDER', zero_provider)
        worker_os_family = os.getenv('TF_VAR_worker_os_family', 'ubuntu')

        if apollo_space:
            zero_nodes_manager = os.getenv('ZERO_NODES_MANAGER', "")
            apollo_nodes_manager = os.getenv('APOLLO_NODES_MANAGER', zero_nodes_manager)
            zero_nodes_worker = os.getenv('ZERO_NODES_WORKER', "")
            apollo_nodes_worker = os.getenv('APOLLO_NODES_WORKER', zero_nodes_worker)

            if apollo_nodes_manager and apollo_nodes_manager != "":
                inventory["manager"] = []
                i = 0
                if apollo_space == "platform":
                    i = 1
                for node in apollo_nodes_manager.split(","):
                    hostname = "manager-{}".format(i)
                    inventory['all']['hosts'].append(hostname)
                    inventory["manager"].append(hostname)
                    inventory['_meta']['hostvars'][hostname] = {
                        "vpn_ip": "10.1.0.{}/32".format(i+1),
                        "ansible_host": node,
                        "ansible_user ": "root"
                    }
                    i += 1

                    if apollo_provider == "aws":
                        inventory['_meta']['hostvars'][hostname]["ansible_user"] = "ubuntu"

            if apollo_nodes_worker and apollo_nodes_worker != "":
                inventory["worker"] = []
                i = 0
                if apollo_space == "platform":
                    i = 1
                for node in apollo_nodes_worker.split(","):
                    hostname = "worker-{}".format(i)
                    inventory['all']['hosts'].append(hostname)
                    inventory["worker"].append(hostname)
                    inventory['_meta']['hostvars'][hostname] = {
                        "vpn_ip": "10.1.1.{}/32".format(i+1),
                        "ansible_host": node,
                        "ansible_user ": "root"
                    }

                    # Fix connection parameters by provider
                    if apollo_provider == "aws" and worker_os_family == "ubuntu":
                        inventory['_meta']['hostvars'][hostname]["ansible_user"] = "ubuntu"

                    # Fix user if windows machine
                    if worker_os_family == "windows":
                        inventory['_meta']['hostvars'][hostname]["ansible_user"] = "administrator"
                        inventory['_meta']['hostvars'][hostname]["ansible_shell_type"] = "cmd"
                        inventory['_meta']['hostvars'][hostname]["ansible_become_method"] = "runas"
                        inventory['_meta']['hostvars'][hostname]["ansible_become_user"] = "Administrator"
                        

                    i += 1
            inventory = json.dumps(inventory)
        else:
            return False
    
        return inventory

    # Empty inventory for testing.
    def empty_inventory(self):
        return {'_meta': {'hostvars': {}}}

    # Read the command line args passed to the script.
    def read_cli_args(self):
        parser = argparse.ArgumentParser()
        parser.add_argument('--list', action = 'store_true')
        parser.add_argument('--host', action = 'store')
        self.args = parser.parse_args()

# Get the inventory.
ZeroInventory()