#!/usr/local/bin/python2.7
import os
import string 
import re
import argparse
import sys
import subprocess

# Function retrieves the serial number of system
def findSerial(): 
    serial_num = os.popen('dmidecode -s system-serial-number').read()

    return serial_num

# Function retrieves the product name 
def findProdName():
    prod_name = os.popen('dmidecode -s system-product-name').read()

    return prod_name

# Function retieves the BMCIP name
def findBmcNic():
    cmd = "ipmitool lan print | grep -i 'IP Address'|tail -1|cut -d ':' -f2"
    p1=subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,close_fds=False)
    output=p1.communicate()[0]
    Bmcip=output.strip('\n')
    Bmcip=''.join(filter(None,Bmcip.split(' ')))
	
    return Bmcip

	
# Runs routine #3 
def getActiveNic(sflg):
##====================
## sflg = 'mac' | null | 0 , return active mac
## sflg = 'ip' | 1, return active mac IP

##===================
    #contents = os.popen('ifconfig').read() 
    #eth = re.findall(r'eth', contents)  # Returns all instances of 'eth' in the contents of ifconfig 

    nic_ary = []
    nics = subprocess.Popen(["ls /sys/class/net/"],stdout=subprocess.PIPE, shell=True)
    (devices,rc) = nics.communicate()
    nic_ary = devices.split("\n")   #nics on system are in nic_ary

    

    index = ''  # Keeps track of the index of active MAC address

#    for x in range(0, len(eth)): 
    for x in nic_ary:
	nstr = x.strip('\n')
	if  nstr != 'lo' and nstr != '\n' and len(nstr) != 0:
#        	curr_state = os.popen('cat /sys/class/net/eth' + str(x) + '/operstate').read()
        	curr_state = os.popen('cat /sys/class/net/' + nstr + '/operstate').read()
        	curr_state = curr_state.rstrip("\n")
        	if curr_state == 'up':
            		index = x
			break

    if index != '':
#        mac = os.popen('cat /sys/class/net/eth' + str(index) + '/address').read()  # MAC address of active NIC  
        mac = os.popen('cat /sys/class/net/' + index + '/address').read()  # MAC address of active NIC  
        mac = mac.rstrip("\n")
    else: # If active nic could not be found then mac address is null 
        mac = "None"

    nodeIP = "" 
    if mac != "None":
	xcmd = "ifconfig " + index
	contents = os.popen(xcmd).read()
	nodeIP = re.findall(r'\d+\.\d+\.\d+\.\d+',contents)
	#print nodeIP
    else: 
	nodeIP = re.findall(r'\d+\.\d+\.\d+\.\d+',"None")
        #print "|", len(nodeIP), "|"

    if sflg.lower() == "ip" or sflg == "1":
        if ( len(nodeIP) > 0 ):
	    return str(nodeIP[0])
        else:
            return "None"
    else:
	return mac 
    

# Runs routine #1 
def getSerialNum():
    serial_num = findSerial()

    serial_num = str(serial_num)
    serial_num = serial_num.replace(" ", "") # Removes all spaces within serial number
    serial_num = serial_num.rstrip("\n")

    # Runs all checks on serial number
    blank = checkBlank(serial_num) 
    null = checkNull(serial_num)
    chars = checkChars(serial_num)
    size = checkLength(9, serial_num)

# Creates new serial number and outputs value and error message if invalid
    if  blank or  null or not size or not chars: 
        serial_num = makeSerial('AXA')
            
    return serial_num 

# Runs routine #2
def getProdName():
    prod_name = findProdName()

    prod_name = prod_name.rstrip(" ")
    prod_name = prod_name.rstrip("\n")

    blank = checkBlank(prod_name)
    size = checkLength(3, prod_name)
    null = checkNull(prod_name)

    if  blank or null or not size: 
        prod_name = "AutoMAT Server 1999" 

    return prod_name


# Gets active NIC MAC address and puts it in serial number format
def makeSerial(prefix):
    mac = getActiveNic('mac')

    # If active NIC is not there, use the address of eth0
    if mac == "None": 
#        mac = os.popen('cat /sys/class/net/eth0/address').read()
	nic_ary = []
	nics = subprocess.Popen(["ls /sys/class/net/"],stdout=subprocess.PIPE, shell=True)
	(devices,rc) = nics.communicate()
	nic_ary = devices.split("\n")   #nics on system are in nic_ary
	firstnic = nic_ary[0].strip('\n')
	xcmd = 'cat /sys/class/net/' + firstnic + '/address'
	mac = os.popen(xcmd).read()



    mac = mac.rstrip("\n")
    mac = mac.replace(":", "")
    mac = prefix + mac
    mac = mac.upper()

    return(mac)

# Makes sure the string isn't all blanks
def checkBlank(strng): 
    blank = True 

    for char in strng: 
        if char != " ":
            blank = False

    return blank

def checkNull(strng): 
    is_null = False

    lower_string = strng.lower()
    if lower_string == 'null' or  lower_string == None or lower_string == 'none':
        is_null = True

    return is_null

# Determines if chars in string are valid (A-Z, a-z, 0-9, -, _)
def checkChars(strng):
    allowed_chars = set(string.ascii_letters + string.digits + '-' + '_')
    valid = set(strng) <= allowed_chars 

    return valid 

# Checks whether string is greater than or equal to size 
def checkLength(size, strng): 
    valid = False
    spaceless = strng.replace(" ", "")

    if len(spaceless) > size: 
        valid = True 

    return valid


if __name__ == '__main__':
  
    # Creates menu for testing reasons
    parser = argparse.ArgumentParser()
    parser.add_argument('-s','--serial_num',  help = 'Check serial number of machine', action = 'store_true')
    parser.add_argument('-p', '--product_name', help = 'Check product name of machine', action = 'store_true')
    parser.add_argument('-n', '--network_information',  help = 'Retrieve active NIC MAC address', action = 'store_true')
    parser.add_argument('-i', '--ip_information',  help = 'Retrieve active IP address', action = 'store_true')
    parser.add_argument('value', nargs = '?',  help = 'Value for serial number or product name')
    args = parser.parse_args()
   
    # Determines which tag was entered 
    if args.serial_num:
        serial = getSerialNum()
        print serial
    elif args.product_name:
#        product = getProdName(args.value)
        product = getProdName()
        print product
    elif args.network_information: # Go and return the active NIC MAC address
        mac = getActiveNic('mac') 
        print mac
    elif args.ip_information: # Go and return the active IP address
        aip = getActiveNic('ip') 
        print aip

