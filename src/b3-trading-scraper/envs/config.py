import os

ENV = os.environ.get("ENV", "prod")
S3_BUCKET = os.environ.get("S3_BUCKET", "")
S3_BUCKET_FOLDER = os.environ.get("S3_BUCKET_FOLDER", "")
AWS_REGION = os.environ.get("AWS_REGION", "us-east-1")
