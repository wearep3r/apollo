#!/bin/bash
set -e
# If something is mounted to /.ssh, copy it to /root/.ssh
# Why not mount SSH Keys directly to /root/.ssh?
# On Windows, SSH Keys mounted as a Volume have wrong permission which can't be corrected on a Volume
# This, the strategy is to mount them to /.ssh and copy them to /root/.ssh on each start of the container

if [ -d $ENVIRONMENT_DIR ];
then
  # ToDo: replace this with `if0 environment load`
  env_files=`find $ENVIRONMENT_DIR -type f -name "*.env"`

  for file in $env_files;
  do
    set -o allexport
    source $file
    #export $(grep -hv '^#' $ENVIRONMENT_DIR/*.env | xargs)
    set +o allexport
  done
fi

ZERO_SSH_DIR=${ZERO_SSH_DIR:-/.ssh}
if [ -d "$ZERO_SSH_DIR" ]; then
    if [ "$(ls -A $ZERO_SSH_DIR)" ]; then
        echo "Found SSH Keys in $ZERO_SSH_DIR"
        cp /.ssh/* /root/.ssh/. && chmod 0600 /root/.ssh/id_rsa
        echo "Copied SSH Keys to /root/.ssh"
    fi
fi

exec "$@"