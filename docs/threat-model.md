# Threat Model
**Name:** Althea Barbato

Using a simplified STRIDE approach to identify threats against `webserver01`.

---

## What I'm protecting

- The server itself (Ubuntu 20.04, Oracle Cloud)
- The web application running on nginx (port 80)
- The monitoring stack (Prometheus, Grafana, Uptime Kuma)
- The SSH access mechanism
- Data at rest: logs, Prometheus time series, Grafana data

---

## Threat actors

**Script kiddies / automated scanners** most likely threat. The internet constantly scans for open ports, default credentials, and known CVEs. No targeted intent, just opportunistic.

**Credential stuffers** try username/password combos leaked from other services. Less relevant here since password auth is disabled, but still show up in the logs.

**Targeted attacker** someone specifically after this server. Unlikely (it's a class project with no valuable data) but used as the worst-case for modeling.

---

## STRIDE analysis

### Spoofing
**Threat:** attacker spoofs SSH connections or impersonates a legitimate user.
**Mitigation:** key-only auth means credentials can't be stolen via phishing or reuse. SSH protocol 2 only (no SSHv1 which had MITM vulnerabilities).
**Residual risk:** if the private key file is compromised on the client machine, identity spoofing is possible.

### Tampering
**Threat:** attacker modifies server files, configs, or monitoring data.
**Mitigation:** auditd watches /etc/passwd, /etc/shadow, /etc/ssh/sshd_config, /etc/sudoers for any write or attribute change. UFW and iptables prevent unauthorized network access.
**Residual risk:** auditd logs could be cleared by root. No off-server log shipping means audit logs only exist on the compromised machine.

### Repudiation
**Threat:** actions taken on the server can't be traced back to a specific actor.
**Mitigation:** auditd logs user commands (uid >= 1000) with timestamps. Auth events go to /var/log/auth.log. Both are visible in the monitoring stack.
**Residual risk:** logs aren't shipped off-server, so a root compromise could destroy them.

### Information disclosure
**Threat:** sensitive server information exposed publicly.
**Mitigation:** Prometheus node_exporter metrics are on port 9100 (accessible but not advertising credentials). Grafana requires login. kernel.dmesg_restrict=1 hides kernel messages from non-root users.
**Residual risk:** Prometheus /metrics and /api/v1/query are publicly accessible. Someone could learn the server's exact CPU, memory, disk, and process state. No real secrets in there but it's more information than needed.

### Denial of Service
**Threat:** server overwhelmed and made unavailable.
**Mitigation:** tcp_syncookies=1 protects against SYN floods. Fail2ban bans IPs after 5 failed attempts within 10 minutes, limiting brute force volume. UFW rate limiting could be added.
**Residual risk:** a volumetric DDoS from many IPs would overwhelm the 1 Gbps Oracle connection. No CDN or DDoS protection in place.

### Elevation of privilege
**Threat:** attacker gains root from an unprivileged position.
**Mitigation:** fs.suid_dumpable=0 (prevents SUID binary core dumps). sudoers is audit-watched. No unnecessary SUID binaries added (default Ubuntu only).
**Residual risk:** kernel exploits could bypass all of this. Unattended-upgrades keeps the kernel patched but there's always a window between disclosure and patch deployment.

---

## Attack surfaces by port

| Port | Service | Exposure | Risk |
|---|---|---|---|
| 22 | SSH | 0.0.0.0/0 | Medium (key-only, fail2ban active) |
| 80 | nginx | 0.0.0.0/0 | Low (static page, no user input) |
| 9090 | Prometheus | 0.0.0.0/0 | Low-Medium (no auth, exposes metrics) |
| 3000 | Grafana | 0.0.0.0/0 | Low (login required, non-default password) |
| 3001 | Uptime Kuma | 0.0.0.0/0 | Low (login required) |
| 9100 | node_exporter | 0.0.0.0/0 | Low (read-only metrics) |
| 9113 | nginx_exporter | 0.0.0.0/0 | Low (read-only metrics) |
