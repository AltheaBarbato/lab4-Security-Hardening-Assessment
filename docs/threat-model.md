# Threat Model
**Name:** Althea Barbato

STRIDE breakdown for webserver01. Not a super complex setup but worth thinking through.



## What I'm protecting

- The server (Ubuntu 20.04, Oracle Cloud free tier)
- nginx web app on port 80
- The monitoring stack from Lab 3 (Prometheus, Grafana, Uptime Kuma)
- SSH access
- Logs, Prometheus data, Grafana data



## Who would even attack this

**Automated scanners** most realistic threat. Bots constantly scan the internet for open ports and default creds. Not personal, just opportunistic.

**Credential stuffers** try leaked username/password combos from other breaches. Not super relevant here since password auth is off, but they show up in the logs anyway.

**Targeted attacker** someone actually after this server specifically. Pretty unlikely since there's nothing valuable on it, but good to think through worst case.



## STRIDE

### Spoofing
Someone pretending to be me to get SSH access.
Key-only auth helps a lot here since there's no password to steal. SSHv1 is disabled.
Still risky if my laptop gets compromised and someone grabs the key file.

### Tampering
Someone changing files or configs on the server.
auditd is watching the sensitive ones now (/etc/passwd, /etc/shadow, sshd_config, sudoers). UFW and iptables block unauthorized access.
If someone got root they could clear the audit logs before anyone noticed.

### Repudiation
Not being able to trace who did what.
auditd logs commands from non-root users with timestamps. Auth events in auth.log.
Logs are only on the server so if someone rooted it they could wipe them.

### Information disclosure
Server info leaking to people who shouldn't have it.
Grafana requires a login. kernel.dmesg_restrict=1 hides kernel info from non-root.
Prometheus is still open to anyone on port 9090. CPU, memory, disk, process state all accessible with no auth.

### Denial of Service
Server getting flooded and going down.
tcp_syncookies=1 handles SYN floods. Fail2ban cuts off IPs that hammer SSH.
A real distributed attack from a ton of IPs at once would overwhelm it. No CDN or DDoS protection.

### Elevation of privilege
Getting from regular user to root.
fs.suid_dumpable=0 blocks a specific path for that. Sudoers is audit-watched. No extra SUID binaries added.
Kernel exploits could still work. Unattended-upgrades patches things but there's always a window.



## Open ports and their risk

| Port | Service | Exposure | Risk |
|---|---|---|---|
| 22 | SSH | 0.0.0.0/0 | Medium (key-only, fail2ban running) |
| 80 | nginx | 0.0.0.0/0 | Low (static page, no user input) |
| 9090 | Prometheus | 0.0.0.0/0 | Low-Medium (no auth at all) |
| 3000 | Grafana | 0.0.0.0/0 | Low (login required) |
| 3001 | Uptime Kuma | 0.0.0.0/0 | Low (login required) |
| 9100 | node_exporter | 0.0.0.0/0 | Low (read only) |
| 9113 | nginx_exporter | 0.0.0.0/0 | Low (read only) |
