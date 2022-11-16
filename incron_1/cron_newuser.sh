#!/bin/bash

USERNAME=$1
if expr $USERNAME : '.*/$';then
	USERNAME=$(expr substr $USERNAME 1 $(expr $(expr length $USERNAME) - 1));
fi
useradd $USERNAME --create-home
mkdir /home/$USERNAME/.ssh
mv /home/anonymous_user/newuser/$1 /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME /home/$USERNAME/.ssh
chmod -R 600 /home/$USERNAME/.ssh
