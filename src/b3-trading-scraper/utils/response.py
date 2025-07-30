def json_response(body: dict, status_code: int = 200):
    return {
        "statusCode": status_code,
        "body": body
    }