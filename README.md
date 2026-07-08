# Security Hardening Assessment
**Name:** Althea Barbato

Formal security assessment of `webserver01` (163.192.117.50) built across Labs 1-3. Identifies vulnerabilities, applies remediations via Ansible, and documents the remaining risk.

## What this does

- Installs and configures auditd with rules watching /etc/passwd, /etc/shadow, sshd_config, and sudoers
- Tightens SSH config (MaxAuthTries 3, no X11, no agent forwarding, idle timeout 5 min)
- Hardens kernel sysctl (SYN cookies, rp_filter, no redirects)
- Configures fail2ban with stricter ban settings
- Sets password aging policy
- Enables automatic security updates

## Running it

```bash
bash deploy.sh --check
bash deploy.sh
bash scripts/scan.sh
```

## Docs

| File | What it covers |
|---|---|
| docs/vulnerability-report.md | 5 vulnerabilities found, severity, remediations |
| docs/hardening-checklist.md | Full control checklist with status |
| docs/threat-model.md | STRIDE analysis, attack surfaces by port |
| docs/residual-risk.md | What's still exposed and why |

## Scan results

`bash scripts/scan.sh` connects to the server and checks 14 controls. Should show all passing after deploy.
