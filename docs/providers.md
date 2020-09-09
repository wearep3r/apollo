# apollo provider

`APOLLO_PROVIDER` contains information about the infrastruture provider. Default is `generic`, which means apollo won't create its own infrastructure.

## generic

You need to manually provide all necessary infrastructure configuration.

```bash
APOLLO_PROVIDER=generic
APOLLO_NODES_MANAGER=
APOLLO_NODES_WORKER=
APOLLO_PRIVATE_INTERFACE=
APOLLO_PUBLIC_INTERFACE=
APOLLO_INGRESS_IP=
```

### Prepare nodes

- Login as root
- Create ssh directory: `mkdir .ssh`
- Add the space public key to user root's authorized_keys: `echo $SSH_PUBLIC_KEY > /root/.ssh/authorized_keys`
- Set `PermitRootLogin` to `without-password` in `/etc/ssh/sshd_config`

## hcloud