# Residual Risk Analysis
**Name:** Althea Barbato

After applying all remediations in this lab, these are the risks that still exist and why I'm accepting them (or can't fix them given the scope of this class).

---

## Remaining risks

### Prometheus has no authentication (Accepted)

Prometheus's web UI and API are publicly accessible. Anyone who finds port 9090 can query any metric, see what's running on the server, and check alert state.

**Why I'm accepting this:** Prometheus has no built-in auth mechanism. The real fix is putting nginx in front of it with basic auth and TLS, which is out of scope here. The data it exposes is operational metrics, not credentials or application data. Oracle VCN is the outer network gate.

**What would fix it:** Add a nginx reverse proxy with basic auth in front of :9090 and block direct access to the port via iptables.

---

### Audit logs are not shipped off-server (Accepted)

auditd logs everything to /var/log/audit/audit.log on the same server. If an attacker got root they could clear or modify these logs before anyone saw them.

**Why I'm accepting this:** Shipping logs off-server would require setting up a remote syslog server or a cloud logging service, which is out of scope. For a production system this would be unacceptable — auditd is only useful as a forensic tool if the logs are immutable and stored elsewhere.

**What would fix it:** Configure auditd to forward to a remote syslog (rsyslog remote_host directive) or use a service like AWS CloudWatch Logs or Loki with remote write.

---

### No DDoS protection (Accepted)

A volumetric attack from many source IPs would overwhelm the server. Fail2ban only bans single IPs, it can't handle a distributed flood.

**Why I'm accepting this:** This is a free-tier Oracle instance. Real DDoS protection needs a CDN (Cloudflare, AWS Shield) in front of the server, which costs money and is out of scope for a class project.

---

### Monitoring ports accessible from any IP (Accepted with note)

Ports 3000, 3001, 9090, 9100, 9113 are open to 0.0.0.0/0 in both UFW and Oracle VCN. This is wider than necessary.

**Why I'm accepting this:** Restricting these to my home IP would break things every time my IP changes (ISPs reassign dynamic IPs). A VPN would be the right fix. Accepted because the data exposed is non-sensitive.

---

### Private key on local machine (Accepted)

The SSH private key (lab1-key.pem) lives on my laptop. If the laptop is compromised, an attacker gets server access.

**Why I'm accepting this:** It's a class project with no production data. In a real environment the key would be in a secrets manager (HashiCorp Vault, AWS Secrets Manager) and access would be audited.

---

## Overall risk posture

The server is reasonably hardened for its purpose:
- No password-based SSH login
- Automated brute-force blocking via fail2ban
- Audit logging on sensitive files
- Kernel network hardening applied
- Automatic security patches

The biggest actual risks are that logs live only on the server and that the monitoring ports are publicly accessible. Neither is a critical issue for a class project on a server with no user data, but both would be blockers in a real deployment.
