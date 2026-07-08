# Residual Risk Analysis
**Name:** Althea Barbato

These are the risks still left after everything in this lab got applied, and why I'm not fixing them right now.

---

## Remaining risks

### Prometheus has no authentication (Accepted)

Prometheus's web UI and API are publicly accessible. Anyone who finds port 9090 can query metrics, see what's running on the server, and check alert state without logging in.

**Why I'm accepting this:** Prometheus has no built-in auth. The real fix is putting nginx in front of it with basic auth and TLS, which is out of scope here. The data it exposes is operational metrics, not credentials or app data. Oracle VCN is the only network gate right now.

**What would fix it:** nginx reverse proxy with basic auth in front of port 9090, then block direct access to 9090 via iptables.

---

### Audit logs are not shipped off-server (Accepted)

auditd logs everything to /var/log/audit/audit.log on the same server. If an attacker got root they could clear those logs before anyone saw them.

**Why I'm accepting this:** Shipping logs off-server needs a remote syslog or cloud logging service, which is out of scope. For a real production system this would be a blocker since audit logs are only useful for forensics if they're somewhere the attacker can't touch.

**What would fix it:** Configure rsyslog to forward to a remote host, or use something like Loki with remote write enabled.

---

### No DDoS protection (Accepted)

A volumetric attack from many IPs at once would overwhelm the server. Fail2ban only bans individual IPs so it can't handle a distributed flood.

**Why I'm accepting this:** Free-tier Oracle instance. Real DDoS protection needs a CDN like Cloudflare or AWS Shield in front, which costs money and is out of scope for a class.

---

### Monitoring ports open to any IP (Accepted with note)

Ports 3000, 3001, 9090, 9100, 9113 are open to 0.0.0.0/0 in UFW and Oracle VCN. Wider than necessary.

**Why I'm accepting this:** Locking these down to my home IP would break every time my ISP reassigns my IP. A VPN would be the right fix. Accepted because the exposed data isn't sensitive.

---

### Private key lives on my laptop (Accepted)

The SSH private key (lab1-key.pem) is on my local machine. If the laptop got compromised, someone gets server access.

**Why I'm accepting this:** Class project, no production data. In a real setup the key would live in a secrets manager like HashiCorp Vault or AWS Secrets Manager with access logging.

---

## Overall posture

The server is reasonably hardened for what it is:
- No password SSH login
- Fail2ban blocking brute force
- Auditd logging changes to sensitive files
- Kernel network hardening in place
- Automatic security patches running

The two biggest actual gaps are that logs only live on the server and that monitoring ports are world-accessible. Neither is critical for a class project with no real user data, but both would need to be fixed before running anything in production.
