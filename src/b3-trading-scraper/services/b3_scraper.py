import re
import json
import time
import random
import base64
import requests
from datetime import datetime
from io import BytesIO

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
import boto3

from envs import config

def clean_type_field(type_str):
    if isinstance(type_str, str):
        return re.sub(r'\s+', ' ', type_str).strip()
    return type_str


def clean_number(value):
    if not isinstance(value, str):
        return None
    cleaned = re.sub(r'[.,]', '', value)
    try:
        number = int(cleaned)
        return number
    except Exception as e:
        return None

def create_api_url(page_number=1, page_size=20):
    params = {
        "language": "en-us",
        "pageNumber": page_number,
        "pageSize": page_size,
        "index": "IBOV",
        "segment": "1"
    }

    params_json = json.dumps(params, separators=(',', ':'))
    params_base64 = base64.b64encode(params_json.encode("utf-8")).decode("utf-8")
    return f"https://sistemaswebb3-listados.b3.com.br/indexProxy/indexCall/GetPortfolioDay/{params_base64}"


def access_b3_api(page_number=1):
    url = create_api_url(page_number)
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    return None


def extract_file_date(json_data):
    try:
        date_str = json_data['header']['date']
        dt = datetime.strptime(date_str, "%d/%m/%y")
        return dt.strftime("%Y-%m-%d")
    except Exception:
        return datetime.now().strftime("%Y-%m-%d")


def collect_page_with_retry(page_number, max_attempts=10):
    for attempt in range(1, max_attempts + 1):
        data = access_b3_api(page_number)
        if data:
            return data
        if attempt < max_attempts:
            time.sleep(attempt * 2)
    return None


def jsons_to_dataframe(json_pages):
    records = []
    for page in json_pages:
        items = page.get("results", [])
        records.extend(items)
    return pd.DataFrame(records)

def upload_parquet_to_s3(df, partition_date):
    dt = datetime.strptime(partition_date, "%Y-%m-%d")
    year = dt.strftime("%Y")
    month = dt.strftime("%m")
    day = dt.strftime("%d")

    key = f"{config.S3_BUCKET_FOLDER}/year={year}/month={month}/day={day}/ibovespa.parquet"

    table = pa.Table.from_pandas(df)
    buf = BytesIO()
    pq.write_table(table, buf)
    buf.seek(0)

    s3 = boto3.client("s3")
    s3.put_object(Bucket=config.S3_BUCKET, Key=key, Body=buf.getvalue())


def run_scraper():
    first_page = access_b3_api(page_number=1)
    if not first_page:
        return None, "Failed to fetch first page from API"

    partition_date = extract_file_date(first_page)
    total_pages = first_page['page']['totalPages']
    all_pages = [first_page]

    for page in range(2, total_pages + 1):
        time.sleep(random.uniform(1, 2))
        page_data = collect_page_with_retry(page)
        if page_data:
            all_pages.append(page_data)
        else:
            return None, f"Failed to fetch page {page}"

    if len(all_pages) != total_pages:
        return None, "Incomplete data collection"

    df = jsons_to_dataframe(all_pages)
    if df.empty:
        return None, "No data to save"

    # Remove coluns
    df = df.drop(columns=['segment', 'partAcum'], errors='ignore')

    # Adjust type
    df['raw_type'] = df['type']
    df['type'] = df['type'].apply(clean_type_field)

    # Adjust theoricalQty
    df['raw_theorical_qty'] = df['theoricalQty']
    df['theorical_qty'] = df['theoricalQty'].apply(clean_number)
    df.drop(columns=['theoricalQty'], inplace=True)

    # Adjust part
    df['raw_part'] = df['part']
    df['part'] = df['part'].apply(clean_number)

    # new fields
    df['date_partition'] = partition_date  # string yyyy-mm-dd já extraída da API
    df['extract_timestamp'] = datetime.utcnow().replace(microsecond=0).isoformat() + 'Z'  # UTC ISO 8601

    upload_parquet_to_s3(df, partition_date)

    return {
        "message": "Scraping and upload completed successfully",
        "pages_collected": len(all_pages),
        "date_partition": partition_date
    }, None
