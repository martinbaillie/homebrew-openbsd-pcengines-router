#!/bin/sh
DB="/etc/bogons.db"
/usr/local/bin/curl -Ls https://www.team-cymru.org/Services/Bogons/fullbogons-ipv4.txt -o "${DB}" >/dev/null
pfctl -v -t bogons -T replace -f "${DB}"
