#!/usr/local/bin/bash
set -euo pipefail

: "${CURL:=/usr/local/bin/curl}"

EXCLUSION_GREP=""
while read -r permitted; do
    [ -n "${permitted}" ] && EXCLUSION_GREP="${EXCLUSION_GREP} -e '${permitted}'"
done < /etc/adservers_permitted.db
[ -n "$EXCLUSION_GREP" ] && EXCLUSION_GREP="grep -v -i ${EXCLUSION_GREP}"

# Populate a new monster DB.
unset LANG && \
    for site in $(${CURL} --fail -s 'https://v.firebog.net/hosts/lists.php?type=tick'); do
        ${CURL} --fail -sL "${site}" || :;
    done | \
    tr -d '\r' | \
    sed -e 's/^127.0.0.1\s*//g; s/^0.0.0.0\s*//g; s/^0\s*//g; s/localhost//g' \
    -e 's/\s*#.*$//' -e '/^\s*$/d' -e $'s/\r//' | \
    sort | \
    uniq | \
    awk '{print $1}' | \
    sed '/^-/d; /^\./d; /^\s*$/d; /\.\./d' | \
    sort | \
    uniq | \
    eval "${EXCLUSION_GREP}" | \
    { 
        while read -r site; do 
            echo -e "local-zone: \"${site}\" refuse";
        done
    } > /etc/adservers.db

# Restart unbound.
chown _unbound:_unbound /etc/adservers.db
pkill -9 -u _unbound unbound
rcctl stop unbound
rcctl start unbound

# Warm up.
${CURL} -LIs www.google.com > /dev/null || ${CURL} -LIs www.google.com > /dev/null 
