FROM public.ecr.aws/lambda/python:3.12

ARG APP_DIR

COPY src/${APP_DIR}/requirements.txt ${LAMBDA_TASK_ROOT}

RUN pip install --upgrade pip && \
    pip install -r requirements.txt

COPY src/${APP_DIR} ${LAMBDA_TASK_ROOT}

CMD ["handler.lambda_handler"]