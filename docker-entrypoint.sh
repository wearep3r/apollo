#!/bin/bash
set -e

if [ "$CI" = "1" ];
then
  # in CI
  export SHELL ["/bin/bash", "-c"]
fi

if [ ! -d $HOME/.apollo/.spaces ];
then
  mkdir -p $HOME/.apollo/.spaces
fi

# Backwards compatibility
SSH_DIR=${SSH_DIR:-/.ssh}
if [ -d "$SSH_DIR" ]; then
    if [ "$(ls -A $SSH_DIR)" ]; then
        echo "Found SSH Keys in $SSH_DIR"
        cp /.ssh/* /home/apollo/.ssh/. && chmod 0600 /home/apollo/.ssh/id_rsa
        echo "Copied SSH Keys to /root/.ssh"
    fi
fi

if [ "$1" = 'dev' ];
then
  cd /cargo
  exec "/bin/bash"
elif [ "$1" = 'apollo' ];
then
  exec "$@"
else
  set -- /home/apollo/.local/bin/apollo "$@"
  cd /cargo
fi

exec "$@"