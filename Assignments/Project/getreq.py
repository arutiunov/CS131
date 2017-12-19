import aiohttp
import asyncio
import async_timeout
import json

async def fetch(session, url):
    with async_timeout.timeout(10):
        async with session.get(url) as response:
            return await response.text()

async def main():
    async with aiohttp.ClientSession() as session:
        html = await fetch(session, 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=50&key=AIzaSyC-tfrRtq4VBwbiySjc5CHXKUPRitNTXyQ')
        data_json = json.loads(html)
        limit_results = data_json["results"][0:20]
        data_json["results"] = limit_results
        print("THIS IS WHERE THE AT RESPONSE WILL GO\n{}\n\n".format(json.dumps(data_json, sort_keys=True,indent=4,separators=(',',': '))))

loop = asyncio.get_event_loop()
loop.run_until_complete(main())


#https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=50&key=AIzaSyC-tfrRtq4VBwbiySjc5CHXKUPRitNTXyQ
#https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=50&key=AIzaSyC-tfrRtq4VBwbiySjc5CHXKUPRitNTXyQ