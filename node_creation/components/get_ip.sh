#!/bin/bash

#get ip address of ethernet interface and stores it in MY_IP

MY_IP=$(ip addr | grep "enp0" | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/")
echo "'$(expr substr $MY_IP 1 $(expr $(expr length $MY_IP) - 1))'"


