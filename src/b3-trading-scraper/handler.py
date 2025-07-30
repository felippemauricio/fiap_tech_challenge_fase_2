from services.b3_scraper import run_scraper
from utils.response import json_response

def lambda_handler(event, context):
    result, error = run_scraper()

    if error:
        return json_response({"error": error}, status_code=500)

    return json_response(result)
