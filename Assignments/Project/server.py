import asyncio
import aiohttp
import async_timeout
import json
import client
import sys
import configuration
import time
import logging


# Globals for the server initiated
loop = asyncio.get_event_loop()
nameOfServer = sys.argv[1]
serverPort = configuration.PORT_NUMS[nameOfServer]
URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={0}&radius={1}&key=AIzaSyC-tfrRtq4VBwbiySjc5CHXKUPRitNTXyQ'
clientDict = dict()
fileName = nameOfServer + '.log'
logging.basicConfig(filename=fileName,level=logging.DEBUG)
logging.info("Server {} created".format(nameOfServer))

#implementation of server class
class EchoServerClientProtocol(asyncio.Protocol):

	#if connection is made
	def connection_made(self, transport):
		peername = transport.get_extra_info('peername')
		self.transport = transport
		logging.info("Connected to server {}".format(nameOfServer))

	# functions that check for valid input
	def checkValidIAMAT(self,command):
		try:
			float(command)
			return True
		except ValueError:
			return False

	def hasPlusMinus(self,command):
		print (command)
		if not (command[0] == '+'):
			return False
		elif not ('-' in command):
			return False
		return True

	def checkValidWHATSAT(self,command):
		if not command[1] in clientDict:
			return False
		elif len(command) != 4:
			return False
		elif int(command[2]) > 50 or int(command[3]) > 20:
			return False
		elif not(command[2].isdigit()) or (command[3].isdigit()):
			return False
		return True

	# functions that make JSON request
	async def fetch(self,session, url):
		with async_timeout.timeout(10):
			async with session.get(url) as response:
				return await response.text()

	async def parseJSON(self,radius,clientID):
		clientInfo = clientDict[clientID]
		locationReformatted = self.formatLocation(clientInfo[0])
		outPutMsgStr = "AT {0} {1} {2} {3} {4}\n".format(nameOfServer,clientInfo[2],clientID,clientDict[clientID][0],clientInfo[3])
		async with aiohttp.ClientSession() as session:
			call = URL.format(locationReformatted,radius)
			html = await self.fetch(session,call)
			#JSON formatting
			data_json = json.loads(html)
			limit_results = data_json["results"][0:int(radius)]
			data_json["results"] = limit_results
			outPutMsgStr = ("{}\n{}\n\n".format(outPutMsgStr, json.dumps(data_json, sort_keys=True,indent=4,separators=(',',': '))))
			outPutMsg = bytes(outPutMsgStr, 'utf-8')
			self.transport.write(outPutMsg)

	def formatLocation(self,location):
		sign = "+"
		if "-" in location[1:]:
			sign = "-"
		position = location[1:].index(sign) + 1
		returnStr = location[0:position] + "," + location[position:]
		returnStr.replace("+","")
		return returnStr

	# parsing client's request message
	def data_received(self, command):
		logging.info("Received command {} from client".format(command))        		
		try:
			command = command.decode()
			input = command.split(' ')
			if(input[0] == 'IAMAT'):
				if (len(input) != 4 or not self.checkValidIAMAT(input[3]) or not self.hasPlusMinus(input[2])):
					outPutMsgStr = "? {}\n".format(command)
					outPutMsg = bytes(outPutMsgStr, 'utf-8')
					self.transport.write(outPutMsg)
				else:
					self.updateClientLocation(input[1],input[2],float(input[3]))

			elif(input[0] == 'WHATSAT'):
				if not self.checkValidWHATSAT(input):
					outPutMsgStr = "? {}\n".format(command)
					outPutMsg = bytes(outPutMsgStr, 'utf-8')
					self.transport.write(outPutMsg)
				else:
					print("making GET request!")
					clientID = input[1]
					asyncio.ensure_future(self.parseJSON(input[3],clientID))
					logging.info("Made GET request for {}".format(clientID))        		

			elif(input[0] == 'AT'):
				input[5][:-1]
				asyncio.ensure_future(self.receiveInfoOtherServer(input[1],input[2],input[3],input[4],float(input[5])))

			else:
				outPutMsgStr = "? {}\n".format(command)
				outPutMsg = bytes(outPutMsgStr, 'utf-8')
				self.transport.write(outPutMsg)
		except:
			self.transport.write('?  {0}'.format(command))

	# receive 'IAMAT' request, propagate
	def updateClientLocation(self,clientID,location,timeReceived):
		timeDifference = time.time() - timeReceived
		timeDiffStr = ""
		if (timeDifference > 0):
			timeDiffStr = "+" + str(timeDifference)
		else:
			timeDiffStr = "-" + str(timeDifference)

		outPutMsgStr = "AT {0} {1} {2} {3} {4}\n".format(nameOfServer,timeDiffStr,clientID,location,timeReceived)
		outPutMsg = bytes(outPutMsgStr, 'utf-8')
		self.transport.write(outPutMsg)
		logging.info("Sent back {} to user".format(outPutMsgStr))        		
		if (clientID in clientDict):
			if (clientDict[clientID][0] != location):
				clientDict[clientID][0] = location
				clientDict[clientID][1] = nameOfServer
				clientDict[clientID][2] = timeDiffStr
				clientDict[clientID][3] = timeReceived
				print ("client {0} found in clientDict and updated location to {1}".format(clientID,location))
				for s in configuration.SERVER_REL[nameOfServer]:
					try:
						asyncio.ensure_future(client.main(outPutMsgStr,configuration.PORT_NUMS[s]))
						logging.info("Sent AT from {0} to {1}".format(nameOfServer,s))
					except:
						print("cannot connect to server {}".format(configuration.PORT_NUMS[s]))
		else:
			clientDict[clientID] = []
			clientDict[clientID].append(location)
			clientDict[clientID].append(nameOfServer)
			clientDict[clientID].append(timeDiffStr)
			clientDict[clientID].append(timeReceived)

			for s in configuration.SERVER_REL[nameOfServer]:
				#print("CURRENTLY TRYING TO REACH {}\n".format(s))
				try:
					asyncio.ensure_future(client.main(outPutMsgStr,configuration.PORT_NUMS[s]))
					logging.info("Sent AT from {0} to {1}".format(nameOfServer,s))
				except:
					print("cannot connect to server {}".format(configuration.PORT_NUMS[s]))

	# receive 'AT' request, propagate
	async def receiveInfoOtherServer(self, serverName, timeDiffStr, clientID, location, timeReceived):
		logging.info("Received information about client {}".format(clientID))
		outPutMsgStr = "AT {0} {1} {2} {3} {4}\n".format(serverName,timeDiffStr,clientID,location,timeReceived)
		#print("Received message {}".format(outPutMsgStr))		
		if (clientID in clientDict):
			if (clientDict[clientID][0] != location):
				clientDict[clientID][0] = location
				clientDict[clientID][1] = serverName
				clientDict[clientID][2] = timeDiffStr
				clientDict[clientID][3] = timeReceived
				for s in configuration.SERVER_REL[nameOfServer]:
					try:
						asyncio.ensure_future(client.main(outPutMsgStr,configuration.PORT_NUMS[s]))
					except:
						print("cannot connect to server {}".format(configuration.PORT_NUMS[s]))
		else:
			#print ("new client {0} created in clientDict from function RECEIVE\n".format(clientID))
			clientDict[clientID] = []
			clientDict[clientID].append(location)
			clientDict[clientID].append(nameOfServer)
			clientDict[clientID].append(timeDiffStr)
			clientDict[clientID].append(timeReceived)
			for s in configuration.SERVER_REL[nameOfServer]:
				try:
					asyncio.ensure_future(client.main(outPutMsgStr,configuration.PORT_NUMS[s]))
				except:
					print("cannot connect to server {}".format(configuration.PORT_NUMS[s]))

 

def main():
	# Each client connection will create a new protocol instance
	coro = loop.create_server(EchoServerClientProtocol, '127.0.0.1', serverPort)
	server = loop.run_until_complete(coro)

	# Serve requests until Ctrl+C is pressed
	print('This is server {0} listening on port {1}'.format(nameOfServer,serverPort))
	try:
		loop.run_forever()
	except KeyboardInterrupt:
		pass

	# Close the server
	server.close()
	loop.run_until_complete(server.wait_closed())
	loop.close()

if __name__ == "__main__":
	main()
