import asyncio
#import aiohttp
#import async_timeout
#import getreq
import client
import sys
import configuration
import time


# Globals for the server initiated
nameOfServer = sys.argv[1]
serverPort = configuration.PORT_NUMS[nameOfServer]
#serverAsClient = client.EchoClientProtocol("")

class EchoServerClientProtocol(asyncio.Protocol):
    def connection_made(self, transport):
        peername = transport.get_extra_info('peername')
        self.transport = transport
        self.clientDict = dict()
    #def serverSendToServer(self, serverPort, messageToSend):
    #	client.main(serverPort,messageToSend)

    def serverSendToServer(self,serverPort,messageToSend):
    	client.main(serverPort,messageToSend)
    	#loop = asyncio.get_event_loop()
    	#coro = loop.create_connection(lambda: client.EchoClientProtocol(messageToSend,loop),'127.0.0.1',serverPort)
    	#self.run_once(loop.run_until_complete(coro))
    	#loop.create_task(coro)
    	#loop.run_forever()
    	#loop.stop()
    	#loop.close()

    def checkValidIAMAT(self,command):
        try:
            float(command)
            return True
        except ValueError:
            return False    

    def data_received(self, command):
        try:
            command = command.decode()
            input = command.split(' ')
            if(input[0] == 'IAMAT'):
                if (len(input) != 4 or not self.checkValidIAMAT(input[3])):
                    outPutMsgStr = "? {}\n".format(command)
                    outPutMsg = bytes(outPutMsgStr, 'utf-8')
                    self.transport.write(outPutMsg)
                else:
                    self.updateClientLocation(input[1],input[2],float(input[3]))


            elif(input[0] == 'WHATSAT'):
                if (int(input[2]) > 50 or int(input[3]) > 20):
                    outPutMsgStr = "? {}\n".format(command)
                    outPutMsg = bytes(outPutMsgStr, 'utf-8')
                    #self.transport.write(outPutMsg)
                    #self.transport.write('? {}\n'.format(command))

            elif(input[0] == 'AT'):
            	input[5][:-1] # remove newline character
            	print("AT command received")
            	self.receiveInfoOtherServer(input[1],input[2],input[3],input[4],float(input[5]))

            else:
                outPutMsgStr = "? {}\n".format(command)
                outPutMsg = bytes(outPutMsgStr, 'utf-8')
                self.transport.write(outPutMsg)
        except:
            self.transport.write('?  {0}'.format(command))

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

        self.clientDict[clientID] = location

        loop = asyncio.get_event_loop()
        for s in configuration.SERVER_REL[nameOfServer]:
        	coro = loop.create_connection(lambda: client.EchoClientProtocol(outPutMsgStr, loop),
                                      '127.0.0.1', serverPort)
        	loop.create_task(coro)
        loop.run_until_complete
        loop.close()

        #if (clientID in self.clientDict.keys()):
        #    if (self.clientDict[clientID][0] != location):
        #        self.clientDict[clientID][0] = location
        #        self.clientDict[clientID][1] = nameOfServer
        #        self.clientDict[clientID][2] = timeDiffStr
        #        self.clientDict[clientID][3] = timeReceived
        #        print("***********UPDATE LOCATION*************\n")
        #        for s in configuration.SERVER_REL[serverName]:
                	#serverAsClient.sendConnection(configuration.PORT_NUMS[s],outPutMsgStr)
        #        	self.serverSendToServer(configuration.PORT_NUMS[s],outPutMsgStr)
#               	print("Successfully processed {0}".format(outPutMsgStr))
        #    else:
        #    	print("***********LOCATION IS THE SAME*************\n")

        #else:
        #    self.clientDict[clientID] = []
        #   self.clientDict[clientID].append(location)
        #    self.clientDict[clientID].append(nameOfServer)
        #    self.clientDict[clientID].append(timeDiffStr)
        #    self.clientDict[clientID].append(timeReceived)
        #    print("Successfully processed {0} in else block".format(outPutMsgStr))
        #    for s in configuration.SERVER_REL[nameOfServer]:
            	#serverAsClient.sendConnection(configuration.PORT_NUMS[s],outPutMsgStr)
        #    	self.serverSendToServer(configuration.PORT_NUMS[s],outPutMsgStr)


    def receiveInfoOtherServer(self, serverName, timeDiffStr, clientID, location, timeReceived):
        outPutMsgStr = "AT {0} {1} {2} {3} {4}\n".format(nameOfServer,timeDiffStr,clientID,location,timeReceived)
        if (clientID in self.clientDict):
            if self.clientDict[clientID] != location:
                self.clientDict[clientID] = location
                #self.clientDict[clientID][1] = nameOfServer
                #self.clientDict[clientID][2] = timeDiffStr
                #self.clientDict[clientID][3] = timeReceived

                	#serverAsClient.sendConnection(configuration.PORT_NUMS[s],outPutMsgStr)
                	#self.serverSendToServer(configuration.PORT_NUMS[s],outPutMsgStr)
                	#print("Successfully processed {0}".format(outPutMsgStr))
            else:
            	print("***********LOCATION IS THE SAME*************\n")
        else:
        	self.clientDict[clientID] = location
            #self.clientDict[clientID] = []
            #self.clientDict[clientID].append(location)
            #self.clientDict[clientID].append(nameOfServer)
            #self.clientDict[clientID].append(timeDiffStr)
            #self.clientDict[clientID].append(timeReceived)
            #for s in configuration.SERVER_REL[serverName]:
            	#serverAsClient.sendConnection(configuration.PORT_NUMS[s],outPutMsgStr)
            #	self.serverSendToServer(configuration.PORT_NUMS[s],outPutMsgStr)
           	# 	print("Successfully processed {0} in else block".format(outPutMsgStr))
           	
        loop = asyncio.get_event_loop()
        for s in configuration.SERVER_REL[serverName]:
        	coro = loop.create_connection(lambda: client.EchoClientProtocol(outPutMsgStr, loop), '127.0.0.1', serverPort)
        	loop.create_task(coro)
        	loop.run_until_complete

        loop.close()

       


        #message = data.decode()
        #print('Data received: {!r}'.format(message))

        #print('Send: {!r}'.format(message))
        #self.transport.write(data)

        #print('Close the client socket')
        #self.transport.close()
