#!/bin/bash
# runs a series of security checks against webserver01 and reports pass/fail

SERVER_IP="163.192.117.50"
SSH_KEY="$HOME/.ssh/lab1-key.pem"
SSH_OPTS="-i $SSH_KEY -o StrictHostKeyChecking=no -o ConnectTimeout=10"

PASS=0
FAIL=0

check() {
    local label="$1"
    local result="$2"
    if [[ "$result" == "ok" ]]; then
        echo "  [PASS] $label"
        PASS=$((PASS + 1))
    else
        echo "  [FAIL] $label ($result)"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== SSH Hardening ==="
root_login=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "grep -i '^PermitRootLogin' /etc/ssh/sshd_config | awk '{print \$2}'")
check "PermitRootLogin no" "$( [[ "$root_login" == "no" ]] && echo ok || echo "got: $root_login" )"

pw_auth=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "grep -i '^PasswordAuthentication' /etc/ssh/sshd_config | awk '{print \$2}'")
check "PasswordAuthentication no" "$( [[ "$pw_auth" == "no" ]] && echo ok || echo "got: $pw_auth" )"

max_auth=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "grep -i '^MaxAuthTries' /etc/ssh/sshd_config | awk '{print \$2}'")
check "MaxAuthTries <= 3" "$( [[ "$max_auth" -le 3 ]] && echo ok || echo "got: $max_auth" )"

x11=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "grep -i '^X11Forwarding' /etc/ssh/sshd_config | awk '{print \$2}'")
check "X11Forwarding no" "$( [[ "$x11" == "no" ]] && echo ok || echo "got: $x11" )"

echo ""
echo "=== Firewall ==="
ufw_status=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo ufw status | head -1 | awk '{print \$2}'")
check "UFW active" "$( [[ "$ufw_status" == "active" ]] && echo ok || echo "not active" )"

echo ""
echo "=== Fail2ban ==="
f2b=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo systemctl is-active fail2ban")
check "fail2ban running" "$( [[ "$f2b" == "active" ]] && echo ok || echo "$f2b" )"

f2b_jail=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo fail2ban-client status sshd 2>/dev/null | grep 'Currently banned' | awk '{print \$NF}'")
check "fail2ban sshd jail active" "$( [[ -n "$f2b_jail" ]] && echo ok || echo "jail not found" )"

echo ""
echo "=== Auditd ==="
auditd=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo systemctl is-active auditd")
check "auditd running" "$( [[ "$auditd" == "active" ]] && echo ok || echo "$auditd" )"

audit_rules=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo auditctl -l 2>/dev/null | grep -c passwd || echo 0")
check "audit rules loaded (watching /etc/passwd)" "$( [[ "$audit_rules" -ge 1 ]] && echo ok || echo "no rules" )"

echo ""
echo "=== Kernel Hardening ==="
syncookies=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sysctl -n net.ipv4.tcp_syncookies")
check "tcp_syncookies enabled" "$( [[ "$syncookies" == "1" ]] && echo ok || echo "got: $syncookies" )"

rp_filter=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sysctl -n net.ipv4.conf.all.rp_filter")
check "rp_filter enabled" "$( [[ "$rp_filter" == "1" ]] && echo ok || echo "got: $rp_filter" )"

redirects=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sysctl -n net.ipv4.conf.all.accept_redirects")
check "accept_redirects disabled" "$( [[ "$redirects" == "0" ]] && echo ok || echo "got: $redirects" )"

echo ""
echo "=== Auto Updates ==="
uu=$(ssh $SSH_OPTS "sysadmin@$SERVER_IP" "sudo systemctl is-active unattended-upgrades")
check "unattended-upgrades running" "$( [[ "$uu" == "active" ]] && echo ok || echo "$uu" )"

echo ""
echo "=== Root Login Blocked ==="
root_blocked=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes root@"$SERVER_IP" echo ok 2>&1 || true)
check "root SSH login blocked" "$( echo "$root_blocked" | grep -q "denied\|Permission\|publickey" && echo ok || echo "root login may be open" )"

echo ""
echo "done $PASS passed, $FAIL failed"
