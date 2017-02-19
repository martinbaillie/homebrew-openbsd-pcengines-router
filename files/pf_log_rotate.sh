#!/bin/sh
PFLOG=/var/log/pflog
FILE=/var/log/pflog5min.$(date "+%Y%m%d%H%M")

pkill -ALRM -u root -U root -t - -x pflogd
if [ -r "$PFLOG" ] && [ "$(stat -f %z $PFLOG)" -gt 24 ]; then
   mv $PFLOG $FILE
   pkill -HUP -u root -U root -t - -x pflogd
   tcpdump -n -e -s 160 -ttt -r $FILE | logger -t pf -p local0.info
   rm $FILE
fi
