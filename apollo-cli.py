#!/usr/bin/env python

import typer
import os
import subprocess
import yaml
import json
import re
from enum import Enum
import anyconfig

app = typer.Typer(help="apollo CLI")
arc = {
  "space_dir": ""
}

spacefile = {}

# HELPER COMMANDS

class InfrastructureProviders(str, Enum):
    generic = "generic"
    hcloud = "hcloud"
    digitalocean = "digitalocean"

def checkSpaceconfig(config: dict):
  print("ss")

def checkSpaceName(name: str):
  """
  Check if spaceName matches the required syntax
  """
  pattern = re.compile("^([a-z0-9-]+)$")
  
  if pattern.match(name):
    return True
  
  return False

def checkSpaceVersion(version: str):
  """
  Check if spaceVersion matches the required syntax
  """
  pattern = re.compile("^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$")
  
  if pattern.match(version):
    return True
  
  return False

def checkSpaceBaseDomain(base_domain: str):
  """
  Check if spaceBaseDomain matches the required syntax
  """
  pattern = re.compile("^(?!:\/\/)(?=.{1,255}$)((.{1,63}\.){1,127}(?![0-9]*$)[a-z0-9-]+\.?)$")
  
  if pattern.match(base_domain):
    return True
  
  return False

def checkSpaceMail(mail: str):
  """
  Check if spaceBaseDomain matches the required syntax
  """
  pattern = re.compile("^[A-Za-z0-9\.\+_-]+@[A-Za-z0-9\._-]+\.[a-zA-Z]*$")
  
  if pattern.match(mail):
    return True
  
  return False

def loadConfig():
  spacefile = validateSpacefile()
  nodesfile = validateNodesfile()

  return spacefile,nodesfile

def loadDefaults():
  try:
    defaults = anyconfig.load(["/apollo/defaults.yml"])
    # with open('/apollo/defaults.yml','r') as file:
    #   defaults = yaml.load(file, Loader=yaml.FullLoader)
    return defaults
  except Exception as e:
    typer.secho(f"Error loading defaults.yml: {e}", err=True, bold=False, fg=typer.colors.RED)
    raise typer.Exit(code=1)

def loadSpacefile():
  try:
    spacefile = anyconfig.load(["/apollo/defaults.yml",arc['space_dir']+'/Spacefile.yml'])
    # with open(arc['space_dir']+'/Spacefile.yml','r') as file:
    #   spacefile = yaml.load(file, Loader=yaml.FullLoader)
    return spacefile
  except Exception as e:
    typer.secho(f"Error loading Spacefile.yml: {e}", err=True, bold=False, fg=typer.colors.RED)
    raise typer.Exit(code=1)

def loadNodesfile():
  try:
    nodesfile = anyconfig.load([arc['space_dir']+'/Nodesfile.yml'])
    # with open(arc['space_dir']+'/Nodesfile.yml','r') as file:
    #   nodesfile = yaml.load(file, Loader=yaml.FullLoader)
    return nodesfile
  except Exception as e:
    typer.secho(f"Error loading Nodesfile.yml: {e}", err=True, bold=False, fg=typer.colors.RED)
    raise typer.Exit(code=1)

