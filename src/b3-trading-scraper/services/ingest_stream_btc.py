import requests
from bs4 import BeautifulSoup
from datetime import datetime
import boto3
import json
import time

firehoseClient = boto3.client('firehose',
                              aws_access_key_id='acess',
                              aws_secret_access_key='acess',
                              aws_session_token='acess',
                              region_name='us-east-1')

# create a function to get price of cryptocurrency


def get_latest_crypto_price(coin):
    url = 'https://www.google.com/search?q=' + (coin) + '+price'
    # make a request to the website
    HTML = requests.get(url)
    # Parse the HTML
    soup = BeautifulSoup(HTML.text, 'html.parser')
    # find the current price
    text1 = soup.find('div', attrs={
        'class': 'BNeawe iBp4i AP7Wnd'
    }).find({
        'div': 'BNeawe iBp4i AP7Wnd'
    }).text
    return text1


while (1):
    now = datetime.now()
    coleta = now.strftime("%Y-%m-%d %H:%M:%S")
    price = get_latest_crypto_price('bitcoin')
    envio = firehoseClient.put_record(
        DeliveryStreamName='ingest_btc_stream',
        Record={
            'Data': json.dumps({
                "price": price,
                "coleta": coleta
            })
        }
    )
    print(envio, price, coleta)
    time.sleep(1)
