#!/usr/bin/env python3

import typer
import os
import subprocess
import yaml
import json
import sys
import re
from enum import Enum
import anyconfig
from pathlib import Path
from read_version import read_version
from typing import Optional, List
import namesgenerator
from dotenv import load_dotenv
import pyperclip

app = typer.Typer(help="apollo CLI")
arc = {"space_dir": os.getenv("PWD")}

spacefile = {}

# HELPER COMMANDS


class InfrastructureProviders(str, Enum):
    generic = "generic"
    hcloud = "hcloud"
    digitalocean = "digitalocean"


def checkSpaceVersion(version: str):
    """
    Check if spaceVersion matches the required syntax
    """
    pattern = re.compile(
        "^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"
    )

    if pattern.match(version):
        return True

    return False


def loadSpacefile():
    try:
        spacefile = anyconfig.load(
            [arc["defaults_path"], os.path.join(arc["space_dir"], ".apollorc.yml")],
            "yaml",
        )
        return spacefile
    except Exception as e:
        typer.secho(
            f"Error loading .apollorc.yml: {e}",
            err=True,
            bold=False,
            fg=typer.colors.RED,
        )
        raise typer.Exit(code=1)


@app.command()
def exec(target: str, command: str):
    """
    Exec command on cluster
    """
    nodesfile = loadNodesfile()

    typer.secho(f"Executing {command} on {target}", fg=typer.colors.BRIGHT_BLACK)

    try:
        exec = subprocess.run(
            [
                "ansible",
                "-i",
                arc["inventory_path"],
                f"{target}",
                "-a",
                f"{command}",
            ],
            cwd=arc["ansible_path"],
        )
    except Exception as e:
        typer.secho(
            f"Failed to execture {command} on {target}", err=True, fg=typer.colors.RED
        )
        raise typer.Exit(code=1)


# @app.command()
# def enter(node: str):
#     """
#     Enter cluster node
#     """
#     spacefile = loadSpacefile()
#     nodesfile = loadNodesfile()
#     ssh_config = "-o LogLevel=ERROR -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

#     nodes = {}

#     if nodesfile["manager"]:
#         for manager in nodesfile["manager"]:
#             nodes[manager["name"]] = manager

#     if nodesfile["worker"]:
#         for worker in nodesfile["worker"]:
#             nodes[worker["name"]] = worker

#     apollo_user = nodes.get(node, {}).get("user", "root")
#     apollo_ipv4 = nodes.get(node, {}).get("ipv4", "")
#     command = "ssh {} -i {}/.ssh/id_rsa -l {} {}".format(
#         ssh_config, arc["space_dir"], apollo_user, apollo_ipv4
#     )

#     try:
#         enter = subprocess.call(command, shell=True)
#     except Exception as e:
#         typer.secho(f"Failed to enter {node}", err=True, fg=typer.colors.RED)

#         if arc["verbosity"] > 0:
#             typer.secho(f"{command}", err=False, fg=typer.colors.BRIGHT_BLACK)
#         raise typer.Exit(code=1)


@app.command()
def commit(message: str):
    """
    Commit configuration changes to the space (requires git)
    """
    command = ["git", "commit", "-am", f"{message}"]

    if arc["verbosity"] > 0:
        typer.secho(f"{command}", fg=typer.colors.BRIGHT_BLACK)

    commit = subprocess.run(command)

    return commit


@app.command()
def push():
    """
    Push configuration changes to the space repository (requires git)
    """
    command = ["git", "push"]

    if arc["verbosity"] > 0:
        typer.secho(f"{command}", fg=typer.colors.BRIGHT_BLACK)

    push = subprocess.run(command)

    return push


@app.command()
def build():
    """
    Build apollo infrastructure
    """
    spacefile = loadSpacefile()

    if spacefile["infrastructure"]["enabled"] == True:
        infrastructure = deployInfrastructure(spacefile)
        return infrastructure
    else:
        typer.secho(f"Infrastructure disabled", err=True, fg=typer.colors.RED)
        raise typer.Exit(code=1)


@app.command(context_settings={"allow_extra_args": True, "ignore_unknown_options": True})
def inventory(ctx: typer.Context):
    base_command = ["ansible-inventory", "-i", arc["inventory"]]

    run_command = base_command + ctx.args

    if arc["verbosity"] > 0:
        typer.secho(f"{run_command}", fg=typer.colors.BRIGHT_BLACK)

    result = subprocess.run(run_command, cwd=arc["ansible_path"])

    return result


