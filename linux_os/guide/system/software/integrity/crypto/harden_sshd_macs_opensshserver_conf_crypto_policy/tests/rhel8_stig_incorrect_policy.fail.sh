#!/bin/bash
# platform = Oracle Linux 8,Red Hat Enterprise Linux 8
# variables = sshd_approved_macs=hmac-sha2-512,hmac-sha2-256,hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
=stig_extended

configfile=/etc/crypto-policies/back-ends/opensshserver.config

# Ensure directory + file is there
test -d /etc/crypto-policies/back-ends || mkdir -p /etc/crypto-policies/back-ends

if [[ -f $configfile ]]; then
    sed -i -r "s/-oMACs=\S+/-oMACs=hmac-sha2-256-etm@openssh.com,hmac-sha1-etm@openssh.com/" $configfile
else
    echo "-oMACs=hmac-sha2-256-etm@openssh.com,hmac-sha1-etm@openssh.com" > "$configfile"
fi
