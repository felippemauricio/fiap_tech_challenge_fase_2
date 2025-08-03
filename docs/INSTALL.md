# Installation Guide

This document provides detailed instructions to set up the necessary tools, configure AWS credentials, provision AWS infrastructure, and deploy Lambda functions for the project.

## 🐳 1. Install Required CLI Tools (Docker & AWS CLI)

You need to install both **Docker** and **AWS CLI** on your local machine to build and deploy Lambda Docker images and interact with AWS services.

### On macOS (via Homebrew):

```bash
# Install Docker
brew install --cask docker

# Install AWS CLI v2
brew install awscli
```

> **After installing Docker**, make sure to **open the Docker Desktop app at least once** so it finishes setup and starts the Docker daemon.

## 🔐 2. Setting Up AWS Credentials (via AWS Academy Lab)

To enable Terraform to provision resources in your AWS environment, you need to configure local AWS credentials. If you're using **AWS Academy Learner Lab**, follow the steps below:

### 📘 How to Configure AWS Credentials

1. Access the **AWS Academy Learner Lab** and start your active lab session.  
2. In the lab dashboard, locate the **"AWS Details"** section.  
3. Click the **"Show"** button next to **"AWS CLI"** to reveal your temporary credentials.

    You should see something like this:

    ```ini
    [default]
    aws_access_key_id = ABCDEFGHIJK123456789
    aws_secret_access_key = aVeryLongSecretKeyHere123456789...
    aws_session_token = AnotherLongSessionToken...
    ```

4. Copy the full content (including the `[default]` section header).  
5. In this project’s root folder, navigate to the `aws/` directory.  
6. If it doesn’t exist yet, create a file named `credentials`.  
7. Paste the copied content into `aws/credentials`.

> ✅ **Done!** Terraform will now use this file to authenticate your AWS session when creating resources.

## 3. ☁️ Provisioning AWS Infrastructure - ECR Repositories

Provision the Elastic Container Registries (ECR) that will store the Docker images for each Lambda function.

```bash
# Make sure to replace <your-account-id> with your actual AWS account ID.
make repo-init
make repo-plan AWS_ACCOUNT_ID=<your-account-id> ENVIRONMENT=prod
make repo-apply AWS_ACCOUNT_ID=<your-account-id> ENVIRONMENT=prod
```

These commands initialize Terraform, show the planned infrastructure changes, and apply them to your AWS account.

## 4. 🚀 Build and Push Lambda Docker Images to AWS ECR

The Lambda functions are packaged as Docker containers. Build and push the images to the ECR repositories created in the previous step.

```bash
# Make sure to replace <your-account-id> with your actual AWS account ID.
# Login to AWS
make login AWS_ACCOUNT_ID=<your-aws-account-id>

# Build images
make build APP_NAME=b3-trading-scraper
make build APP_NAME=trigger-glue-etl

# Push images
make push APP_NAME=b3-trading-scraper AWS_ACCOUNT_ID=<your-aws-account-id> ENVIRONMENT=prod
make push APP_NAME=trigger-glue-etl AWS_ACCOUNT_ID=<your-aws-account-id> ENVIRONMENT=prod
```

## 5. ☁️ Provisioning AWS Infrastructure - Core Resources / Full Resources

Provision the remaining AWS resources such as:

- S3 buckets
- Glue Catalog Databases and Tables
- Lambda functions (referencing images pushed in step 4)
- EventBridge rules
- Athena

```bash
# Make sure to replace <your-account-id> with your actual AWS account ID.
make init
make plan AWS_ACCOUNT_ID=<your-account-id> ENVIRONMENT=prod
make apply AWS_ACCOUNT_ID=<your-account-id> ENVIRONMENT=prod
```

> Ensure the ECR images are already pushed before this step, as Lambda functions depend on them.

## 6. 🧩 Manual Creation of AWS Glue Job

Terraform generates the Glue job JSON file and uploads it to a specific S3 folder. However, due to current AWS limitations, the Glue job must be created manually using the **Visual with a source script** editor in the AWS Glue Console.

### Why manual creation is necessary:

- Visual Glue jobs require a specific JSON format that includes UI metadata (like node positions and links) which Terraform and the AWS CLI cannot generate.
- The job includes visual components and drag-and-drop transformations that must be defined manually in the AWS Console.

### Steps to Create the Glue Job:

1. **Go to S3 Console**  
   Navigate to the AWS S3 Console and find the bucket named: glue-job-scripts-b3-trading-visual-job-<ENVIRONMENT>

> The `<ENVIRONMENT>` here refers to the same value used in the Terraform commands from **Step 5**, such as `prod`, `dev`, or `test`.

2. **Download the Glue Job JSON**  
Inside the bucket, you’ll find a `.json` file named with the Glue job name (e.g., `b3-trading-daily-job.json`). Download it to your local machine.

3. **Go to AWS Glue Console**  
Open the [AWS Glue Console](https://console.aws.amazon.com/glue/).

4. **Create a New Job**  
- In the left menu, click on **"Jobs"**.
- Click **"Visual with a source script"** (do **not** use “Script editor”).
- Click **"Create job"**.

5. **Set Job Name and Upload Script**  
- Enter the **exact same job name** as the JSON filename (without `.json`).
- In the job editor, click the **"Actions"** menu, then select **"Import script from JSON file"**.
- Upload the JSON file you downloaded earlier.

6. **Review and Save**  
- Review the job settings and the visual nodes.
- Click **"Save"** to create the job.

> Once saved, the Glue job will be ready to run or be triggered via the associated Lambda.
