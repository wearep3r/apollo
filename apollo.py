#!/usr/bin/env python

import typer
import os
import subprocess
import yaml
import json

app = typer.Typer(help="apollo CLI")
arc = {
  "space_dir": ""
}

spacefile = {}

def loadConfig():
  spacefile = loadSpacefile()

  if spacefile:
    os.environ["APOLLO_SPACE"] = spacefile['space']['name']
    return {**arc, **spacefile}
  else:
    typer.echo(f"Can't find Spacefile.yml in {arc['space_dir']}", err=True)
    raise typer.Exit(code=1)

def loadSpacefile():
  try:
    with open(arc['space_dir']+'/Spacefile.yml','r') as file:
      spacefile = yaml.load(file, Loader=yaml.FullLoader)
      return spacefile
  except:
    return False

def loadNodesfile():
  try:
    with open(arc['space_dir']+'/Nodesfile.yml','r') as file:
      nodesfile = yaml.load(file, Loader=yaml.FullLoader)
      return nodesfile
  except:
    return False

def deployInfrastructure(arc):
  if arc['infrastructure']['provider'] != "":
    extra_vars = {
      "apollo_infrastructure_provider": arc['infrastructure']['provider']
    }

    infrastructure = subprocess.run([
      "ansible-playbook",
      "--extra-vars",
      json.dumps(extra_vars),
      "--flush-cache",
      "playbooks/cli-infrastructure.yml"
    ], cwd="/apollo")
    return infrastructure
  else:
    typer.echo(f"Spacefile.infrastructure.provider is empty. Exiting.", err=True)
    raise typer.Exit(code=1)

def destroyInfrastructure(arc):
  extra_vars = {
    "apollo_terraform_destroy": 1,
    "apollo_infrastructure_provider": arc['infrastructure']['provider']
  }

  if arc['infrastructure']['provider'] != "":
    infrastructure = subprocess.run([
      "ansible-playbook",
      "--extra-vars",
      json.dumps(extra_vars),
      "--tags",
      f"terraform_destroy",
      "--flush-cache",
      "playbooks/cli-infrastructure.yml"
    ], cwd="/apollo")
  else:
    typer.echo(f"Spacefile.infrastructure.provider is empty. Exiting.", err=True)
    raise typer.Exit(code=1)

@app.command()
def exec(where: str, what: str):
  """
  Exec command on cluster
  """
  arc = loadConfig()

  typer.echo(f"Executing {what} on {where}")

  try:
    exec = subprocess.run([
        "ansible",
        "-i", 
        "/apollo/inventory/apollo-inventory.py", 
        f"{where}", 
        "-a",
        f"{what}"
      ], cwd="/apollo")
  except Exception as e:
    typer.echo(f"Failed to execute {what} on {where}.", err=True)
    raise typer.Exit(code=1)

@app.command()
def enter(where: str):
  """
  Enter cluster node
  """
  arc = loadConfig()
  nodesfile = loadNodesfile()
  ssh_config = "-o LogLevel=ERROR -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

  if not nodesfile:
    typer.echo(f"Can't find Nodesfile.yml in {arc['space_dir']}", err=True)
    raise typer.Exit(code=1)

  nodes = {}
  
  if nodesfile['manager']:
    for manager in nodesfile['manager']:
      nodes[manager['name']] = manager

  if nodesfile['worker']:
    for worker in nodesfile['worker']:
      nodes[worker['name']] = worker

  apollo_user = nodes.get(where,{}).get('user','root')
  apollo_ipv4 = nodes.get(where,{}).get('ipv4','')
  command = "ssh {} -i {}/.ssh/id_rsa -l {} {}".format(ssh_config,arc['space_dir'],apollo_user,apollo_ipv4)

  try:
    enter = subprocess.call(command, shell=True)
  except Exception as e:
    typer.echo(f"Failed to enter {where}.", err=True)
    typer.echo(f"{command}", err=True)
    raise typer.Exit(code=1)

@app.command()
def commit():
  print("commit")

@app.command()
def push():
  print("push")

@app.command()
def deploy(what: str = typer.Argument("all")):
  """
  Deploy apollo
  """
  arc = loadConfig()
  
  if what == "infrastructure":
    if arc['infrastructure']['enabled'] == True:
      infrastructure = deployInfrastructure(arc)
      return infrastructure
    else:
      typer.echo(f"Spacefile.infrastructure.enabled is false. Exiting.", err=True)
      raise typer.Exit(code=1)
  elif what != "all":
    deployment = subprocess.run([
      "ansible-playbook",
      "--flush-cache", 
      "--tags", 
      f"{what},always", 
      "provision.yml"], cwd="/apollo")
    return deployment
  else:
    deployment = subprocess.run([
      "ansible-playbook",
      "--skip-tags",
      "provision_infrastructure",
      "--flush-cache", 
      "provision.yml"], cwd="/apollo")
    return deployment

@app.command()
def destroy():
  """
  Destroy apollo
  """
  arc = loadConfig()
  
  if arc['infrastructure']['enabled'] == True:
    infrastructure = destroyInfrastructure(arc)
  else:
    typer.echo(f"Spacefile.infrastructure.enabled is false. Exiting.", err=True)
    raise typer.Exit(code=1)

@app.command()
def show(what: str):
  arc = loadConfig()

  if what in ["inventory","nodes"]:
    inventory = json.loads(subprocess.check_output([
      "python",
      "inventory/apollo-inventory.py",
      "--list"
      ], cwd="/apollo"))
    
    typer.echo(json.dumps(inventory,sort_keys=True, indent=4))

  if what == "config":    
    typer.echo(json.dumps(arc,sort_keys=True, indent=4))

@app.command()
def check(what: str):
  """
  Check parts of the system
  """
  arc = loadConfig()

  typer.echo(f"Checking {what}")
  check = subprocess.run([
      "ansible-playbook",
      "--flush-cache", 
      "--skip-tags", 
      "provision_infrastructure", 
      "--tags", 
      f"provision_{what},always", 
      "provision.yml"], cwd="/apollo")
  return check

@app.callback()
def callback(
    verbosity: int = 0,
    space_dir: str = os.environ.get('PWD')
  ):
  os.environ["APOLLO_CONFIG_VERSION"] = "2"
  os.environ["APOLLO_SPACE_DIR"] = space_dir
  os.environ["ANSIBLE_VERBOSITY"] = str(verbosity)

  if verbosity > 0:
    os.environ["ANSIBLE_DEBUG"] = "1"

  arc['space_dir'] = space_dir
  arc['verbosity'] = verbosity


if __name__ == "__main__":
    app()