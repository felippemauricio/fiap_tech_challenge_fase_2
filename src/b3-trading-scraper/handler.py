import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f"Received felippe event: {json.dumps(event)}")

    # Log all environment variables
    env_vars = dict(os.environ)
    logger.info(f"Environment variables: {json.dumps(env_vars)}")
