#!/bin/sh
/usr/local/bin/curl -Ls 'https://pgl.yoyo.org/adservers/serverlist.php?hostformat=unbound&showintro=0&startdate%5Bday%5D=&startdate%5Bmonth%5D=&startdate%5Byear%5D=&mimetype=plaintext' -o /etc/adservers.db >/dev/null
/usr/sbin/unbound-control reload
