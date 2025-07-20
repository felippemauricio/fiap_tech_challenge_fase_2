TERRAFORM = docker compose run --rm
APP=B3_Scrapper.py

VENV_DIR=.venv

PIP=$(VENV_DIR)/bin/pip
PYTHON=$(VENV_DIR)/bin/python

BLACK=$(VENV_DIR)/bin/black
FLAKE8=$(VENV_DIR)/bin/flake8
UVICORN=$(VENV_DIR)/bin/uvicorn

.PHONY: venv install run test lint format

init:
	$(TERRAFORM) terraform init

plan:
	$(TERRAFORM) terraform plan

apply:
	$(TERRAFORM) terraform apply -auto-approve

venv:
	python -m venv $(VENV_DIR)

install: venv
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

run: venv
	$(PYTHON) $(APP) --reload

lint: venv
	$(FLAKE8) .

format: venv
	$(BLACK) --line-length 79 .
