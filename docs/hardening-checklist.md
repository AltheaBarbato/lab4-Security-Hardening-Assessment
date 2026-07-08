# Hardening Checklist
**Name:** Althea Barbato

What's done and what's not on webserver01.

| Control | Status | How |
|---|---|---|
| Root SSH login disabled | done | sshd_config PermitRootLogin no |
| Password auth disabled | done | sshd_config PasswordAuthentication no |
| SSH MaxAuthTries = 3 | done | sshd_config MaxAuthTries 3 |
| SSH idle timeout 5 min | done | ClientAliveInterval 300 / CountMax 2 |
| X11 forwarding off | done | sshd_config X11Forwarding no |
| Agent forwarding off | done | sshd_config AllowAgentForwarding no |
| Empty passwords blocked | done | sshd_config PermitEmptyPasswords no |
| UFW firewall active | done | baseline role, Lab 1 |
| Only needed ports open | done | 22/80/443/9090/3000/3001/9100/9113 |
| Fail2ban running | done | baseline role, Lab 1 |
| Fail2ban ban time 1 hour | done | jail.local bantime=3600 |
| Fail2ban maxretry 5 | done | jail.local maxretry=5 |
| Auditd installed | done | this lab |
| Watching /etc/passwd | done | /etc/audit/rules.d/hardening.rules |
| Watching /etc/shadow | done | /etc/audit/rules.d/hardening.rules |
| Watching sshd_config | done | /etc/audit/rules.d/hardening.rules |
| Watching sudoers | done | /etc/audit/rules.d/hardening.rules |
| SYN cookie protection | done | sysctl tcp_syncookies=1 |
| ICMP redirects blocked | done | sysctl accept_redirects=0 |
| Reverse path filtering | done | sysctl rp_filter=1 |
| Source routing blocked | done | sysctl accept_source_route=0 |
| dmesg restricted to root | done | sysctl kernel.dmesg_restrict=1 |
| SUID core dumps off | done | sysctl fs.suid_dumpable=0 |
| Password max age 90 days | done | /etc/login.defs |
| Password expiry warning 14 days | done | /etc/login.defs |
| Auto security updates | done | unattended-upgrades |
| USB storage disabled | done | /etc/modprobe.d (cloud VM anyway) |
| Monitoring and alerts | done | Prometheus + Grafana from Lab 3 |
| Failed login metric | done | node_failed_ssh_logins_total |

## Not done

| Control | Why |
|---|---|
| Prometheus locked to my IP | Would need a reverse proxy, out of scope |
| MFA for SSH | Key-only is good enough here |
| Full CIS benchmark | Way out of scope, that's 200+ controls |
| Tripwire/AIDE | auditd covers the important files |
| Network segmentation | Single server, nothing to segment |
