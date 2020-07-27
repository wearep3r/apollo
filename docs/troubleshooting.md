# Troubleshooting

## Docker Upgrades

Updating active Swarm clusters can lead to problems during deployment where the Swarm seems to be broken. A possible indicator is a log-message like this:

```bash
TASK [apollo-orchestrator-swarm : Initialize Swarm Cluster] ************************************************************************************************************************************************
fatal: [manager-0]: FAILED! => changed=true 
  cmd: |-
    docker swarm init --advertise-addr=188.68.34.76:2377
  delta: '0:00:00.095251'
  end: '2020-07-27 16:07:35.320168'
  msg: non-zero return code
  rc: 1
  start: '2020-07-27 16:07:35.224917'
  stderr: 'Error response from daemon: This node is already part of a swarm. Use "docker swarm leave" to leave this swarm and join another one.'
  stderr_lines: <omitted>
  stdout: ''
  stdout_lines: <omitted>
        to retry, use: --limit @/root/.ansible/.retry/provision.retry
```

### Solution

`enter` the Space and do the following on each node:

* stop Docker
* delete the Swarm
* reboot

```bash
service docker stop && rm -r /var/lib/docker/swarm && reboot
```

Once all nodes are up again, `deploy` to form a new Swarm.