def main():
	loop = asyncio.get_event_loop()
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




# CODE THAT HAS IAMAT AND WHATSAT WORKING
import asyncio
import aiohttp
import async_timeout
import json
import client
import sys
import configuration
import time


# Globals for the server initiated
nameOfServer = sys.argv[1]
serverPort = configuration.PORT_NUMS[nameOfServer]
URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={0}&radius={1}&key=AIzaSyC-tfrRtq4VBwbiySjc5CHXKUPRitNTXyQ'

class EchoServerClientProtocol(asyncio.Protocol):
    def connection_made(self, transport):
        peername = transport.get_extra_info('peername')
        self.transport = transport
        self.clientDict = dict()

    def checkValidIAMAT(self,command):
        try:
            float(command)
            return True
        except ValueError:
            return False    

    async def fetch(self,session, url):
        with async_timeout.timeout(10):
            async with session.get(url) as response:
                return await response.text()

    async def parseJSON(self,radius,clientID):
        clientInfo = self.clientDict[clientID]
        locationReformatted = self.formatLocation(clientInfo[0])
        outPutMsgStr = "AT {0} {1} {2} {3} {4}\n".format(nameOfServer,clientInfo[2],clientID,self.clientDict[clientID][0],clientInfo[3])

        async with aiohttp.ClientSession() as session:
            call = URL.format(locationReformatted,radius)
            #call = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=50&key=AIzaSyC-tfrRtq4VBwbiySjc5CHXKUPRitNTXyQ'
            #print(call)
            html = await self.fetch(session,call)
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

    def data_received(self, command):
        try:
            command = command.decode('utf-8')
            input = command.split(' ')
            if(input[0] == 'IAMAT'):
                if (len(input) != 4 or not self.checkValidIAMAT(input[3])):
                    outPutMsgStr = "? {}\n".format(command)
                    outPutMsg = bytes(outPutMsgStr, 'utf-8')
                    self.transport.write(outPutMsgStr)
                else:
                    self.updateClientLocation(input[1],input[2],float(input[3]))

            elif(input[0] == 'WHATSAT'):
                if (int(input[2]) > 50 or int(input[3]) > 20):
                    outPutMsgStr = "? {}\n".format(command)
                    outPutMsg = bytes(outPutMsgStr, 'utf-8')
                else:
                    clientID = input[1]
                    asyncio.ensure_future(self.parseJSON(input[3],clientID))                

            elif(input[0] == 'AT'):
                input[5][:-1] # remove newline character
                print("AT command received")
                self.receiveInfoOtherServer(input[1],input[2],input[3],input[4],float(input[5]))

            else:
                outPutMsgStr = "? {}\n".format(command)
                outPutMsg = bytes(outPutMsgStr, 'utf-8')
                self.transport.write(outPutMsg)
        except:
            self.transport.write('?  {0}'.format(command))

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


        if (clientID in self.clientDict):
            self.clientDict[clientID][0] = location
            self.clientDict[clientID][1] = nameOfServer
            self.clientDict[clientID][2] = timeDiffStr
            self.clientDict[clientID][3] = timeReceived
            print ("client {0} found in clientDict".format(clientID))
        else:
            print ("new client {0} created in clientDict".format(clientID))
            self.clientDict[clientID] = []
            self.clientDict[clientID].append(location)
            self.clientDict[clientID].append(nameOfServer)
            self.clientDict[clientID].append(timeDiffStr)
            self.clientDict[clientID].append(timeReceived)

        print(clientID)
        print(self.clientDict[clientID])

        #self.clientDict[clientID] = location

        #loop = asyncio.get_event_loop()
        #for s in configuration.SERVER_REL[nameOfServer]:
        #   coro = loop.create_connection(lambda: client.EchoClientProtocol(outPutMsgStr, loop),
        #                              '127.0.0.1', s)
        #   loop.create_task(coro)
        #loop.run_until_complete()
        #loop.close()

    def receiveInfoOtherServer(self, serverName, timeDiffStr, clientID, location, timeReceived):
        outPutMsgStr = "AT {0} {1} {2} {3} {4}\n".format(nameOfServer,timeDiffStr,clientID,location,timeReceived)
        if (clientID in self.clientDict):
            if self.clientDict[clientID] != location:
                self.clientDict[clientID] = location
            else:
                print("***********LOCATION IS THE SAME*************\n")
        else:
            self.clientDict[clientID] = location

        loop = asyncio.get_event_loop()
        for s in configuration.SERVER_REL[serverName]:
            coro = loop.create_connection(lambda: client.EchoClientProtocol(outPutMsgStr, loop), '127.0.0.1', s)
            loop.create_task(coro)
        loop.run_until_complete()
        loop.close()