def runPlay(custom_command, custom_vars: dict = {}):
    base_vars = {
        "apollo_space_dir": arc["space_dir"],
    }

    if custom_vars:
        base_vars = base_vars + custom_vars

    base_command = [
        "ansible-playbook",
        "-i",
        arc["inventory"],
        "--flush-cache",
        "--extra-vars",
        f"{json.dumps(base_vars)}",
    ]

    run_command = base_command + custom_command

    if arc["dry"]:
        typer.secho(f"Running in check mode", fg=typer.colors.BRIGHT_BLACK)
        run_command.append("--check")

    if arc["verbosity"] > 0:
        typer.secho(f"{run_command}", fg=typer.colors.BRIGHT_BLACK)

    result = subprocess.run(run_command, cwd=arc["ansible_path"])

    return result


def runKubectl(custom_command, custom_vars: dict = {}):
    base_command = ["kubectl", "--kubeconfig", arc["kubeconfig"]]

    run_command = base_command + custom_command

    if arc["verbosity"] > 0:
        typer.secho(f"{run_command}", fg=typer.colors.BRIGHT_BLACK)

    result = subprocess.run(run_command)

    return result


@app.command()
def copy():
    kubeconfig = anyconfig.load(arc["kubeconfig"])
    pyperclip.copy(anyconfig.dumps(kubeconfig, "yaml"))
    pyperclip.paste()


@app.command(context_settings={"allow_extra_args": True, "ignore_unknown_options": True})
def deploy(ctx: typer.Context):
    """
    Deploy apollo
    """

    command = [
        "deploy.yml",
    ]

    custom_vars = {}

    if ctx.args:
        command = command + ctx.args

    if arc["verbosity"] > 0:
        typer.secho(f"{command}", fg=typer.colors.BRIGHT_BLACK)

    result = runPlay(command, custom_vars)

    if result.returncode == 0:
        typer.secho(f"Deployment successful", err=False, fg=typer.colors.GREEN)
        return result
    else:
        typer.secho(f"Deployment failed", err=True, fg=typer.colors.RED)
        raise typer.Exit(code=result.returncode)


@app.command()
def destroy():
    """
    Destroy apollo
    """
    spacefile = loadSpacefile()

    if spacefile["infrastructure"]["enabled"] == True:
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

    if what in ["inventory", "nodes"]:
        inventory = json.loads(
            subprocess.check_output(
                ["python", "inventory/apollo-inventory.py", "--list"],
                cwd=arc["ansible_path"],
            )
        )

        typer.secho(
            json.dumps(inventory, sort_keys=True, indent=4),
            err=False,
            fg=typer.colors.BRIGHT_BLACK,
        )

    if what == "config":
        typer.secho(
            json.dumps(spacefile, sort_keys=True, indent=4),
            err=False,
            fg=typer.colors.BRIGHT_BLACK,
        )


@app.command()
def init(force: bool = typer.Option(False, "--force", "-f")):
    """
    Initialize configuration
    """

    # typer.secho("Initializing apollo config", bold=True, fg=typer.colors.BRIGHT_BLACK)

    # Check if config already exists
    if os.path.exists(arc["inventory"]):
        if not force:
            message = typer.style(
                "Config already exists. ",
                bold=True,
                fg=typer.colors.RED,
            )
            message += typer.style(
                "Run '!! -f' (or 'apollo init --force') to overwrite it.",
                bold=False,
                fg=typer.colors.WHITE,
            )
            typer.echo(message)
            raise typer.Exit(code=1)

    defaults = anyconfig.load(arc["defaults_path"])

    # with open(arc["defaults_path"], "r") as file:
    #     defaults = yaml.load(file, Loader=yaml.FullLoader)

    # name
    if defaults["all"]["vars"]["id"] == "apollo":
        # Generate random name
        cluster_name = namesgenerator.get_random_name(sep="-")

        # Prompt for
        cluster_id = typer.prompt("Set a cluster id", default=cluster_name)

        defaults["all"]["vars"]["id"] = cluster_id

    # Save .apollorc.yml
    try:
        anyconfig.dump(defaults, arc["inventory"])

        message = typer.style("Config saved to ", fg=typer.colors.WHITE)
        message = message + typer.style(f"{arc['inventory']}", fg=typer.colors.GREEN)
        typer.echo(message)
    except Exception as e:
        typer.secho(f"Could not save config: {e}", err=True, fg=typer.colors.RED)
        raise typer.Exit(code=1)


