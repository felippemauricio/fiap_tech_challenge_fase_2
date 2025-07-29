#!/bin/bash

# B3 Scrapper lambda 
B3_TRADING_SRC="b3_trading_scraper"
echo "🛠️  Building Lambda package for '${B3_TRADING_SRC}'..."
rm -f ./package/$B3_TRADING_SRC.zip
cd ./src/${B3_TRADING_SRC} || exit 1
zip -r ../../package/${B3_TRADING_SRC}.zip . > /dev/null
cd - > /dev/null || exit 1
echo "📦  Lambda package '${B3_TRADING_SRC}.zip' created successfully in ./package/"
echo "🚀  Ready for deployment."
echo ""

# Trigger Glue ETL lambda 
TRIGGER_GLUE_ETL_SRC="trigger-glue-etl"
echo "🛠️  Building Lambda package for '${TRIGGER_GLUE_ETL_SRC}'..."
rm -f ./package/$TRIGGER_GLUE_ETL_SRC.zip
cd ./src/${TRIGGER_GLUE_ETL_SRC} || exit 1
zip -r ../../package/${TRIGGER_GLUE_ETL_SRC}.zip . > /dev/null
cd - > /dev/null || exit 1
echo "📦  Lambda package '${TRIGGER_GLUE_ETL_SRC}.zip' created successfully in ./package/"
echo "🚀  Ready for deployment."
echo ""
