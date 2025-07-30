# Build stage: Use official Python image with build tools installed
FROM python:3.11 AS builder

ARG APP_DIR
WORKDIR /app

# Copy requirements.txt from the app folder
COPY src/${APP_DIR}/requirements.txt .

# Upgrade pip and install dependencies into /install directory
RUN pip install --upgrade pip && \
    pip install --target=/install -r requirements.txt

# Copy application source code into /install (alongside the libraries)
COPY src/${APP_DIR} /install/

# Final stage: AWS Lambda official Python runtime image
FROM public.ecr.aws/lambda/python:3.11

WORKDIR /var/task

# Copy installed dependencies and source code from the builder stage
COPY --from=builder /install/ .

# Set the Lambda handler function
CMD ["handler.lambda_handler"]
