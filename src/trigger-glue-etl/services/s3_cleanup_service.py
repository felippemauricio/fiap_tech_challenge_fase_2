import boto3

s3_client = boto3.client('s3')

def delete_refined_files(bucket_name: str, prefix: str):
    try:
        paginator = s3_client.get_paginator('list_objects_v2')
        pages = paginator.paginate(Bucket=bucket_name, Prefix=prefix)

        deleted_files = 0
        for page in pages:
            if 'Contents' in page:
                for obj in page['Contents']:
                    s3_client.delete_object(Bucket=bucket_name, Key=obj['Key'])
                    deleted_files += 1
        return {
            "success": True,
            "deleted_files_count": deleted_files
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }
