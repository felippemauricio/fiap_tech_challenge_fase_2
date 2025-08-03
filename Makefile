REGION = us-east-1
AWS_CREDENTIALS = $(CURDIR)/aws/credentials

TERRAFORM = docker compose -f docker-compose-deploy.yml run --rm
REPO_TERRAFORM = docker compose -f docker-compose-repo.yml run --rm

AWS_ACCOUNT_ID ?= 
ENVIRONMENT ?= 

TF_VARS = -var="account_id=$(AWS_ACCOUNT_ID)" -var="environment=$(ENVIRONMENT)"

.PHONY: init plan apply build run deploy login-aws test

####################################################################
### Terraform REPO commands
####################################################################

# make repo-init
repo-init:
	$(REPO_TERRAFORM) terraform init

# make repo-plan AWS_ACCOUNT_ID=467807053936 ENVIRONMENT=prod-v2
repo-plan:
	$(REPO_TERRAFORM) terraform plan $(TF_VARS)

# make repo-apply AWS_ACCOUNT_ID=467807053936 ENVIRONMENT=prod-v2
repo-apply:
	$(REPO_TERRAFORM) terraform apply -auto-approve $(TF_VARS)

# make repo-destroy AWS_ACCOUNT_ID=467807053936 ENVIRONMENT=prod-v2
repo-destroy:
	$(TERRAFORM) terraform destroy -auto-approve $(TF_VARS)

####################################################################
### Terraform commands
####################################################################

# make init
init:
	$(TERRAFORM) terraform init

# make plan AWS_ACCOUNT_ID=467807053936 ENVIRONMENT=prod-v2
plan:
	$(TERRAFORM) terraform plan $(TF_VARS)

# make apply AWS_ACCOUNT_ID=467807053936 ENVIRONMENT=prod-v2
apply:
	$(TERRAFORM) terraform apply -auto-approve $(TF_VARS)

# make destroy AWS_ACCOUNT_ID=467807053936 ENVIRONMENT=prod-v2
destroy:
	$(TERRAFORM) terraform destroy -auto-approve $(TF_VARS)

import:
	$(TERRAFORM) terraform import $(resource) $(id)

####################################################################
### Lambda Docker build & deploy
####################################################################

# make build APP_NAME=b3-trading-scraper
# make build APP_NAME=trigger-glue-etl
build:
	docker build --platform linux/arm64 --build-arg APP_DIR=$(APP_NAME) -t fiap/$(APP_NAME):latest .

# make login AWS_ACCOUNT_ID=467807053936
login:
	AWS_SHARED_CREDENTIALS_FILE=$(AWS_CREDENTIALS) \
	aws ecr get-login-password --region $(REGION) | \
	docker login --username AWS --password-stdin \
	$(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com

# make push APP_NAME=b3-trading-scraper AWS_ACCOUNT_ID=467807053936 ENVIRONMENT=prod-v2
# make push APP_NAME=trigger-glue-etl AWS_ACCOUNT_ID=467807053936 ENVIRONMENT=prod-v2
push:
	AWS_SHARED_CREDENTIALS_FILE=$(AWS_CREDENTIALS) \
	docker tag fiap/$(APP_NAME):latest \
	$(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/fiap/$(APP_NAME)-$(ENVIRONMENT):latest && \
	AWS_SHARED_CREDENTIALS_FILE=$(AWS_CREDENTIALS) \
	docker push \
	$(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/fiap/$(APP_NAME)-$(ENVIRONMENT):latest

# make deploy APP_NAME=b3-trading-scraper AWS_ACCOUNT_ID=467807053936 ENVIRONMENT=prod-v2
# make deploy APP_NAME=trigger-glue-etl AWS_ACCOUNT_ID=467807053936 ENVIRONMENT=prod-v2
deploy:
	AWS_SHARED_CREDENTIALS_FILE=$(AWS_CREDENTIALS) \
	aws lambda update-function-code \
	--function-name "$(APP_NAME)-lambda-$(ENVIRONMENT)" \
	--image-uri $(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/fiap/$(APP_NAME)-$(ENVIRONMENT):latest \
	--region $(REGION)

# make run APP_NAME=b3-trading-scraper
# make run APP_NAME=trigger-glue-etl
run:
	docker run -p 9000:8080 fiap/$(APP_NAME):latest

test:
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" \
		-H "Content-Type: application/json" \
		-d '{"test": "ok"}' | jq
