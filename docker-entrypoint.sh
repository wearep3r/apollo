#!/bin/bash
set -e
# If something is mounted to /.ssh, copy it to /root/.ssh
# Why not mount SSH Keys directly to /root/.ssh?
# On Windows, SSH Keys mounted as a Volume have wrong permission which can't be corrected on a Volume
# This, the strategy is to mount them to /.ssh and copy them to /root/.ssh on each start of the container

DIR=/.ssh
if [ -d "$DIR" ]; then
    if [ "$(ls -A $DIR)" ]; then
        echo "Found SSH Keys in /.ssh"
        cp /.ssh/* /root/.ssh/. && chmod 0600 /root/.ssh/id_rsa
        echo "Copied SSH Keys in /root/.ssh"
    fi
fi

exec "$@"