#!/bin/bash

## This pings the router / a website 10 times, and if there is no response, it assumes  ##
## the network is down so initiates a reboot of the Raspberry Pi                        ##

echo -e "Checking network..." >> /dev/null
## Pick one below:
# 1. Ping a router
#ping -c10 192.168.1.254 >> /dev/null
## 2. Ping Google
ping -c10 google.co.uk >> /dev/null

if [ $? != 0 ]
then
  echo -e "No network connection! Rebooting... on `date +"%e %B %Y at %X"`" >> /home/pi/no-wifi-reboot/reboot.log
  sleep 5;
  sudo /sbin/shutdown -r now
else
  echo -e "Network is fine." >> /dev/null
fi
