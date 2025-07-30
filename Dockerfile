FROM public.ecr.aws/lambda/python:3.11 AS base

ARG APP_DIR
WORKDIR /var/task

COPY src/${APP_DIR}/requirements.txt .

RUN pip install --upgrade pip \
    && pip install -r requirements.txt \
    && rm requirements.txt

COPY src/${APP_DIR} .

CMD ["handler.lambda_handler"]