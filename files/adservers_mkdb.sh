#!/usr/bin/env bash
set -euo pipefail

# Populate a new monster DB
unset LANG && \
    for site in $(curl --fail -s 'https://v.firebog.net/hosts/lists.php?type=tick'); do
        curl --fail -sL "${site}" || :;
    done | \
    sed -e 's/^127.0.0.1\s*//g; s/^0.0.0.0\s*//g; s/^0\s*//g; s/localhost//g' \
    -e 's/\s*#.*$//' -e '/^\s*$/d' -e $'s/\r//' | \
    sort | \
    uniq | \
    awk '{print $1}' | \
    sed '/^-/d; /^\./d; /^\s*$/d; /\.\./d' | \
    sort | \
    uniq | \
    { 
        while read -r site; do 
            echo -e "local-data: \"${site} A 127.0.0.1\"\\nlocal-zone: \"${site}\" redirect";
        done
    } > /etc/adservers.db
# OLD
#/usr/local/bin/curl -Ls 'https://pgl.yoyo.org/adservers/serverlist.php?hostformat=unbound&showintro=0&startdate%5Bday%5D=&startdate%5Bmonth%5D=&startdate%5Byear%5D=&mimetype=plaintext' -o /etc/adservers.db >/dev/null

# Restart unbound
chown _unbound:_unbound /etc/adservers.db
pkill -9 -u _unbound unbound
rcctl stop unbound
rcctl start unbound

# Warm up
curl -LIs www.google.com > /dev/null || curl -LIs www.google.com > /dev/null 
