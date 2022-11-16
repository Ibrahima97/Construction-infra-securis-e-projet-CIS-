Incron on master
===============

run cron_conf.sh as root in order to configure incron to listen on every ~/jobs and calling /home/cisnode/onreceive.sh on each incoming package

For now always /home/cisnode/onreceive.sh is used, so $USER inside it will always be cisnode, change if required.
