#!/bin/bash
set -e
# If something is mounted to /.ssh, copy it to /root/.ssh
# Why not mount SSH Keys directly to /root/.ssh?
# On Windows, SSH Keys mounted as a Volume have wrong permission which can't be corrected on a Volume
# This, the strategy is to mount them to /.ssh and copy them to /root/.ssh on each start of the container

if [ -d $ENVIRONMENT_DIR ];
then
  env_files=`find $ENVIRONMENT_DIR -type f -name "*.env"`

  for file in $env_files;
  do
    set -o allexport
    #source $file
    export $(grep -hv '^#' $file | xargs)
    set +o allexport
  done
fi

SSH_DIR=${SSH_DIR:-/.ssh}
if [ -d "$SSH_DIR" ]; then
    if [ "$(ls -A $SSH_DIR)" ]; then
        echo "Found SSH Keys in $SSH_DIR"
        cp /.ssh/* /root/.ssh/. && chmod 0600 /root/.ssh/id_rsa
        echo "Copied SSH Keys to /root/.ssh"
    fi
fi

exec "$@"