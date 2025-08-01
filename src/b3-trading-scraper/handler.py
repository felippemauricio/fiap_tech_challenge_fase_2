from services.b3_scraper import run_scraper
from utils.response import json_response

"""
This Lambda function scrapes the theoretical portfolio of the IBOV index from B3’s website,
processes the data, and writes the result as a Parquet file to Amazon S3, partitioned by date.

The generated Parquet file includes the following fields:

| Field              | Data Type | Description                                                |
|--------------------|-----------|------------------------------------------------------------|
| cod                | string    | Asset code                                                 |
| asset              | string    | Asset name                                                 |
| type               | string    | Cleaned asset type                                         |
| part               | long      | Numeric participation in the index                         |
| raw_type           | string    | Original asset type as received from the source            |
| raw_theorical_qty  | string    | Original theoretical quantity (raw string)                 |
| theorical_qty      | long      | Cleaned theoretical quantity (as a number)                 |
| raw_part           | string    | Original participation string (e.g., "3,57")               |
| date_partition     | string    | Reference date in YYYY-MM-DD format                        |
| extract_timestamp  | string    | UTC timestamp of the extraction in ISO 8601 format         |
"""
def lambda_handler(event, context):
    result, error = run_scraper()

    if error:
        return json_response({"error": error}, status_code=500)

    return json_response(result)
