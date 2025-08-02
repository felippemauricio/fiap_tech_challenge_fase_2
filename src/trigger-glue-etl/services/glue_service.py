import boto3

glue_client = boto3.client('glue')

def start_glue_job(job_name: str):
    try:
        response = glue_client.start_job_run(JobName=job_name)
        return {
            "success": True,
            "job_run_id": response['JobRunId']
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }
