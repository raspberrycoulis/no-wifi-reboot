# No WiFi? Reboot!

This is a very simple bash script that pings a network device / a website of your choice, then initiates a reboot if there is no response - i.e. if the network is down.

Inspired by [this guide](https://weworkweplay.com/play/rebooting-the-raspberry-pi-when-it-loses-wireless-connection-wifi/) and [this script](https://github.com/raspberrypi/linux/issues/3034#issuecomment-723420437). The code is as simple as this:

## Check then reboot
This version will check for network connectivity and initiate a reboot if there are issues:

```bash
#!/bin/bash

## This pings the router / a website 10 times, and if there is no response, it assumes  ##
## the network is down so initiates a reboot of the Raspberry Pi                        ##

## Set the log file location and name
logPath=/home/pi/no-wifi-reboot/logs
logFile=reboot.log

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
  echo "`date +"%e %B %Y at %X"`: No network connection! Rebooting..."
  ## Sleep for 5s...
  sleep 5
  ## ... now reboot!
  sudo /sbin/shutdown -r now
  exit
fi

```

## Check then repair
This version will check for network connectivity and attempts to repair / restart the affected services:

```bash
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
  sudo dhclient -r; sudo dhclient > /dev/null
  ## ... sleeps for 15s...
  sleep 15
  ## ... then restarts the SSH service.
  sudo systemctl restart sshd
  echo "`date +"%e %B %Y at %X"`: Network should be repaired!"
  exit
fi
```

## Running

Add the script as a cronjob (running every 5 minutes) by entering:

```shell
$ sudo crontab -e
```

Then add the following:

```bash
*/5 * * * * /usr/bin/sudo -H /home/pi/no-wifi-reboot/check-then-reboot.sh >> /home/pi/no-wifi-reboot/logs/check-then-reboot.log 2>&1
```

or for the repair script:

```bash
*/5 * * * * /usr/bin/sudo -H /home/pi/no-wifi-reboot/check-then-repair.sh >> /home/pi/no-wifi-reboot/logs/check-then-repair.log 2>&1
```

## Check if the cronjob has run

To see if the cronjob has run the appropriate script, search the `syslog` with, substituting `****` with the `pair` or `boot`:

```shell
$ grep -i check-then-re****.sh /var/log/syslog
```

If you see an entry, it has run successfully!
