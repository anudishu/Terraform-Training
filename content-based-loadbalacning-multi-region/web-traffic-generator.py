import asyncio
import requests
import aiohttp
import datetime

async def fetch(session, url):
    start_time = datetime.datetime.now()
    print(start_time)
    async with session.get(url) as response:
        return await response.text()

async def main():
    base_url = "http://lyfedge.com:80"
    urls = [base_url for i in range(600000)]
    tasks = []
    async with aiohttp.ClientSession() as session:
        for url in urls:
            tasks.append(fetch(session, url))
        htmls = await asyncio.gather(*tasks)
        # for html in htmls:
        #     print(html[:100])

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())    