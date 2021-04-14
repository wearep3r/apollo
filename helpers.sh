#!/usr/bin/env bash
set -euo pipefail

bootstrap() {
  echo "ansible-playbook install.yml $@"
  chmod 0700 /root/.ssh/id_rsa
  ansible-playbook install.yml "$@"
}

install() {
  echo "ansible-playbook install.yml $@"
  chmod 0700 /root/.ssh/id_rsa
  ansible-playbook install.yml "$@"
}

upgrade() {
  echo "ansible-playbook install.yml $@"
  chmod 0700 /root/.ssh/id_rsa
  ansible-playbook install.yml "$@"
}

uninstall() {
  echo "ansible-playbook uninstall.yml $@"
  chmod 0700 /root/.ssh/id_rsa
  ansible-playbook uninstall.yml "$@"
}

# Call the requested function and pass the arguments as-is
"$@"
