#import built in modules
import socket
import sys
import subprocess 


from Routines import getSerialNum
from Routines import getProdName
from  Routines import getActiveNic
from  Routines import findBmcNic

#--some Variables-----------------------------------
#ip or name of the remote server
server_addr='16.83.185.26'
portNum=10000

#Get product information to send to the server
BmcIP=findBmcNic()
SerialNum=getSerialNum()
ProdName=getProdName()
ActiveIP=getActiveNic('ip')
ActiveMac=getActiveNic('MAC')
message=SerialNum+'|'+ProdName+'|'+ActiveIP+'|'+ActiveMac+'|'+BmcIP+'\n'

#print('connecting to port '+str(portNum)+' on '+server_addr)
#print('message',message) 
#create a tcp/ip socket
sock=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
 
#connect the socket to the port where the server is listening
socket_address=(server_addr,portNum)
sock.connect(socket_address)
 
try:
	#send data. this is a string converted to byte code
	#message=b'hello? Blah BLah BLAH BLAH BLAH BLAH'
	# .decode decodes byte code to utf-8
	#print('sending: '+message.decode())
	#print('sending: '+output.decode())
	#sock.sendall(message)
	#sock.sendall(output)
	sock.sendall(message)
 
	#look for the response
	amount_received=0
	#amount_expected=len(message)
	#amount_expected=len(output)
	amount_expected=len(message)
 
	while amount_received<amount_expected:
		data=sock.recv(16)
		amount_received+=len(data)
		print('received: '+data.decode())
 
finally:
	print('closing socket')
	sock.close()
