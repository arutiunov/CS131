import asyncio

class EchoClientProtocol(asyncio.Protocol):
    def __init__(self, message, loop):
        self.message = message
        self.loop = loop
    def connection_made(self,transport):
        transport.write(self.message.encode())
        #print('Data sent: {!r}'.format(self.message))
    def data_received(self, data):
        print('Data received: {!r}'.format(data.decode()))

    def connection_lost(self, exc):
        print('The server closed the connection')
        print('Stop the event loop')

async def main(message,port):
    loop = asyncio.get_event_loop()
    try:
        coro = loop.create_connection(lambda: EchoClientProtocol(message, loop), '127.0.0.1', port)
    except:
        print("cannot connect to server with port {}".format(port))
    asyncio.ensure_future(coro)