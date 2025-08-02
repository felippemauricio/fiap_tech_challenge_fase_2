import json

from envs import config
from services.glue_service import start_glue_job
from services.s3_cleanup_service import delete_refined_files

def lambda_handler(event, context):
    cleanup_result = delete_refined_files(config.S3_BUCKET, config.S3_BUCKET_FOLDER)
    if not cleanup_result["success"]:
        return {
            "statusCode": 500,
            "body": f"Erro ao limpar S3: {cleanup_result['error']}"
        }

    glue_result = start_glue_job(config.GLUE_JOB_NAME)
    if not glue_result["success"]:
        return {
            "statusCode": 500,
            "body": f"Erro ao iniciar Glue Job: {glue_result['error']}"
        }

    return {
        "statusCode": 200,
        "body": f"Glue Job iniciado com sucesso, run ID: {glue_result['job_run_id']}, arquivos deletados: {cleanup_result['deleted_files_count']}"
    }
