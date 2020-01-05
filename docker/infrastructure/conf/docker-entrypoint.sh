# See here: https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#entrypoint
# With the DEMO.Dockerfile in mind, this is now possible:
# docker run postgres (invokes the CMD)
# docker run postgres bash (ignores CMD, executes ENTRYPOINT and passes on $1 which will be caught by 'exec "$@"' in docker-entrypoint.sh; bash will be launched)
# 

#! /bin/bash
set -e
if [ "$1" = 'ansible' ]; then
    # Do bootstrapping, init, etc
    # Test for additional conditions (e.g. "is the database already up?"; useful for DB migrations or services that can't start properly without DB connection)
    # This helps to achieve coordinated container-startups (in a Swarm, 'depends_on' doesn't work and can be implemented with the Entrypoint)
    chown -R postgres "$PGDATA"

    if [ -z "$(ls -A "$PGDATA")" ]; then
        gosu postgres initdb
    fi

    # Pseudo Code
    while not db.isReady():
        # Sleep a second, then probe again
        sleep 1;

    exec gosu postgres "$@"
fi

exec "$@"