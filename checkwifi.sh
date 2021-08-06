#!/bin/bash

# This pings the router 10 times, and if there is no response, it assumes  #
# the network is down so initiates a reboot of the Raspberry Pi            #

echo "Checking network..."
ping -c10 192.168.1.254 > /dev/null

if [ $? != 0 ]
then
  echo "No network connection! Rebooting... on`date +"%e %B %Y at %X"`" >> reboot.log
  sleep 5;
  sudo /sbin/shutdown -r now
else
  echo "Network is fine."
fi
