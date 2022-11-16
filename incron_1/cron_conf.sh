#!/bin/bash

cd $(dirname $0);
PATH+=:/usr/sbin
service incron stop
if ! cp cron_root.sh /root; then
    echo "Error: cron_root.sh not found" >&2;
    chmod +x /root/cron_root.sh;
    exit -1;
fi
if ! cp cron_newuser.sh /root; then
    echo "Error: cron_newuser.sh not found" >&2;
    chmod +x /root/cron_newuser.h;
#     exit -1;
fi
if ! cp new_user.sh /home/anonymous_user/; then
	echo "Error..." >&2
	chmod 555 /home/anonymous_user/new_user.sh
fi
if ! cp incron_rule /etc/incron.d/; then
    echo "Error: incron_rule not found" >&2;
    exit -1;
fi
echo -e "root\ncisnode" > /etc/incron.allow;
service incron start
exit $?;