def version_callback(value: bool):
    if value:
        version = read_version(".", "__init__.py")
        typer.echo(f"{version}")
        raise typer.Exit()


@app.command(context_settings={"allow_extra_args": True, "ignore_unknown_options": True})
def bootstrap(
    ctx: typer.Context,
    list_tasks: bool = typer.Option(
        False, "--list-tasks", "-d", help="List Tasks, do not execute"
    ),
    list_tags: bool = typer.Option(
        False, "--list-tags", "-d", help="List Tags, do not execute"
    ),
):

    command = [
        "--tags",
        "create",
        "bootstrap.yml",
    ]

    if list_tasks:
        command.append("--list-tasks")

    if list_tags:
        command.append("--list-tags")

    if ctx.args:
        command = command + ctx.args

    result = runPlay(command)

    if result.returncode == 0:
        typer.secho(f"Bootstrapping successful", err=False, fg=typer.colors.GREEN)
        return result
    else:
        typer.secho(f"Bootstrapping failed", err=True, fg=typer.colors.RED)
        raise typer.Exit(code=bootstrap.returncode)

    # Managers
    # 1. Check if "nodes" list is empty
    # 2. if so, fall back on group spec

    raise typer.Exit()


@app.command(context_settings={"allow_extra_args": True, "ignore_unknown_options": True})
def k(ctx: typer.Context):
    command = []

    if ctx.args:
        command = command + ctx.args

    runKubectl(command)


@app.callback(invoke_without_command=True)
def callback(
    verbosity: int = typer.Option(0, "--verbosity", "-v", help="Verbosity"),
    inventory: str = typer.Option(
        os.path.join(os.environ.get("PWD"), ".apollorc.yml"),
        "--inventory",
        "-i",
        help="Inventory",
    ),
    env_file: str = typer.Option(
        os.path.join(os.environ.get("PWD"), ".env"),
        "--env-file",
        "-e",
        help="A file containing environment variables to be used during command execution",
    ),
    debug: bool = typer.Option(False, "--debug", "-d", help="Enable Debugging"),
    force: bool = typer.Option(False, "--force", help="Enable Development Mode"),
    dry: bool = typer.Option(False, "--dry", help="Enable dry run"),
    version: Optional[bool] = typer.Option(
        None, "--version", callback=version_callback, is_eager=True
    ),
):
    # Load from .env
    load_dotenv(dotenv_path=env_file)

    home = os.environ.get("HOME")

    os.environ["APOLLO_CONFIG_VERSION"] = "3"
    os.environ["APOLLO_VERSION"] = read_version(".", "__init__.py")

    arc["config_dir"] = f"{home}/.apollo"
    os.environ["APOLLO_CONFIG_DIR"] = arc["config_dir"]

    arc["spaces_dir"] = f"{home}/.apollo/.spaces"
    os.environ["APOLLO_SPACES_DIR"] = arc["spaces_dir"]

    arc["inventory"] = inventory
    os.environ["ANSIBLE_INVENTORY"] = arc["inventory"]

    arc["space_dir"] = str(Path(arc["inventory"]).parent)
    os.environ["APOLLO_SPACE_DIR"] = arc["space_dir"]

    arc["kubeconfig"] = os.path.join(arc["space_dir"], "kubeconfig.yml")
    os.environ["KUBECONFIG"] = arc["kubeconfig"]

    arc["verbosity"] = verbosity
    os.environ["ANSIBLE_VERBOSITY"] = str(verbosity)

    arc["debug"] = debug
    os.environ["ANSIBLE_DEBUG"] = str(arc["debug"])

    arc["force"] = force
    arc["dev"] = force
    os.environ["APOLLO_FORCE"] = str(arc["force"])

    arc["dry"] = dry

    arc["defaults_path"] = str(Path(__file__).parent / ".apollorc.yml")
    arc["ansible_path"] = str(Path(__file__).parent / "ansible")


if __name__ == "__main__":
    app()
