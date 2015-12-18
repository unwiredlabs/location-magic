#!/bin/bash

##############################################################
# Powered-By: Unwired Labs                                   #
# Version 1.2                                                #
# run as ./locationmagic.sh -locate [PLATFORM] [TOKEN]       #
##############################################################

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

set -e

version=1.2

echo "Welcome to LocationMagic " + $version + "
...a simple way to track your *nix device.


Use this script to install / locate / uninstall the LocationMagic cron from your system"

inputargs=$1
platform=$2
token=$3
stamp=$(date)
log_file=/var/log/locationmagic/locationmagic.log

HELP="Usage: <script> <function> <platform> <token>
 Functions:
 -install   = install the script
 -uninstall = unintsall the script
 -locate    = locate the device

Platform:
osx   = for MacBooks
linux = for Linux (Ubuntu, Raspberry Pi, Arduino etc)

Token = your token generated at https://locationmagic.org

Examples:
To install   = ./locationmagic.sh -install osx xyz12345aabbcc
To uninstall = ./locationmagic.sh -uninstall
To locate    = ./locationmagic.sh -locate osx xyz12345aabbcc
"

if [ "$inputargs" = "-install" ] || [ "$inputargs" = "-locate" ]
then
	if [ ! -f /usr/local/bin/locationmagic.sh ]; then
		echo "Copying script to /usr/local/bin.."
        	mkdir -p /usr/local/bin
		cp locationmagic.sh /usr/local/bin/
		chmod +x /usr/local/bin/locationmagic.sh
	fi

	if [ ! -f /var/log/locationmagic/locationmagic.log ]; then
		mkdir -p /var/log/locationmagic
		echo "Initializing log file in /var/log/locationmagic/locationmagic.log"
		touch /var/log/locationmagic/locationmagic.log
		chmod 755 /var/log/locationmagic/locationmagic.log
	fi

	if [ "$inputargs" = "-install" ]; then
		if [ "$platform" != "osx" ] && [ "$platform" != "linux" ]
		then
			echo "ERROR Invalid platform.. has to be 'osx' or 'linux', sorry!"
			exit
		fi
		echo "Backing up crontab.."
		crontab -l > crontab_$(whoami).backup
		echo "Adding script to run every hour"
		($(crontab -l > file; echo "0 * * * * cd /usr/local/bin/ && ./locationmagic.sh -locate $platform $token" >> file | sort file | uniq file | crontab -))
		echo "All done!"
		echo $stamp" Installed Successfully" >> $log_file
	fi

	echo "Searching for WiFi networks.."
	if [ "$platform" = "osx" ]; then
		list=($(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s |  egrep -o '([a-f0-9]{2}:){5}[a-f0-9]{2}'))
	elif [ "$platform" = "linux" ]; then
		interface=($(ifconfig | grep wlan | awk '{print $1}'))
		list=($(iwlist "$interface" scanning | grep Address | awk '{print $5}'))
	else
		echo "Invalid platform / OS selected.. Proceeding with IP address based location"
		list[0]=""
	fi

	if [[ ! $list ]]; then
		echo "Wifi is disabled or there are no WiFis nearby. Proceeding with IP address based location"
		list[0]=""
	fi

	echo "Sending location data to Location Magic.."

	input+='https://locationmagic.org/geosubmit?'
	input+="token=$token"
	input+="&v=$version&w="

	for i in "${list[@]}"
	do
	   :
	  input+="$i"','
	done

	input="${input%?}"

	output=$(curl --silent $input)

	echo $output

	echo $stamp $output >> $log_file

	echo "Installation complete.."

elif [ "$inputargs" = "-uninstall" ]
then
	comment=($(crontab -l | sed "/^[^#].*locationmagic.sh*/s/^/#/" | crontab - ))
	sudo rm /usr/local/bin/locationmagic.sh
	echo "Uninstalled successfully"
	echo $stamp" Uninstalled Successfully" >> $log_file
else
	echo "$HELP"
fi
