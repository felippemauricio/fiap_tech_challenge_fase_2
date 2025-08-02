import os

ENV = os.environ.get("ENV", "prod")
GLUE_JOB_NAME = os.environ.get("GLUE_JOB_NAME", "")
S3_BUCKET = os.environ.get("S3_BUCKET", "")
S3_BUCKET_FOLDER = os.environ.get("S3_BUCKET_FOLDER", "refined")
AWS_REGION = os.environ.get("AWS_REGION", "us-east-1")
