# No WiFi? Reboot!

This is a very simple bash script that pings a network device / a website of your choice, then initiates a reboot if there is no response - i.e. if the network is down.

Inspired by [this guide](https://weworkweplay.com/play/rebooting-the-raspberry-pi-when-it-loses-wireless-connection-wifi/), the code is as simple as this:

```bash
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
  echo -e "No network connection! Rebooting... on`date +"%e %B %Y at %X"`" >> /home/pi/no-wifi-reboot/reboot.log
  sleep 5;
  sudo /sbin/shutdown -r now
else
  echo -e "Network is fine." >> /dev/null
fi
```

The IP address in this instance is the router, so if this is unreachable it assumes the internal network is down, so triggers the Raspberry Pi to reboot. A log file is also created, called `reboot.log`.

## Running

Add the script as a cronjob (running every 5 minutes) by entering:

```shell
$ sudo crontab -e
```

Then add the following:

```bash
*/5 * * * * /usr/bin/sudo -H /home/pi/no-wifi-reboot/checkwifi.sh >> /home/pi/no-wifi-reboot/reboot.log 2>&1
```

## Check if the cronjob has run

To see if the cronjob has run the `checkwifi.sh` script, search the `syslog` with:

```shell
$ grep -i checkwifi.sh /var/log/syslog
```

If you see an entry, it has run successfully!