def deployInfrastructure(spacefile):
  if spacefile['infrastructure']['provider'] not in ["generic", ""]:
    extra_vars = {
      "apollo_infrastructure_provider": spacefile['infrastructure']['provider']
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
    typer.secho(f"Infrastructure provider missing:", err=True, fg=typer.colors.RED)
    raise typer.Exit(code=1)

def destroyInfrastructure(spacefile):
  extra_vars = {
    "apollo_terraform_destroy": 1,
    "apollo_infrastructure_provider": spacefile['infrastructure']['provider']
  }

  if spacefile['infrastructure']['provider'] != "":
    infrastructure = subprocess.run([
      "ansible-playbook",
      "--extra-vars",
      json.dumps(extra_vars),
      "--tags",
      f"terraform_destroy",
      "--flush-cache",
      "playbooks/cli-infrastructure.yml"
    ], cwd="/apollo")
    return infrastructure
  else:
    typer.secho(f"Infrastructure provider missing", err=True, fg=typer.colors.RED)
    raise typer.Exit(code=1)

# APP COMMANDS

@app.command()
def exec(where: str, what: str):
  """
  Exec command on cluster
  """
  nodesfile = loadNodesfile()

  typer.secho(f"Executing {what} on {where}", fg=typer.colors.BRIGHT_BLACK)

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
    typer.secho(f"Failed to execture {what} on {where}", err=True, fg=typer.colors.RED)
    raise typer.Exit(code=1)

@app.command()
def enter(where: str):
  """
  Enter cluster node
  """
  spacefile = loadSpacefile()
  nodesfile = loadNodesfile()
  ssh_config = "-o LogLevel=ERROR -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

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
    typer.secho(f"Failed to enter {where}", err=True, fg=typer.colors.RED)

    if arc['verbosity'] > 0:
      typer.secho(f"{command}", err=False, fg=typer.colors.BRIGHT_BLACK)
    raise typer.Exit(code=1)

@app.command()
def commit(message: str):
  """
  Commit configuration changes to the space (requires git)
  """
  command = [
    "git",
    "commit",
    "-am",
    f"{message}"
  ]

  if arc['verbosity'] > 0:
    typer.secho(f"{command}", fg=typer.colors.BRIGHT_BLACK)

  commit = subprocess.run(command)
    
  return commit

@app.command()
def push():
  """
  Push configuration changes to the space repository (requires git)
  """
  command = [
    "git",
    "push"
  ]

  if arc['verbosity'] > 0:
    typer.secho(f"{command}", fg=typer.colors.BRIGHT_BLACK)

  push = subprocess.run(command)
    
  return push

@app.command()
def build():
  """
  Build apollo infrastructure
  """
  spacefile = loadSpacefile()

  if spacefile['infrastructure']['enabled'] == True:
    infrastructure = deployInfrastructure(spacefile)
    return infrastructure
  else:
    typer.secho(f"Infrastructure disabled", err=True, fg=typer.colors.RED)
    raise typer.Exit(code=1)

@app.command()
def version():
  """
  Show apollo's version
  """
      
  version = os.getenv('APOLLO_VERSION')

  if not version:
    typer.secho(f"No version found", err=True, fg=typer.colors.RED)
    raise typer.Exit(code=1)

  typer.secho(f"{version}", err=False, fg=typer.colors.GREEN)

@app.command()
def deploy(what: str = typer.Argument("all")):
  """
  Deploy apollo
  """
  spacefile = loadSpacefile()
  ansible_spacefile = {
    "apollo_space_dir": arc['space_dir'],
    "arc": spacefile
  }

  # Check if in CI
  # gitlab-runner throws an error if ssh-key
  # permissions are bad
  # https://gitlab.com/gitlab-org/gitlab-runner/-/issues/3749
  in_ci = bool(os.getenv('CI'))

  if in_ci:
    typer.secho(f"Running in CI", fg=typer.colors.BRIGHT_BLACK)

    try:
      subprocess.run(['chmod', '0700', '.ssh'])
      subprocess.run(['chmod', '600', '.ssh/id_rsa'])
      subprocess.run(['chmod', '644', '.ssh/id_rsa.pub'])
      typer.secho(f"Corrected ssh key permissions", fg=typer.colors.BRIGHT_BLACK)
    except Exception as e:
      typer.secho(f"Failed to correct ssh key permissions: {e}", err=True, fg=typer.colors.RED)
      raise typer.Exit(code=1)
  
  nodesfile = loadNodesfile()
  if what != "all":
    if nodesfile:
      command = [
        "ansible-playbook",
        "--extra-vars",
        f"{json.dumps(ansible_spacefile)}",
        #'{"arc":'+f"{json.dumps(spacefile)}"+'}',
        "--flush-cache", 
        "--tags", 
        f"{what},always", 
        "provision.yml"
      ]

      if arc['verbosity'] > 0:
        typer.secho(f"{command}", fg=typer.colors.BRIGHT_BLACK)

      deployment = subprocess.run(command, cwd="/apollo")
      
      if deployment.returncode == 0:
        typer.secho(f"Deployment successful", err=False, fg=typer.colors.GREEN)
        return deployment
      else:
        typer.secho(f"Deployment failed", err=True, fg=typer.colors.RED)
        raise typer.Exit(code=deployment.returncode)

  else:
    if nodesfile:
      command = [
        "ansible-playbook",
        "--extra-vars",
        f"{json.dumps(ansible_spacefile)}",
        "--flush-cache", 
        "provision.yml"
      ]

      if arc['verbosity'] > 0:
        typer.secho(f"{command}", fg=typer.colors.BRIGHT_BLACK)

      deployment = subprocess.run(command, cwd="/apollo")

      if deployment.returncode == 0:
        typer.secho(f"Deployment successful", err=False, fg=typer.colors.GREEN)
        return deployment
      else:
        typer.secho(f"Deployment failed", err=True, fg=typer.colors.RED)
        raise typer.Exit(code=deployment.returncode)

@app.command()
def destroy():
  """
  Destroy apollo
  """
  spacefile = loadSpacefile()
  
  if spacefile['infrastructure']['enabled'] == True:
    infrastructure = destroyInfrastructure(spacefile)
    return infrastructure
  else:
    typer.secho(f"Infrastructure disabled", err=True, fg=typer.colors.RED)
    raise typer.Exit(code=1)  

@app.command()
def show(what: str):
  """
  Show apollo config
  """

  spacefile = loadSpacefile()

  if what in ["inventory","nodes"]:
    inventory = json.loads(subprocess.check_output([
      "python",
      "inventory/apollo-inventory.py",
      "--list"
      ], cwd="/apollo"))
    
    typer.secho(json.dumps(inventory, sort_keys=True, indent=4), err=False, fg=typer.colors.BRIGHT_BLACK)

  if what == "config": 
    typer.secho(json.dumps(spacefile,sort_keys=True, indent=4), err=False, fg=typer.colors.BRIGHT_BLACK)


def validateSpacefile():
  spacefile = loadSpacefile()
  schema = anyconfig.load("/apollo/Spacefile.schema.json")

  #defaults = loadDefaults()
  #scm4 = anyconfig.gen_schema(defaults)
  #scm4_s = anyconfig.dumps(scm4, "json")
  #print(scm4_s)

  rc, err = anyconfig.validate(spacefile, schema)
  
  if not rc:
    typer.secho(f"Could not validate Spacefile: {err}", err=True, fg=typer.colors.RED)
    raise typer.Exit(code=1)
  else:
    if (arc['verbosity'] > 1):
      typer.secho(f"Spacefile is valid", fg=typer.colors.GREEN)
    return spacefile

def validateNodesfile():
  nodesfile = loadNodesfile()
  #schema = anyconfig.load("/apollo/Nodesfile.schema.json")

  #defaults = loadDefaults()
  #scm4 = anyconfig.gen_schema(defaults)
  #scm4_s = anyconfig.dumps(scm4, "json")
  #print(scm4_s)

  #rc, err = anyconfig.validate(spacefile, schema)
  
  if not nodesfile:
    typer.secho(f"Could not validate Nodesfile: {err}", err=True, fg=typer.colors.RED)
    raise typer.Exit(code=1)
  else:
    if (arc['verbosity'] > 1):
      typer.secho(f"Nodesfile is valid", fg=typer.colors.GREEN)
    return nodesfile
  
@app.command()
def validate():
  """
  Validate apollo config
  """

  defaults = loadDefaults()

  spacefile = validateSpacefile()

  # Check for defaults
  if spacefile['auth']['admin_password'] == defaults['auth']['admin_password']:
    typer.secho(f"admin_password set to default", fg=typer.colors.BRIGHT_BLACK)

@app.command()
def create(
    space_name: str = typer.Option("", help="URL-conform name of the space", show_default=False),
    space_version: str = typer.Option("latest", help="apollo version to deploy to the space")
  ):
  """
  Create a space from command line
  """

@app.command()
def init():
  """
  Initialize configuration
  """

  typer.secho(f"Initializing apollo config", bold=True, fg=typer.colors.BRIGHT_BLACK)

  # Load /apollo/defaults.yml
  with open('/apollo/defaults.yml','r') as file:
    config = yaml.load(file, Loader=yaml.FullLoader)

  # name
  while config['space']['name'] == "apollo":
    space_name = typer.prompt("Name")

    if checkSpaceName(space_name):
      config['space']['name'] = space_name
    else:
      typer.secho(f"Incorrect format: {space_name}", err=True, fg=typer.colors.RED)

  # base_domain
  while config['space']['base_domain'] == "":
    space_base_domain = typer.prompt("Base Domain")
    
    if checkSpaceBaseDomain(space_base_domain):
      config['space']['base_domain'] = space_base_domain
    else:
      typer.secho(f"Incorrect format: {space_base_domain}", err=True, fg=typer.colors.RED)

  # mail
  while config['space']['mail'] == "":
    space_mail = typer.prompt("E-mail")
    
    if checkSpaceMail(space_mail):
      config['space']['mail'] = space_mail
    else:
      typer.secho(f"Incorrect format: {space_mail}", err=True, fg=typer.colors.RED)

  # space_domain
  config['space']['space_domain'] = f"{config['space']['name']}.{config['space']['base_domain']}"

  # infrastructure
  infrastructure_enabled = typer.confirm("Enable infrastructure")
  if infrastructure_enabled:
        config['infrastructure']['enabled'] = True

        # provider
        while config['infrastructure']['provider'] == "generic":
          infrastructure_provider = typer.prompt("Provider (hcloud, digitalocean")
          
          if infrastructure_provider in ["hcloud", "digitalocean"]:
            config['infrastructure']['provider'] = infrastructure_provider
          else:
            typer.secho(f"Unsupported provider: {infrastructure_provider}", err=True, fg=typer.colors.RED)

        # provider
        while config['provider'][config['infrastructure']['provider']]['auth']['token'] == "":
          auth_token = typer.prompt("API Token")
          
          if auth_token != "":
            config['provider'][config['infrastructure']['provider']]['auth']['token'] = auth_token
          else:
            typer.secho(f"Incorrect format: {auth_token}", err=True, fg=typer.colors.RED)


        # # provider
        # InfrastructureProvider = InfrastructureProviders.generic
        # infrastructure_provider = typer.prompt("Provider")

        # typer.secho(f"Configure managers", bold=True, fg=typer.colors.BRIGHT_BLACK)
        # manager = typer.prompt("Managers")

  # Save Spacefile.yml
  try:
    # Create space_dir
    arc['space_dir'] = arc['spaces_dir']+'/'+config['space']['name']+'.space'

    os.mkdir(arc['space_dir'])

    # Generate SSH Keys
    os.mkdir(arc['space_dir']+'/.ssh')

    command = [
      "ssh-keygen",
      "-b",
      "4096",
      "-t",
      "rsa",
      "-q",
      "-N",
      "\"\"",
      "-f",
      arc['space_dir']+"/.ssh/id_rsa"
    ]

    if arc['verbosity'] > 0:
      typer.secho(f"{command}", fg=typer.colors.BRIGHT_BLACK)

    ssh_dir = subprocess.run(command)

    with open(arc['space_dir']+'/Spacefile.yml','w') as file:
      _arc = yaml.dump(config, file, sort_keys=True)
      
      message = typer.style("Config saved to ", fg=typer.colors.BRIGHT_BLACK)
      message = message + typer.style(f"{arc['space_dir']+'/Spacefile.yml'}", fg=typer.colors.GREEN)
      typer.echo(message)
  except Exception as e:
    typer.secho(f"Could not save Spacefile.yml: {e}", err=True, fg=typer.colors.RED)
    raise typer.Exit(code=1)

@app.callback()
def callback(
    verbosity: int = 0,
    space_dir: str = os.environ.get('PWD'),
    debug: int = 0
  ):
  os.environ["APOLLO_CONFIG_VERSION"] = "2"
  os.environ["APOLLO_CONFIG_DIR"] = "/root/.apollo"
  os.environ["APOLLO_SPACE_DIR"] = space_dir
  os.environ["APOLLO_SPACES_DIR"] = "/root/.apollo/.spaces"
  os.environ["ANSIBLE_VERBOSITY"] = str(verbosity)

  if verbosity > 3 or debug:
    os.environ["ANSIBLE_DEBUG"] = "1"

  arc['config_dir'] = "/root/.apollo"
  arc['space_dir'] = space_dir
  arc['spaces_dir'] = "/root/.apollo/.spaces"
  arc['verbosity'] = verbosity


if __name__ == "__main__":
    app()