#!/bin/zsh
set -e
set -Eeo pipefail

# source /apollo/apollo.plugin.zsh

# if [ -f $HOME/.apollo/apollo.env ];
# then
#   set -o allexport
#   export $(grep -hv '^#' $HOME/.apollo/apollo.env | xargs)
#   set +o allexport
# fi

if [ ! -d $HOME/.apollo/.spaces ];
then
  mkdir -p $HOME/.apollo/.spaces
fi

# Backwards compatibility
SSH_DIR=${SSH_DIR:-/.ssh}
if [ -d "$SSH_DIR" ]; then
    if [ "$(ls -A $SSH_DIR)" ]; then
        echo "Found SSH Keys in $SSH_DIR"
        cp /.ssh/* /root/.ssh/. && chmod 0600 /root/.ssh/id_rsa
        echo "Copied SSH Keys to /root/.ssh"
    fi
fi

if [ "$1" = 'enter' ];
then
  cd /cargo
  exec "/bin/zsh"
else
  #export APOLLO_SPACE_DIR=/cargo
  #set -- /usr/local/bin/apollo --space-dir /cargo "$@"
  set -- /usr/local/bin/apollo "$@"
  cd /cargo
fi

exec "$@"