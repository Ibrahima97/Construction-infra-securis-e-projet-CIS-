#!/bin/bash

#Decide user
USR_INCHARGE=cisnode
FILENAME=$1
if expr $1 : '.*/$';then
	FILENAME=$(expr substr $FILENAME 1 $(expr $(expr length $FILENAME) - 1))
fi
#echo $FILENAME
cd /home/$USR_INCHARGE
sudo -u $USR_INCHARGE ./onreceive.sh $FILENAME
