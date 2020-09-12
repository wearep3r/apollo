# Security

apollo has a number of security features:

- Includes the [DevSec Hardening Framework](https://dev-sec.io/) which implements [Deutsche Telekom's Security Requirements](https://www.telekom.com/de/verantwortung/datenschutz-und-datensicherheit/sicherheit/details/privacy-and-security-assessment-verfahren-342724)
- Encrypted networking with Wireguard backbone
- Custom firewalling
- A-rating for apollo's SSL ingress proxy: [SSL Labs](https://www.ssllabs.com/ssltest/analyze.html?d=portainer.apollo-demo-1.paas.p3r.engineering)
- Ready to audit with **Inspec**
- Infrastructure-as-Code design pattern
- Continuous Replication design pattern to guarantee short recovery times
- Implements cloud-native best practices
- monthly release cycles

## What does that mean

apollo is built to last. We want to establish a rolling release workflow that introduces no backwards compatibility issues. This is hard to achieve considering the many parts that need to be moved to provide a secure container platform.

### Node security

apollo runs on linux nodes - Ubuntu and Debian specifically. We're planning to support RHEL, Suse and ARM-based operating-systems in the near future. To ensure the nodes are secured against attackers, we employ multiple mechanisms:

- inter-node communication is fully encrypted through Wireguard
- firewall blocks all connections except ports 22, 80, 443
- fail2ban increases SSH security
- DevSec Hardening Framework and auditd enable Inspec-based security analyses
- SSL is enabled by default for all controlplane services

### Container security

Container security implementation depends on the orchestrator in place. For our default, Docker Swarm, the following measures will be taken to ensure safe operations:

- regular garbage collection to free unused resources
- network-tracing is possible
- the ingress proxy enables SSL by default for all connected services
- continuous replication ensures regular, automated backups of important data

### Deployment security

apollo does NOT implement any RBAC-like restrictions regarding deployment of apollo itself or apps on an apollo space. All the authenteication and authorization stuff is dealt with by GitLab or GitHub, assuming apollo is used according to its best practices.

### Storage security

In distributed setups, Storidge takes care of data security and availability. Please refer to [their docs](https://docs.storidge.com/) for additional information.

### Disaster recovery

Assuming apollo backups are configured correctly, the fastest way to discover from disaster is to destroy the current cluster, create a new one and restore all data from a backup.

apollo can easily migrated between providers and infrastructures this way, too.