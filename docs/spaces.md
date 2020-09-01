# apollo Spaces

apollo manages clusters in **spaces**. A **space** is a self-contained compute-environment built from declarative configuration. Locally, apollo uses `~/.apollo/.spaces` to keep track of your managed spaces. Each space has its own directory, suffixed with `.space` (so it's easier to find with standard linux-tooling).

## Create a space

An apollo space has a few minimum requirements to be functional:

- a good name
- an IP address of a node to manage
- ssh-keys that are allowed to access that node

Everything else is optional.

You can create spaces in multiple different ways:

### Manually

```bash
mkdir spacename3000.space
cd spacename3000.space
ssh-keygen -b 4096 -t rsa -q -N "" -f .ssh/id_rsa
cat <<'EOF' >> apollo.env
APOLLO_NODES_MANAGER=1.2.3.4
APOLLO_SPACE=spacename3000
EOF
```

### With our Docker image

```bash
mkdir ~/.apollo
docker run --rm -it \
  --name apollo \
  -v ${HOME}/.ssh:/root/.ssh \
  -v ${HOME}/.gitconfig:/root/.gitconfig \
  -v ${HOME}/.apollo:/root/.apollo \
  wearep3r/apollo:latest
```

Once you're runnning the Docker image, type `init`, press `ENTER` and work through the wizard.

### In CI/CD

apollo can be configured entirely by environment variables. With GitLab, you can create spaces solely from **CI/CD Variables** - no need to keep files anywhere.

## Deploy a space

The typical thing to do with spaces is **deploying** them - for updates, changed config or maintenance.

### With Docker

By now, you should already have that alias from the [README](../README.md) in you shell-configuration so we can skip on the docker-part.

From within a space directory, run:

```bash
apollo deploy
```

This makes sure the space configuration will be compiled into real world artifacts: you container-platform.

## Commit a space

This is only relevant if you manage your spaces with GitLab (which you should).

### Setup automatic verisoning

apollo spaces use [shipmate](https://gitlab.com/peter.saarland/shipmate) to add automated semantic versioning to space configuration. This helps to keep track of changes in a GitOps-y way and also opens the door for rollbacks.

If you want to use this feature, here's what you need:

- a GitLab repository to hold your apollo space config
- your [Personal Access Token](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) added as a [CI/CD variable](https://docs.gitlab.com/ee/security/cicd_environment_variables.html) to that repository
- a quick read about [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) and [semantic-release](https://github.com/semantic-release/semantic-release#how-does-it-work)
- the following `.gitlab-ci.yml` added to your apollo space directory:

```bash
include:
  - remote: "https://gitlab.com/peter.saarland/shipmate/-/raw/master/shipmate.gitlab-ci.yml"
```

----

Once everything is in place, update your space!

```bash
git add .
git commit -am "feat: updated to apollo 1.8.1"
git push
```

Shipmate will add an auto-generated version as a tag to your repository as well as a changelog outlining what happend, based on your commits.
