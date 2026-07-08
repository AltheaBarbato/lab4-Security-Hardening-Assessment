# Hardening Checklist
**Name:** Althea Barbato

Status of each hardening control on `webserver01` after running `bash deploy.sh`.

| Control | Status | How applied |
|---|---|---|
| Root SSH login disabled | done | sshd_config PermitRootLogin no |
| Password authentication disabled | done | sshd_config PasswordAuthentication no |
| SSH MaxAuthTries = 3 | done | sshd_config MaxAuthTries 3 |
| SSH idle timeout (5 min) | done | ClientAliveInterval 300 / CountMax 2 |
| X11 forwarding disabled | done | sshd_config X11Forwarding no |
| Agent forwarding disabled | done | sshd_config AllowAgentForwarding no |
| Empty passwords blocked | done | sshd_config PermitEmptyPasswords no |
| UFW firewall active | done | from baseline role, Lab 1 |
| Only necessary ports open | done | 22/80/443/9090/3000/3001/9100/9113 |
| Fail2ban running | done | from baseline role, Lab 1 |
| Fail2ban bantime 1 hour | done | jail.local bantime=3600 |
| Fail2ban maxretry = 5 | done | jail.local maxretry=5 |
| Auditd installed and running | done | this lab |
| Audit rules for /etc/passwd | done | /etc/audit/rules.d/hardening.rules |
| Audit rules for /etc/shadow | done | /etc/audit/rules.d/hardening.rules |
| Audit rules for sshd_config | done | /etc/audit/rules.d/hardening.rules |
| Audit rules for sudoers | done | /etc/audit/rules.d/hardening.rules |
| SYN cookie protection | done | sysctl net.ipv4.tcp_syncookies=1 |
| ICMP redirect disabled | done | sysctl accept_redirects=0 |
| Reverse path filtering | done | sysctl rp_filter=1 |
| Source route acceptance disabled | done | sysctl accept_source_route=0 |
| dmesg restricted to root | done | sysctl kernel.dmesg_restrict=1 |
| SUID core dumps disabled | done | sysctl fs.suid_dumpable=0 |
| Password max age 90 days | done | /etc/login.defs |
| Password expiry warning 14 days | done | /etc/login.defs |
| Automatic security updates | done | unattended-upgrades |
| USB storage disabled | done | /etc/modprobe.d (cloud VM, no physical USB) |
| Monitoring with alerts | done | Prometheus + Grafana, Lab 3 |
| Failed login visibility | done | node_failed_ssh_logins_total metric |

## Not done (known gaps)

| Control | Why not |
|---|---|
| Prometheus UI restricted by IP | No reverse proxy set up, Oracle VCN is the only gate |
| MFA for SSH | Key-only auth is sufficient for this setup |
| CIS Benchmark full compliance | Out of scope for this class, would need 200+ controls |
| Intrusion detection (Tripwire/AIDE) | Not required, auditd covers the key files |
| Network segmentation | Single server, nothing to segment |
