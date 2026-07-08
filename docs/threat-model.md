# Threat Model
**Name:** Althea Barbato

Using a simplified STRIDE approach to identify threats against `webserver01`.

---

## What I'm protecting

- The server itself (Ubuntu 20.04, Oracle Cloud)
- The web app running on nginx (port 80)
- The monitoring stack (Prometheus, Grafana, Uptime Kuma)
- SSH access
- Data at rest: logs, Prometheus time series, Grafana data

---

## Threat actors

**Script kiddies and automated scanners** most likely threat. The internet constantly scans for open ports, default credentials, and known CVEs. No targeted intent, just opportunistic.

**Credential stuffers** try username/password combos leaked from other services. Less relevant here since password auth is disabled, but they still show up in the logs.

**Targeted attacker** someone specifically after this server. Unlikely since it's a class project with no valuable data, but useful as the worst case for modeling.

---

## STRIDE analysis

### Spoofing
**Threat:** attacker spoofs SSH connections or pretends to be a legitimate user.
**Mitigation:** key-only auth means credentials can't be stolen via phishing or credential reuse. SSH protocol 2 only (SSHv1 had known MITM issues).
**Residual risk:** if the private key file on my laptop gets compromised, identity spoofing is possible.

### Tampering
**Threat:** attacker changes server files, configs, or monitoring data.
**Mitigation:** auditd watches /etc/passwd, /etc/shadow, /etc/ssh/sshd_config, /etc/sudoers for write or attribute changes. UFW and iptables block unauthorized network access.
**Residual risk:** auditd logs could be cleared by root. No off-server log shipping means audit logs only exist on the compromised machine if it gets fully rooted.

### Repudiation
**Threat:** actions on the server can't be traced back to who did them.
**Mitigation:** auditd logs commands from non-root users with timestamps. Auth events go to /var/log/auth.log. Both feed into the monitoring stack.
**Residual risk:** logs aren't shipped off-server, so a root compromise could wipe them.

### Information disclosure
**Threat:** sensitive server info exposed to the public.
**Mitigation:** Grafana requires login. kernel.dmesg_restrict=1 hides kernel messages from non-root users. node_exporter exposes metrics but not credentials.
**Residual risk:** Prometheus /metrics and /api/v1/query are publicly accessible with no auth. Anyone can learn CPU, memory, disk, and process state of the server. Not credentials but more info than needed.

### Denial of Service
**Threat:** server gets overwhelmed and goes down.
**Mitigation:** tcp_syncookies=1 protects against SYN floods. Fail2ban bans IPs after 5 failed attempts within 10 minutes, limiting brute force volume.
**Residual risk:** a volumetric DDoS from many IPs at once would overwhelm the Oracle connection. No CDN or DDoS protection in place.

### Elevation of privilege
**Threat:** attacker gets root from an unprivileged position.
**Mitigation:** fs.suid_dumpable=0 prevents SUID binary core dumps. sudoers is audit-watched. No extra SUID binaries added beyond Ubuntu defaults.
**Residual risk:** kernel exploits could bypass all of this. Unattended-upgrades keeps the kernel patched but there's always a gap between disclosure and patch.

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
