TERRAFORM = docker compose run --rm
REGION = us-east-1
AWS_CREDENTIALS = $(CURDIR)/aws/credentials

.PHONY: init plan apply build run deploy login-aws test

####################################################################
### Terraform commands
####################################################################

init:
	$(TERRAFORM) terraform init

plan:
	$(TERRAFORM) terraform plan

apply:
	$(TERRAFORM) terraform apply -auto-approve

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

# make push APP_NAME=b3-trading-scraper AWS_ACCOUNT_ID=467807053936
# make push APP_NAME=trigger-glue-etl AWS_ACCOUNT_ID=467807053936
push:
	AWS_SHARED_CREDENTIALS_FILE=$(AWS_CREDENTIALS) \
	docker tag fiap/$(APP_NAME):latest \
	$(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/fiap/$(APP_NAME)-prod:latest && \
	AWS_SHARED_CREDENTIALS_FILE=$(AWS_CREDENTIALS) \
	docker push \
	$(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/fiap/$(APP_NAME)-prod:latest && \
	$(MAKE) deploy

# make deploy APP_NAME=b3-trading-scraper AWS_ACCOUNT_ID=467807053936
# make deploy APP_NAME=trigger-glue-etl AWS_ACCOUNT_ID=467807053936
deploy:
	AWS_SHARED_CREDENTIALS_FILE=$(AWS_CREDENTIALS) \
	aws lambda update-function-code \
	--function-name "$(APP_NAME)-lambda-prod" \
	--image-uri $(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/fiap/$(APP_NAME)-prod:latest \
	--region $(REGION)

# make run APP_NAME=b3-trading-scraper
# make run APP_NAME=trigger-glue-etl
run:
	docker run -p 9000:8080 fiap/$(APP_NAME):latest

test:
	curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" \
		-H "Content-Type: application/json" \
		-d '{"test": "ok"}' | jq
