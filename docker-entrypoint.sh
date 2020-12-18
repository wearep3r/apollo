#!/bin/bash
set -e

if [ "$CI" = "1" ];
then
  # in CI
  export SHELL ["/bin/bash", "-c"]
fi

if [ "$1" = 'dev' ];
then
  cd /cluster
  exec "/bin/bash"
elif [ "$1" = 'apollo' ];
then
  exec "$@"
else
  set -- apollo "$@"
  cd /cluster
fi

exec "$@"