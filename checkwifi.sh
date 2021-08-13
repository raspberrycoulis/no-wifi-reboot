#!/bin/bash

# This pings the router 10 times, and if there is no response, it assumes  #
# the network is down so initiates a reboot of the Raspberry Pi            #

echo "Checking network..."
# Pick one below:
# 1. Ping a router
#ping -c10 192.168.1.254 > /dev/null
# 2. Ping Google
ping -c10 google.co.uk > /dev/null

if [ $? != 0 ]
then
  echo "No network connection! Rebooting... on`date +"%e %B %Y at %X"`" >> reboot.log
  sleep 5;
  sudo /sbin/shutdown -r now
else
  echo "Network is fine." >> /dev/null
fi
