# Network

apollo handles networking and ingress by spanning a peer-to-peer [Wireguard](https://www.wireguard.com/) network between nodes and limiting access to the cluster through custom firewalling.

| Port | Description | Access | Condition |
|------------|-------|----------|-----|
| 22    | SSH |  ✅ | - |
| 23    | NTP |  ✅ | - |
| 80    | HTTP | ✅ | - |
| 443    | HTTPS | ✅ | - |
| 6443    | Kubernetes API | ✅ | `APOLLO_ORCHESTRATOR` in `k3s,k8s` |
| 5888    | VPN | ✅ | `wireguard` in `APOLLO_APPS` |
| 2222    | GitLab SSH | ✅ | `gitlab` in `APOLLO_APPS` |
| *    | ALL | ❌ | DROP all other traffic |