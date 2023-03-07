#!/usr/bin/env python
### Made using proeject from github
### Orginal Project - furkanmustafa - iwscan.py
### https://gist.github.com/furkanmustafa/cf32f9ed2a3181486b00
###

import subprocess 
import os
import sys
import re
import json
import requests

#Read Config File
import wpSettings as s
#Check if running as ROOT
if not os.geteuid() == 0:
    sys.exit('wlanpos must be run as root because of use of network card')

def main():

    #Get Networks
    iw = ['iwlist', s.wint, 'scan']
    wlist = subprocess.Popen(iw, shell=False, stdout=subprocess.PIPE,)
    stdout_str = wlist.communicate()[0].decode('utf-8')
    stdout_list = stdout_str.splitlines()
    
    #URL
    gurl = 'https://us1.unwiredlabs.com/v2/process.php'
    headers = {'content-type': 'application/json'}


    ##Read Lines and get variables
    networks = []
    network = {}
    for line in stdout_list:
        line = line.strip()
        #Get BSSID 
        match = re.search('Address: (\S+)',line)
        if match:
            if len(network):
                networks.append(network)
            network = {}
            network["bssid"] = match.group(1)

        #Get Signal Strength
        match = re.search('Signal level=([0-9-]+) dBm',line)
        if match:
            network["signal"] = match.group(1)

        #Get Channel Number
        match = re.search('Channel:([0-9]+)',line)
        if match:
            network["channel"] = match.group(1)

    ## Append Network to Networks
    if len(network):
            networks.append(network)

	    #Append Networks to 'WifiAccessPoints' and send HTTP-POST
            response = requests.post(gurl, data=json.dumps({'token' : s.apikey , 'wifi': networks}, sort_keys=True, indent=4), headers=headers)
		
            #Print the response
            print (json.dumps(json.loads(response.text), sort_keys=True, indent=4))
if __name__ == '__main__':
    main()
