#import built in modules
import socket
import sys
import os
 
#--some Variables----
#this can be an ip or a name. use [''] instead if you want to listen on any
#address. this is useful when the server has multiple interfaces
host_addr='16.83.185.26'
portNum=10000
#Create a file and log all the client BMC IP
 
print('starting server on '+ str(portNum))
print('server address : '+ str(host_addr))
 
# create a TCP/IP socket
sock=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
 
#Bind the socket to the port
socket_address = (host_addr,portNum)
sock.bind(socket_address)
 
#Calling listen() puts the socket into server mode
sock.listen(5)
 
while True:
	# wait for a connection
	print('waiting for a connection')
#accept() returns an open connection between the server and client
#along with the address of the client.
	connection,client_address=sock.accept()
	try:
		print('connection from: '+ str(client_address))
		#receive the data in small chunks and retransmit it
		while True:
			file = open("BMCIP.txt", "a+")
			print('----------------------------------------')
			#data=connection.recv(16)
			data=connection.recv(128)
			if data:
				#print('received: '+ data.decode())
				#print('sending data back to client')
				file.writelines(data)
				file.close()
				connection.sendall(data)
			else:
				print('no more data from '+ str(client_address))
				break
	finally:
		#clean up the connection
		connection.close