def main():
    loop = asyncio.get_event_loop()
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

#### CODE WITH WHATSAT AND IAMAT WORKING
import asyncio
import aiohttp
import async_timeout
import json
import client
import sys
import configuration
import time


# Globals for the server initiated
nameOfServer = sys.argv[1]
serverPort = configuration.PORT_NUMS[nameOfServer]
URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location={0}&radius={1}&key=AIzaSyC-tfrRtq4VBwbiySjc5CHXKUPRitNTXyQ'

class EchoServerClientProtocol(asyncio.Protocol):
    def connection_made(self, transport):
        peername = transport.get_extra_info('peername')
        self.transport = transport
        self.clientDict = dict()

    def checkValidIAMAT(self,command):
        try:
            float(command)
            return True
        except ValueError:
            return False    

    async def fetch(self,session, url):
        with async_timeout.timeout(10):
            async with session.get(url) as response:
                return await response.text()

    async def parseJSON(self,radius,clientID):
        clientInfo = self.clientDict[clientID]
        locationReformatted = self.formatLocation(clientInfo[0])
        outPutMsgStr = "AT {0} {1} {2} {3} {4}\n".format(nameOfServer,clientInfo[2],clientID,self.clientDict[clientID][0],clientInfo[3])

        async with aiohttp.ClientSession() as session:
            call = URL.format(locationReformatted,radius)
            #call = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=50&key=AIzaSyC-tfrRtq4VBwbiySjc5CHXKUPRitNTXyQ'
            #print(call)
            html = await self.fetch(session,call)
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

    def data_received(self, command):
        try:
            command = command.decode('utf-8')
            input = command.split(' ')
            if(input[0] == 'IAMAT'):
                if (len(input) != 4 or not self.checkValidIAMAT(input[3])):
                    outPutMsgStr = "? {}\n".format(command)
                    outPutMsg = bytes(outPutMsgStr, 'utf-8')
                    self.transport.write(outPutMsgStr)
                else:
                    self.updateClientLocation(input[1],input[2],float(input[3]))

            elif(input[0] == 'WHATSAT'):
                if int(input[2]) > 50 or int(input[3]) > 20:
                    outPutMsgStr = "? {}\n".format(command)
                    outPutMsg = bytes(outPutMsgStr, 'utf-8')
                    self.transport.write(outPutMsg)
                else:
                    clientID = input[1]
                    asyncio.ensure_future(self.parseJSON(input[3],clientID))                

            elif(input[0] == 'Hello'):
                input[5][:-1] # remove newline character
                print("AT command received")
                #asyncio.ensure_future(self.receiveInfoOtherServer(input[1],input[2],input[3],input[4],float(input[5])))

            else:
                outPutMsgStr = "? {}\n".format(command)
                outPutMsg = bytes(outPutMsgStr, 'utf-8')
                self.transport.write(outPutMsg)
        except:
            self.transport.write('?  {0}'.format(command))

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
        if (clientID in self.clientDict):
            if (self.clientDict[clientID][0] != location):
                self.clientDict[clientID][0] = location
                self.clientDict[clientID][1] = nameOfServer
                self.clientDict[clientID][2] = timeDiffStr
                self.clientDict[clientID][3] = timeReceived
                print ("client {0} found in clientDict and updated location to {1}".format(clientID,location))
                asyncio.ensure_future(client.main('Hello',18040))
        else:
            print ("new client {0} created in clientDict".format(clientID))
            self.clientDict[clientID] = []
            self.clientDict[clientID].append(location)
            self.clientDict[clientID].append(nameOfServer)
            self.clientDict[clientID].append(timeDiffStr)
            self.clientDict[clientID].append(timeReceived)
            asyncio.ensure_future(client.main('Hello',18040))
            
        print(clientID)
        print(self.clientDict[clientID])

    def receiveInfoOtherServer(self, serverName, timeDiffStr, clientID, location, timeReceived):
        print("Info received from neighboring server about client: {0}".format(clientID))

 

def main():
    loop = asyncio.get_event_loop()
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

