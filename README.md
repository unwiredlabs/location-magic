# Location Magic
A simple way to track *unix devices

### How Location Magic locates your device
* Scripts in this repo, when run on your device, search for nearby WiFi access points and send us their BSSIDs (physical address)
* We then send this data to Unwired Labs' LocationAPI (https://unwiredlabs.com), a WiFi positioning service
* We plot the location Unwired Labs returns on a map, here: https://locationmagic.org/locate

### Installation Instructions for *unix devices
* Get a token from the Location Magic website
* Download the `locationmagic.sh` script from this repo
* Copy it to `/usr/local/bin` directory

		$ cp locationmagic.sh /usr/local/bin/  
* Make this script executable with `chmod +x`

		$ chmod +x /usr/local/bin/locationmagic.sh	
		
* Install it to your crontab to make it run every hour 

		$ crontab -e
		# Paste this there after replacing $platform with osx / linux and $token with your Location Magic token
		0 * * * * cd /usr/local/bin/ && ./locationmagic.sh -locate $platform $token
* Run it the first time manually

    $ cd /usr/local/bin/ && ./locationmagic.sh -locate $platform $token

* If all is well, you should be able to locate your device here: https://locationmagic.org/locate

### About this repository
This repo contains install scripts used on the Location Magic website.
