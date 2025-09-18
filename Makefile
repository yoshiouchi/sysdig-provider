# Makefile (put this at the repo root)
# Usage:
#   make help
#   make init ENV=dev
#   make plan ENV=dev
#   make apply ENV=dev
#   make destroy ENV=dev

ENV ?= dev
TF_DIR := envs/$(ENV)
TFVARS := $(ENV).tfvars
TF := terraform

.PHONY: help init plan apply destroy fmt validate

help:
	@echo "Targets:"
	@echo "  make init ENV=dev       - terraform init in envs/<env>"
	@echo "  make plan ENV=dev       - terraform plan  with -var-file=<env>.tfvars"
	@echo "  make apply ENV=dev      - terraform apply with -var-file=<env>.tfvars"
	@echo "  make destroy ENV=dev    - terraform destroy with -var-file=<env>.tfvars"
	@echo "  make fmt                - terraform fmt -recursive"
	@echo "  make validate ENV=dev   - terraform validate in envs/<env>"

# Ensure the env directory exists before running anything
check-env:
	@test -d "$(TF_DIR)" || (echo "Environment '$(ENV)' not found at $(TF_DIR)"; exit 1)

init: check-env
	cd "$(TF_DIR)" && $(TF) init

plan: check-env
	cd "$(TF_DIR)" && $(TF) plan -var-file="$(TFVARS)"

apply: check-env
	cd "$(TF_DIR)" && $(TF) apply -var-file="$(TFVARS)"

destroy: check-env
	cd "$(TF_DIR)" && $(TF) destroy -var-file="$(TFVARS)"

fmt:
	$(TF) fmt -recursive

validate: check-env
	cd "$(TF_DIR)" && $(TF) validate
