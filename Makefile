# =============================================================================
# CloudOps Bootstrap — Makefile
# =============================================================================
# Common commands for development, testing, and deployment.
# Usage: make <target>
# =============================================================================

.DEFAULT_GOAL := help
SHELL := /bin/bash

# Project
PROJECT_NAME := cloudops-bootstrap
IAC_DIR := IaC
JAVA_DIR := java-app
PYTHON_DIR := python-app

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m

# =============================================================================
# Help
# =============================================================================
.PHONY: help
help: ## Show this help
	@echo ""
	@echo "$(BLUE)$(PROJECT_NAME)$(NC) — Available targets:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

# =============================================================================
# Infrastructure (Terraform)
# =============================================================================
.PHONY: tf-init tf-plan tf-apply tf-fmt tf-validate tf-destroy

tf-init: ## Initialize Terraform
	cd $(IAC_DIR) && terraform init

tf-plan: ## Plan infrastructure changes
	cd $(IAC_DIR) && terraform plan -out=tfplan

tf-apply: ## Apply infrastructure changes
	cd $(IAC_DIR) && terraform apply tfplan

tf-fmt: ## Format Terraform files
	cd $(IAC_DIR) && terraform fmt -recursive

tf-validate: ## Validate Terraform configuration
	cd $(IAC_DIR) && terraform fmt -check -recursive
	cd $(IAC_DIR) && terraform validate

tf-destroy: ## Destroy infrastructure (CAUTION)
	@echo "$(YELLOW)WARNING: This will destroy all infrastructure!$(NC)"
	@read -p "Type 'yes' to confirm: " confirm && [ "$$confirm" = "yes" ] || exit 1
	cd $(IAC_DIR) && terraform destroy

tf-output: ## Show Terraform outputs
	cd $(IAC_DIR) && terraform output

# =============================================================================
# Java Application
# =============================================================================
.PHONY: java-build java-test java-docker java-run

java-build: ## Build Java application
	cd $(JAVA_DIR) && mvn clean package -DskipTests

java-test: ## Run Java tests
	cd $(JAVA_DIR) && mvn clean verify

java-docker: ## Build Java Docker image
	cd $(JAVA_DIR) && docker build -t $(PROJECT_NAME)-java:latest .

java-run: ## Run Java application locally
	cd $(JAVA_DIR) && mvn spring-boot:run

# =============================================================================
# Python Application
# =============================================================================
.PHONY: python-install python-test python-lint python-docker python-run

python-install: ## Install Python dependencies
	cd $(PYTHON_DIR) && pip install -r requirements.txt -r requirements-dev.txt

python-test: ## Run Python tests with coverage
	cd $(PYTHON_DIR) && pytest --cov=app --cov-report=term-missing

python-lint: ## Lint Python code
	cd $(PYTHON_DIR) && flake8 app/

python-docker: ## Build Python Docker image
	cd $(PYTHON_DIR) && docker build -t $(PROJECT_NAME)-python:latest .

python-run: ## Run Python application locally
	cd $(PYTHON_DIR) && uvicorn app.main:app --reload --port 8000

# =============================================================================
# Quality & CI
# =============================================================================
.PHONY: lint test check

lint: tf-validate python-lint ## Run all linters
	@echo "$(GREEN)All linters passed.$(NC)"

test: java-test python-test ## Run all tests
	@echo "$(GREEN)All tests passed.$(NC)"

check: lint test ## Run all checks (lint + test)
	@echo "$(GREEN)All checks passed.$(NC)"

# =============================================================================
# Docker
# =============================================================================
.PHONY: docker-build docker-push

docker-build: java-docker python-docker ## Build all Docker images
	@echo "$(GREEN)All Docker images built.$(NC)"

# =============================================================================
# Utilities
# =============================================================================
.PHONY: clean az-login

clean: ## Clean build artifacts
	cd $(JAVA_DIR) && mvn clean 2>/dev/null || true
	find $(PYTHON_DIR) -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find $(PYTHON_DIR) -type d -name .pytest_cache -exec rm -rf {} + 2>/dev/null || true
	rm -f $(IAC_DIR)/tfplan
	@echo "$(GREEN)Cleaned.$(NC)"

az-login: ## Login to Azure CLI
	az login
	@echo "$(GREEN)Azure login complete. Set subscription with: az account set --subscription <ID>$(NC)"
