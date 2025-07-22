#!/bin/bash

# B3 Scrapper lambda 
B3_TRADING_SRC="b3_trading_scraper"
rm -f ./package/$B3_TRADING_SRC.zip
cd ./src/$B3_TRADING_SRC
zip -r ../../package/$B3_TRADING_SRC.zip .
