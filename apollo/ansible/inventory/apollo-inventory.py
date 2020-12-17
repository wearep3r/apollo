#!/usr/bin/env python3
import os
import argparse
import yaml

try:
    import json
except ImportError:
    import simplejson as json


class ApolloInventory(object):
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
            "all": {"hosts": ["apollo"]},
            "_meta": {
                "hostvars": {
                    "apollo": {
                        "ansible_connection": "local",
                        "ansible_python_interpreter": "/usr/bin/env python3",
                    },
                }
            },
        }

        apollo_space_dir = os.getenv("APOLLO_SPACE_DIR")
        apollo_config_version = os.getenv("APOLLO_CONFIG_VERSION")
        apollo_space = os.getenv("APOLLO_SPACE")

        # Check which SSH key to use
        custom_ssh_private_key_file = os.path.join(apollo_space_dir, ".ssh/id_rsa")
        if os.path.exists(custom_ssh_private_key_file):
            ansible_ssh_private_key_file = custom_ssh_private_key_file
        else:
            ansible_ssh_private_key_file = os.path.join(
                os.getenv("HOME", "~"), ".ssh/id_rsa"
            )

        custom_ssh_public_key_file = os.path.join(apollo_space_dir, ".ssh/id_rsa.pub")
        if os.path.exists(custom_ssh_private_key_file):
            ansible_ssh_public_key_file = custom_ssh_public_key_file
        else:
            ansible_ssh_public_key_file = os.path.join(
                os.getenv("HOME", "~"), ".ssh/id_rsa.pub"
            )

        infrastructure = {}

        if apollo_config_version == "3":
            try:
                # Find Nodesfile.yml in apollo_space_dir
                with open(os.path.join(apollo_space_dir, "Nodesfile.yml"), "r") as file:
                    # The FullLoader parameter handles the conversion from YAML
                    # scalar values to Python the dictionary format
                    infrastructure = yaml.load(file, Loader=yaml.FullLoader)

                # Update apollo
                inventory["_meta"]["hostvars"]["apollo"][
                    "apollo_ingress_ip"
                ] = infrastructure.get("ingress", {}).get("ipv4", {})
                inventory["_meta"]["hostvars"]["apollo"][
                    "apollo_management_ip"
                ] = infrastructure.get("management", {}).get("ipv4", {})

                # Create cluster group
                inventory["cluster"] = []

                inventory["manager"] = []
                i = 0
                for node in infrastructure["manager"]["nodes"]:
                    hostname = f"apollo-manager-{i}"

                    inventory["all"]["hosts"].append(hostname)
                    inventory["manager"].append(hostname)
                    inventory["cluster"].append(hostname)

                    inventory["_meta"]["hostvars"][hostname] = {
                        "vpn_ip": "10.1.0.{}/32".format(i + 1),
                        "apollo_cluster_ip": "10.1.0.{}".format(i + 1),
                        "apollo_ingress_ip": infrastructure.get("ingress", {}).get(
                            "ipv4", {}
                        ),
                        "apollo_management_ip": infrastructure.get("management", {}).get(
                            "ipv4", {}
                        ),
                        "ansible_host": node.get("ipv4"),
                        "ansible_user ": node.get("user") or "root",
                        "ansible_python_interpreter": "/usr/bin/env python3",
                        "ansible_ssh_private_key_file": ansible_ssh_private_key_file,
                        "ansible_ssh_public_key_file": ansible_ssh_public_key_file,
                    }
                    i += 1

                inventory["worker"] = []
                i = 0
                for node in infrastructure["worker"]["nodes"]:
                    hostname = f"apollo-worker-{i}"

                    inventory["all"]["hosts"].append(hostname)
                    inventory["worker"].append(hostname)
                    inventory["cluster"].append(hostname)

                    inventory["_meta"]["hostvars"][hostname] = {
                        "vpn_ip": "10.1.1.{}/32".format(i + 1),
                        "apollo_cluster_ip": "10.1.1.{}".format(i + 1),
                        "apollo_ingress_ip": infrastructure.get("ingress", {}).get(
                            "ipv4", {}
                        ),
                        "apollo_management_ip": infrastructure.get("management", {}).get(
                            "ipv4", {}
                        ),
                        "ansible_host": node.get("ipv4"),
                        "ansible_user ": node.get("user") or "root",
                        "ansible_python_interpreter": "/usr/bin/env python3",
                        "ansible_ssh_private_key_file": ansible_ssh_private_key_file,
                        "ansible_ssh_public_key_file": ansible_ssh_public_key_file,
                    }
                    i += 1
            except Exception as e:
                pass
        elif apollo_config_version == "2":
            try:
                # Find Nodesfile.yml in apollo_space_dir
                with open(apollo_space_dir + "/Nodesfile.yml", "r") as file:
                    # The FullLoader parameter handles the conversion from YAML
                    # scalar values to Python the dictionary format
                    infrastructure = yaml.load(file, Loader=yaml.FullLoader)

                # Update apollo
                inventory["_meta"]["hostvars"]["apollo"][
                    "apollo_ingress_ip"
                ] = infrastructure.get("ingress", {}).get("ipv4", {})
                inventory["_meta"]["hostvars"]["apollo"][
                    "apollo_management_ip"
                ] = infrastructure.get("management", {}).get("ipv4", {})

                # Create cluster group
                inventory["cluster"] = []

                inventory["manager"] = []
                i = 0
                for node in infrastructure["manager"]:
                    hostname = "manager-{}".format(i)
                    inventory["all"]["hosts"].append(hostname)
                    inventory["manager"].append(hostname)
                    inventory["cluster"].append(hostname)
                    inventory["_meta"]["hostvars"][hostname] = {
                        "vpn_ip": "10.1.0.{}/32".format(i + 1),
                        "apollo_cluster_ip": "10.1.0.{}".format(i + 1),
                        "apollo_ingress_ip": infrastructure.get("ingress", {}).get(
                            "ipv4", {}
                        ),
                        "apollo_management_ip": infrastructure.get("management", {}).get(
                            "ipv4", {}
                        ),
                        "ansible_host": node.get("ipv4"),
                        "ansible_user ": node.get("user") or "root",
                        "ansible_python_interpreter": "/usr/bin/env python3",
                        "ansible_ssh_private_key_file": "{}/.ssh/id_rsa".format(
                            apollo_space_dir
                        ),
                        "ansible_ssh_public_key_file": "{}/.ssh/id_rsa.pub".format(
                            apollo_space_dir
                        ),
                    }
                    i += 1

                inventory["worker"] = []
                i = 0
                for node in infrastructure["worker"]:
                    hostname = "worker-{}".format(i)
                    inventory["all"]["hosts"].append(hostname)
                    inventory["worker"].append(hostname)
                    inventory["cluster"].append(hostname)
                    inventory["_meta"]["hostvars"][hostname] = {
                        "vpn_ip": "10.1.1.{}/32".format(i + 1),
                        "apollo_cluster_ip": "10.1.1.{}".format(i + 1),
                        "apollo_ingress_ip": infrastructure.get("ingress", {}).get(
                            "ipv4", {}
                        ),
                        "apollo_management_ip": infrastructure.get("management", {}).get(
                            "ipv4", {}
                        ),
                        "ansible_host": node.get("ipv4"),
                        "ansible_user ": node.get("user") or "root",
                        "ansible_python_interpreter": "/usr/bin/env python3",
                        "ansible_ssh_private_key_file": "{}/.ssh/id_rsa".format(
                            apollo_space_dir
                        ),
                        "ansible_ssh_public_key_file": "{}/.ssh/id_rsa.pub".format(
                            apollo_space_dir
                        ),
                    }
                    i += 1
            except:
                pass
        else:
            apollo_space = os.getenv("APOLLO_SPACE", "apollo")
            apollo_provider = os.getenv("APOLLO_PROVIDER", "generic")
            worker_os_family = os.getenv("TF_VAR_worker_os_family", "ubuntu")

            # Create cluster group
            inventory["cluster"] = []

            if apollo_space:
                zero_nodes_manager = os.getenv("ZERO_NODES_MANAGER", "")
                apollo_nodes_manager = os.getenv(
                    "APOLLO_NODES_MANAGER", zero_nodes_manager
                )
                zero_nodes_worker = os.getenv("ZERO_NODES_WORKER", "")
                apollo_nodes_worker = os.getenv("APOLLO_NODES_WORKER", zero_nodes_worker)

                if apollo_nodes_manager and apollo_nodes_manager != "":
                    inventory["manager"] = []
                    i = 0
                    if apollo_space == "platform":
                        i = 1
                    for node in apollo_nodes_manager.split(","):
                        hostname = "manager-{}".format(i)
                        inventory["all"]["hosts"].append(hostname)
                        inventory["manager"].append(hostname)
                        inventory["cluster"].append(hostname)
                        inventory["_meta"]["hostvars"][hostname] = {
                            "vpn_ip": "10.1.0.{}/32".format(i + 1),
                            "apollo_cluster_ip": "10.1.0.{}".format(i + 1),
                            "ansible_host": node,
                            "ansible_user ": "root",
                        }
                        i += 1

                        if apollo_provider == "aws":
                            inventory["_meta"]["hostvars"][hostname][
                                "ansible_user"
                            ] = "ubuntu"

                if apollo_nodes_worker and apollo_nodes_worker != "":
                    inventory["worker"] = []
                    i = 0
                    if apollo_space == "platform":
                        i = 1
                    for node in apollo_nodes_worker.split(","):
                        hostname = "worker-{}".format(i)
                        inventory["all"]["hosts"].append(hostname)
                        inventory["worker"].append(hostname)
                        inventory["cluster"].append(hostname)
                        inventory["_meta"]["hostvars"][hostname] = {
                            "vpn_ip": "10.1.1.{}/32".format(i + 1),
                            "apollo_cluster_ip": "10.1.1.{}".format(i + 1),
                            "ansible_host": node,
                            "ansible_user ": "root",
                        }

                        # Fix connection parameters by provider
                        if apollo_provider == "aws" and worker_os_family == "ubuntu":
                            inventory["_meta"]["hostvars"][hostname][
                                "ansible_user"
                            ] = "ubuntu"

                        # Fix user if windows machine
                        if worker_os_family == "windows":
                            inventory["_meta"]["hostvars"][hostname][
                                "ansible_user"
                            ] = "administrator"
                            inventory["_meta"]["hostvars"][hostname][
                                "ansible_shell_type"
                            ] = "cmd"
                            inventory["_meta"]["hostvars"][hostname][
                                "ansible_become_method"
                            ] = "runas"
                            inventory["_meta"]["hostvars"][hostname][
                                "ansible_become_user"
                            ] = "Administrator"

                        i += 1
            else:
                return False
        inventory = json.dumps(inventory)
        return inventory

    # Empty inventory for testing.
    def empty_inventory(self):
        return {"_meta": {"hostvars": {}}}

    # Read the command line args passed to the script.
    def read_cli_args(self):
        parser = argparse.ArgumentParser()
        parser.add_argument("--list", action="store_true")
        parser.add_argument("--host", action="store")
        self.args = parser.parse_args()


# Get the inventory.
ApolloInventory()
