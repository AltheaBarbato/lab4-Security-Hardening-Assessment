# Residual Risk Analysis
**Name:** Althea Barbato

Stuff that's still a risk after this lab and why I'm leaving it for now.

---

## Prometheus has no auth

Anyone can hit port 9090 and query metrics. No login, nothing.

Prometheus just doesn't have built-in auth, the fix is putting a reverse proxy in front of it which is more work than makes sense for a class project. The data it exposes is metrics not credentials so it's not the worst thing. Oracle VCN is the only gate on that port.

To actually fix it: nginx in front of 9090 with basic auth, block direct port access via iptables.

---

## Audit logs only live on the server

auditd writes to /var/log/audit/audit.log on the same machine. If someone got root they could just delete those logs.

Shipping logs somewhere else needs a remote syslog setup or a cloud logging service, neither of which I'm setting up for this. In a real job this would be a requirement not a nice-to-have.

To fix: rsyslog forwarding to a remote host, or Loki with remote write.

---

## No DDoS protection

A flood from a lot of IPs at once would just knock the server over. Fail2ban bans single IPs so it doesn't help here.

Free tier Oracle instance. Cloudflare or AWS Shield would fix this but they cost money.

---

## Monitoring ports open to the whole internet

Ports 3000, 3001, 9090, 9100, 9113 are all open to 0.0.0.0/0. Wider than it needs to be.

My home IP changes so locking it down to just my IP would constantly break things. A VPN is the real fix. Not doing it for now since nothing sensitive is exposed on those ports.

---

## SSH key on my laptop

lab1-key.pem is sitting on my local machine. If my laptop got stolen or hacked, someone has the key.

It's a class project so I'm not stressing about this. Real setup would use a secrets manager.

---

## Where things stand

Server is in decent shape for what it is. Key-only SSH, fail2ban running, auditd watching the important files, kernel hardening applied, auto patches on.

The two things I'd actually fix before putting anything real on this server: get logs off the server, and put auth in front of Prometheus.
