#!/bin/sh
## This pings the router / a website 10 times, and if there is no response, it assumes  ##
## the network is down so repairs the DHCP client then restarts the SSH service.        ##

## Set the log file location and name
logPath=/home/pi/no-wifi-reboot/logs
logFile=repair.log

## Specify your ping target - default is Google's public IP address
ping_target=8.8.8.8

## Create a log file if one is not already found
find "$logPath/" -type f -size +512k -name "$logFile" -exec rm -rf {} \;
if [ ! -f "$logPath/$logFile" ]; then
  echo "`date +"%e %B %Y at %X"`: Creating new logfile: $logPath/$logFile"
  touch "$logPath/$logFile"
else
  echo "`date +"%e %B %Y at %X"`: Existing log file found."
fi

## Main code
echo "`date +"%e %B %Y at %X"`: Checking network..."
ping -q -c 10 $ping_target > /dev/null
if [ $? -eq 0 ]; then
  echo "`date +"%e %B %Y at %X"`: Network is fine!"
else
  echo "`date +"%e %B %Y at %X"`: No network connection! Repairing..."
  ## If the connectivity check fails, this repairs the DHCP client service...
  sudo dhclient -r eth0; sudo dhclient eth0 > /dev/null
  ## ... sleeps for 15s...
  sleep 15
  ## ... then restarts the SSH service.
  sudo systemctl restart sshd
  echo "`date +"%e %B %Y at %X"`: Network should be repaired!"
  exit
fi
