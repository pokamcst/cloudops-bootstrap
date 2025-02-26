# Enterprise Workflow Cloud-DevOps for All

**A Comprehensive Guide for Engineers**

## Table of Contents

1. [Introduction](#introduction)
2. [Enterprise Photo Sharing Platform Architecture](#enterprise-photo-sharing-platform-architecture)
3. [Infrastructure as Code with Terraform](#infrastructure-as-code-with-terraform)
    - [Main Terraform Configuration](#main-terraform-configuration)
    - [Networking Module](#networking-module)
    - [Security Module](#security-module)
    - [AKS Module](#aks-module)
    - [Front Door Module](#front-door-module)
4. [Enterprise Observability Platform](#enterprise-observability-platform)
    - [Monitoring Infrastructure](#monitoring-infrastructure)
    - [OpenTelemetry Integration](#opentelemetry-integration)
    - [SLA and Customer Experience Monitoring](#sla-and-customer-experience-monitoring)
    - [Prometheus Configuration](#prometheus-configuration)
    - [Custom Webhook Adapter](#custom-webhook-adapter)
5. [CI/CD Pipelines](#cicd-pipelines)
    - [Azure DevOps Pipeline](#azure-devops-pipeline)
    - [GitHub Actions Workflow](#github-actions-workflow)
    - [GitOps with Flux CD](#gitops-with-flux-cd)
6. [Troubleshooting Guide](#troubleshooting-guide)
    - [Infrastructure Issues](#infrastructure-issues)
    - [Monitoring Alerts](#monitoring-alerts)
    - [CI/CD Pipeline Failures](#cicd-pipeline-failures)
7. [Best Practices](#best-practices)
    - [Security Standards](#security-standards)
    - [Performance Optimization](#performance-optimization)
    - [Cost Management](#cost-management)
8. [Appendix](#appendix)
    - [Useful Commands](#useful-commands)
    - [Reference Links](#reference-links)

## Introduction

This document serves as a comprehensive guide for engineers working on the Enterprise Photo Sharing Platform. It covers the architectural design, infrastructure setup, monitoring solutions, and CI/CD pipelines. With this guide, engineers will be able to implement solutions and troubleshoot issues efficiently across the entire platform.

The Enterprise Workflow Cloud-DevOps for All methodology provides a streamlined approach to managing cloud infrastructure, application deployment, and monitoring in a cohesive manner. By following these practices, you can ensure consistent, reliable, and scalable operations for enterprise workloads.

## Enterprise Photo Sharing Platform Architecture

The Enterprise Photo Sharing Platform is built on Azure with a focus on security, scalability, and customer experience. The architecture incorporates IT standards, enterprise governance, and customer-centric components.

![img_1.png](img_1.png)

The platform architecture includes:

### Customer Interaction Layer
- Web Portal: Customer-facing web application
- Mobile Apps: iOS and Android applications
- Partner API: RESTful APIs for integration with customer systems
- Analytics Dashboard: Self-service customer analytics and reports
- Customer Support Portal: Ticketing and support interface

### Security & Governance Layer
- Azure AD/RBAC: Role-based access control integrated with corporate identity
- Azure Policy: Enforcement of corporate compliance standards
- Azure Firewall: Network traffic filtering and inspection
- Security Center: Threat monitoring and vulnerability management
- Key Vault: Secrets and certificate management with HSM backing

### Network Layer
- Azure Front Door + CDN: Global content delivery and traffic management
- Azure Virtual Network: Network isolation and security
- Network Security Groups: Fine-grained traffic control
- Private Endpoints: Secure connectivity to Azure services

### Compute Layer (AKS Cluster)
- System Pool: For Kubernetes system components
- Frontend Pool: For user-facing services
- Backend Pool: For API and business logic services
- Batch Processing Pool: For media processing workloads

### IT Standards Implementation
- Network Policy Enforcement
- Container Security Scanning
- Pod Security Policies
- Service Mesh (Istio)
- Egress Lockdown
- Quota Management

### Customer Data Handling
- Multi-tenant Data Isolation
- Data Sovereignty Controls
- Data Retention Policies
- GDPR Compliance Tools
- Customer Data Encryption
- Audit Logging

### Enterprise Data Services
- Blob Storage: Tiered storage for media content
- Cosmos DB: NoSQL database with global distribution
- Azure Cache for Redis: Session state and caching
- Azure SQL DB: Relational data and reporting
- Data Lake Storage: Analytics and customer insights

### Enterprise Observability Platform
- OpenTelemetry: Standardized telemetry collection
- Azure Monitor: Infrastructure monitoring
- Application Insights: Application performance monitoring
- Log Analytics: Log aggregation and analysis
- SLA & Customer Experience Monitoring

### Enterprise Infrastructure Management
- Terraform Modules: Reusable infrastructure components
- Azure DevOps/GitHub Actions: CI/CD pipelines
- Flux CD: GitOps deployment for Kubernetes
- Release Management & Compliance: Change control processes

## Infrastructure as Code with Terraform

The entire infrastructure is defined as code using Terraform, enabling consistent, repeatable deployments across environments.

![img_2.png](img_2.png)

### Main Terraform Configuration

```terraform
# main.tf - Root module for Enterprise Photo Sharing Platform

provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "terraformstateentphoto"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

# Variables
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  default     = "prod"
}

variable "location" {
  description = "Azure region for resources"
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "photo-sharing-platform-rg"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "Enterprise Photo Sharing Platform"
    Owner       = "IT Operations"
    CostCenter  = "IT-100"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.resource_group_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

# Call modules
module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

module "security" {
  source              = "./modules/security"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  virtual_network_id  = module.networking.vnet_id
  subnet_ids          = module.networking.subnet_ids
  tags                = var.tags
}

module "aks" {
  source                = "./modules/aks"
  resource_group_name   = azurerm_resource_group.main.name
  location              = var.location
  environment           = var.environment
  kubernetes_version    = "1.27.3"
  vnet_subnet_id        = module.networking.aks_subnet_id
  node_resource_group   = "${var.resource_group_name}-${var.environment}-aks-nodes"
  key_vault_id          = module.security.key_vault_id
  user_assigned_identity_id = module.security.aks_identity_id
  tags                  = var.tags
  depends_on            = [module.networking, module.security]
}

module "front_door" {
  source              = "./modules/front_door"
  resource_group_name = azurerm_resource_group.main.name
  environment         = var.environment
  backend_pool_hosts  = [module.aks.ingress_lb_ip]
  tags                = var.tags
  depends_on          = [module.aks]
}

module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  subnet_ids          = module.networking.subnet_ids
  private_endpoint_subnet_id = module.networking.pe_subnet_id
  tags                = var.tags
}

module "databases" {
  source              = "./modules/databases"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  subnet_ids          = module.networking.subnet_ids
  private_endpoint_subnet_id = module.networking.pe_subnet_id
  tags                = var.tags
}

module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  aks_cluster_id      = module.aks.cluster_id
  workspace_id        = module.security.log_analytics_workspace_id
  tags                = var.tags
  depends_on          = [module.aks]
}

# Outputs
output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "aks_kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}

output "front_door_endpoint" {
  value = module.front_door.endpoint
}

output "cosmos_db_endpoint" {
  value = module.databases.cosmos_db_endpoint
}

output "blob_storage_primary_endpoint" {
  value = module.storage.blob_storage_primary_endpoint
}
```

### Networking Module

```terraform
# modules/networking/main.tf

# Variables
variable "resource_group_name" {}
variable "location" {}
variable "environment" {}
variable "address_space" {
  type = list(string)
}
variable "tags" {
  type = map(string)
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-photo-platform-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

# Subnets
resource "azurerm_subnet" "aks" {
  name                 = "snet-aks-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/20"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.AzureCosmosDB"]
}

# Additional subnet definitions...

# Network Security Groups
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "nsg-aks-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Additional NSG and rule definitions...

# Outputs
output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks.id
}

# Additional outputs...
```

Additional module definitions (Security, AKS, Front Door, etc.) would follow a similar pattern.

## Enterprise Observability Platform

The Enterprise Observability Platform provides comprehensive monitoring for the entire photo sharing platform, from infrastructure to customer experience metrics.

![img_3.png](img_3.png)

### Monitoring Infrastructure

```terraform
# modules/monitoring/main.tf

# Variables
variable "resource_group_name" {}
variable "location" {}
variable "environment" {}
variable "aks_cluster_id" {}
variable "workspace_id" {}
variable "tags" {
  type = map(string)
}

# Get existing Log Analytics workspace
data "azurerm_log_analytics_workspace" "main" {
  name                = element(split("/", var.workspace_id), length(split("/", var.workspace_id)) - 1)
  resource_group_name = var.resource_group_name
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = "appi-photo-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = data.azurerm_log_analytics_workspace.main.id
  tags                = var.tags
  
  sampling_percentage = 100
  retention_in_days   = 90
}

# Additional Application Insights instances for different components...

# Action Group for critical alerts
resource "azurerm_monitor_action_group" "critical" {
  name                = "ag-critical-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = "critical"
  tags                = var.tags

  email_receiver {
    name                    = "ops-team"
    email_address           = "ops-team@example.com"
    use_common_alert_schema = true
  }

  sms_receiver {
    name         = "oncall"
    country_code = "1"  # US
    phone_number = "5551234567"
  }

  webhook_receiver {
    name                    = "ServiceNow"
    service_uri             = "https://servicenow.example.com/api/incidents"
    use_common_alert_schema = true
  }
}

# Alert rules, web tests, and other monitoring resources...
```

### OpenTelemetry Integration

```yaml
# opentelemetry-collector.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-collector-conf
  namespace: monitoring
  labels:
    app: opentelemetry-collector
data:
  collector.yaml: |
    receivers:
      prometheus:
        config:
          scrape_configs:
            - job_name: 'kubernetes-pods'
              kubernetes_sd_configs:
                - role: pod
              relabel_configs:
                - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
                  action: keep
                  regex: true
                # Additional relabel configurations...
      
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
      
      # Additional receivers...
    
    processors:
      batch:
        timeout: 1s
        send_batch_size: 1024
      
      # Additional processors...
    
    exporters:
      logging:
        loglevel: debug
      
      azuremonitor:
        instrumentation_key: "${env:APPINSIGHTS_INSTRUMENTATIONKEY}"
      
      # Additional exporters...
    
    service:
      extensions: [health_check, memory_ballast]
      pipelines:
        traces:
          receivers: [otlp, jaeger, zipkin]
          processors: [batch, k8s_attributes, memory_limiter, resource, attributes]
          exporters: [azuremonitor, otlphttp, logging]
          
        # Additional pipelines...
```

### SLA and Customer Experience Monitoring

```terraform
# modules/monitoring/customer_experience_monitor.tf

# Variables
variable "customer_tier_thresholds" {
  description = "Response time thresholds for different customer tiers (in ms)"
  type = map(object({
    p50 = number
    p90 = number
    p99 = number
  }))
  default = {
    enterprise = {
      p50 = 100
      p90 = 400
      p99 = 1000
    }
    premium = {
      p50 = 200
      p90 = 500
      p99 = 1500
    }
    standard = {
      p50 = 300
      p90 = 600
      p99 = 2000
    }
  }
}

# Web test for global availability monitoring (synthetic)
resource "azurerm_application_insights_web_test" "global_availability" {
  for_each = {
    "us"      = "US West Home Page"
    "europe"  = "Europe Home Page"
    "asia"    = "Asia Home Page"
    "upload"  = "Photo Upload Flow"
    "gallery" = "Gallery Browse Flow"
    "api"     = "API Health Check"
  }

  name                    = "webtest-photo-${each.key}-${var.environment}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = azurerm_application_insights.main.id
  kind                    = each.key == "api" ? "ping" : "standard" # Use standard for multi-step tests
  frequency               = 300
  timeout                 = 30
  enabled                 = true
  geo_locations           = ["us-tx-sn1-azr", "us-il-ch1-azr", "emea-gb-db3-azr", "apac-hk-hkn-azr", "emea-fr-pra-edge"]
  retry_enabled           = true
  tags                    = var.tags

  # Test configuration XML...
}

# Alerts and dashboards for SLA monitoring...
```

### Prometheus Configuration

```yaml
# prometheus-values.yaml
server:
  global:
    scrape_interval: 15s
    evaluation_interval: 15s
    scrape_timeout: 10s
    external_labels:
      environment: "${environment}"
      cluster: "aks-photo-${environment}"
      
  persistentVolume:
    size: 50Gi
    storageClass: "managed-premium"
  
  retention: "15d"
  
  resources:
    limits:
      cpu: 2000m
      memory: 4Gi
    requests:
      cpu: 1000m
      memory: 2Gi
  
  nodeSelector:
    nodepool-type: backend
  
  # Alert rules
  alertingRules:
    groups:
      - name: kubernetes-system-alerts
        rules:
          - alert: KubernetesNodeDown
            expr: kube_node_status_condition{condition="Ready",status="true"} == 0
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: "Kubernetes node down"
              description: "Node {{ $labels.node }} has been down for more than 5 minutes"
          
          # Additional alert rules...
      
      - name: photo-sharing-platform-alerts
        rules:
          - alert: HighErrorRate
            expr: sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) * 100 > 5
            for: 5m
            labels:
              severity: critical
              service: photo-sharing-platform
            annotations:
              summary: "High HTTP error rate"
              description: "Error rate is above 5% for the last 5 minutes ({{ $value }}%)"
          
          # Additional alert rules...

# Additional Prometheus configuration...
```

### Custom Webhook Adapter

```javascript
// app.js - Prometheus Webhook Adapter for Azure Monitor
const express = require('express');
const bodyParser = require('body-parser');
const appInsights = require('applicationinsights');
const app = express();
const port = process.env.PORT || 8080;

// Initialize App Insights
if (process.env.APPINSIGHTS_INSTRUMENTATIONKEY) {
  appInsights.setup(process.env.APPINSIGHTS_INSTRUMENTATIONKEY)
    .setAutoDependencyCorrelation(true)
    .setAutoCollectRequests(true)
    .setAutoCollectPerformance(true)
    .setAutoCollectExceptions(true)
    .setAutoCollectDependencies(true)
    .setAutoCollectConsole(true)
    .setUseDiskRetryCaching(true)
    .setSendLiveMetrics(true);

  appInsights.defaultClient.context.tags[appInsights.defaultClient.context.keys.cloudRole] = "PrometheusWebhookAdapter";
  appInsights.defaultClient.context.tags[appInsights.defaultClient.context.keys.cloudRoleInstance] = require('os').hostname();
  
  // Add custom properties to all events
  appInsights.defaultClient.addTelemetryProcessor((envelope) => {
    envelope.data.baseData.properties = envelope.data.baseData.properties || {};
    envelope.data.baseData.properties.environment = process.env.ENVIRONMENT || 'development';
    return true;
  });
  
  appInsights.start();
  console.log("Application Insights initialized");
} else {
  console.warn("No Application Insights key found, telemetry is disabled");
}

// Middleware and route handlers...

function processAlertToAppInsights(alert) {
  // Alert processing logic...
}

// Start the server
app.listen(port, () => {
  console.log(`Prometheus Webhook Adapter running on port ${port}`);
});

// Graceful shutdown handlers...
```

## CI/CD Pipelines

![img_4.png](img_4.png)

### Azure DevOps Pipeline

```yaml
# azure-pipelines-monitoring.yml
# Pipeline for deploying the Enterprise Observability Platform

trigger:
  branches:
    include:
      - main
  paths:
    include:
      - 'monitoring/**'
      - 'infrastructure/prometheus/**'

pool:
  vmImage: 'ubuntu-latest'

variables:
  - name: environment
    value: 'prod'
  - name: acrName
    value: 'acrphotosharing$(environment)'
  - name: tagVersion
    value: '$(Build.BuildNumber)'
  - name: aksResourceGroup
    value: 'photo-sharing-platform-rg-$(environment)'
  - name: aksClusterName
    value: 'aks-photo-$(environment)'

stages:
- stage: BuildAndPush
  displayName: 'Build and Push Docker Images'
  jobs:
  - job: BuildWebhookAdapter
    displayName: 'Build and Push Webhook Adapter'
    steps:
    - task: Docker@2
      displayName: 'Build Webhook Adapter'
      # Task configuration...
    
    - task: Docker@2
      displayName: 'Push Webhook Adapter'
      # Task configuration...

- stage: DeployMonitoring
  displayName: 'Deploy Monitoring Components'
  dependsOn: BuildAndPush
  jobs:
  - job: DeployHelm
    displayName: 'Deploy Prometheus and Grafana'
    steps:
    - task: HelmInstaller@1
      displayName: 'Install Helm'
      # Task configuration...
    
    # Additional deployment steps...

# Additional stages and jobs...
```

### GitHub Actions Workflow

```yaml
# .github/workflows/monitoring-pipeline.yml
name: Enterprise Observability Platform

on:
  push:
    branches:
      - main
    paths:
      - 'monitoring/**'
      - 'infrastructure/prometheus/**'
      - '.github/workflows/monitoring-pipeline.yml'
  pull_request:
    branches:
      - main
    paths:
      - 'monitoring/**'
      - 'infrastructure/prometheus/**'
      - '.github/workflows/monitoring-pipeline.yml'
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        default: 'prod'
        type: choice
        options:
          - dev
          - staging
          - prod

env:
  ENVIRONMENT: ${{ github.event.inputs.environment || 'prod' }}
  ACR_NAME: acrphotosharing${{ github.event.inputs.environment || 'prod' }}
  AKS_RESOURCE_GROUP: photo-sharing-platform-rg-${{ github.event.inputs.environment || 'prod' }}
  AKS_CLUSTER_NAME: aks-photo-${{ github.event.inputs.environment || 'prod' }}
  TAG_VERSION: ${{ github.sha }}

jobs:
  build-webhook-adapter:
    name: Build and Push Webhook Adapter
    runs-on: ubuntu-latest
    
    steps:
    - name: Check out code
      uses: actions/checkout@v3
      
    # Additional build and push steps...
  
  terraform-apply:
    name: Apply Terraform Monitoring Configuration
    needs: build-webhook-adapter
    if: github.event_name != 'pull_request'
    runs-on: ubuntu-latest
    
    steps:
    - name: Check out code
      uses: actions/checkout@v3
      
    # Additional Terraform steps...
      
  # Additional jobs...
```

### GitOps with Flux CD

```yaml
# clusters/prod/flux-system/gotk-sync.yaml
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
  name: monitoring-infra
  namespace: flux-system
spec:
  interval: 1m0s
  ref:
    branch: main
  url: https://github.com/enterprise-photo-sharing/monitoring-gitops
  secretRef:
    name: github-credentials
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: monitoring-infra
  namespace: flux-system
spec:
  interval: 10m0s
  path: ./clusters/prod
  prune: true
  sourceRef:
    kind: GitRepository
    name: monitoring-infra
  validation: client
  timeout: 5m0s

# Additional GitOps configuration files...
```

```yaml
# GitHub Actions workflow for GitOps integration
# .github/workflows/gitops-monitoring.yml
name: GitOps Monitoring Pipeline

on:
  push:
    branches:
      - main
    paths:
      - 'monitoring/**'
      - 'infrastructure/prometheus/**'
      - '.github/workflows/gitops-monitoring.yml'
  # Additional triggers...

env:
  ENVIRONMENT: ${{ github.event.inputs.environment || 'prod' }}
  ACR_NAME: acrphotosharing${{ github.event.inputs.environment || 'prod' }}
  GITOPS_REPO: enterprise-photo-sharing/monitoring-gitops
  TAG_VERSION: ${{ github.sha }}
  IMAGE_NAME: prometheus-webhook-adapter

jobs:
  build-and-push:
    name: Build and Push WebHook Adapter
    runs-on: ubuntu-latest
    
    steps:
    - name: Check out code
      uses: actions/checkout@v3
      
    # Additional build and push steps...
  
  update-gitops-repo:
    name: Update GitOps Repository
    needs: build-and-push
    if: github.event_name != 'pull_request'
    runs-on: ubuntu-latest
    
    steps:
    - name: Check out GitOps code
      uses: actions/checkout@v3
      with:
        repository: ${{ env.GITOPS_REPO }}
        token: ${{ secrets.GITOPS_PAT }}
        ref: main
      
    # Additional steps to update GitOps repo...
  
  # Additional jobs...
```

## Troubleshooting Guide

![img_5.png](img_5.png)

### Infrastructure Issues

#### Azure Resources Not Deploying

**Symptoms:**
- Terraform apply fails with errors
- Resources not showing up in the Azure Portal

**Steps to Troubleshoot:**
1. Check Terraform logs for specific error messages
2. Verify service quotas and limits in the Azure subscription
3. Ensure the service principal has sufficient permissions
4. Check for resource name conflicts or invalid configurations

**Resolution Examples:**
```bash
# Get detailed error message from Terraform
terraform apply -var="environment=prod" -var="resource_group_name=photo-sharing-platform-rg-prod" -auto-approve

# Check Azure service principal permissions
az role assignment list --assignee <service-principal-id>

# Check resource provider registration status
az provider list --query "[?registrationState=='NotRegistered']"
```

#### AKS Connectivity Issues

**Symptoms:**
- Unable to connect to AKS cluster
- kubectl commands timing out or failing
- Networking errors between pods

**Steps to Troubleshoot:**
1. Verify AKS cluster health in Azure Portal
2. Check network security groups and route tables
3. Validate virtual network and subnet configurations
4. Review AKS system logs

**Resolution Examples:**
```bash
# Get AKS credentials
az aks get-credentials --resource-group photo-sharing-platform-rg-prod --name aks-photo-prod --admin

# Check AKS cluster status
az aks show --resource-group photo-sharing-platform-rg-prod --name aks-photo-prod --output table

# Check node status
kubectl get nodes -o wide

# Check pod networking
kubectl run -i --tty --rm debug --image=mcr.microsoft.com/aks/fundamental/base-ubuntu:v0.0.11 --restart=Never -- bash
```

### Monitoring Alerts

#### False Positive Alerts

**Symptoms:**
- Frequent alerts with no actual issues
- Alert thresholds being triggered unnecessarily

**Steps to Troubleshoot:**
1. Review alert configurations and thresholds
2. Check historical metrics data to identify patterns
3. Analyze application behavior during alert periods
4. Adjust alert thresholds or time windows as needed

**Resolution Examples:**
```terraform
# Adjust alert threshold in Terraform
resource "azurerm_monitor_metric_alert" "api_response_time" {
  # ...
  criteria {
    # ...
    threshold        = 1500  # Increased from 1000ms to 1500ms
  }
  # ...
}
```

#### Missing Alerts

**Symptoms:**
- Issues occurring without alerts being triggered
- Alerts not being received by the team

**Steps to Troubleshoot:**
1. Verify alert rule configurations
2. Check action group settings and recipient information
3. Validate metric collection is working correctly
4. Test alert rules manually

**Resolution Examples:**
```bash
# Check Azure Monitor alert rules
az monitor alert list --resource-group photo-sharing-platform-rg-prod

# Test action group
az monitor action-group test --name ag-critical-prod --resource-group photo-sharing-platform-rg-prod
```

### CI/CD Pipeline Failures

#### Build Failures

**Symptoms:**
- Pipeline fails during build stage
- Docker image creation errors

**Steps to Troubleshoot:**
1. Review build logs for specific error messages
2. Validate Dockerfile and application code
3. Check for dependency issues or version conflicts
4. Verify access to required resources (ACR, etc.)

**Resolution Examples:**
```bash
# Test Docker build locally
docker build -t prometheus-webhook-adapter:test ./monitoring/prometheus-webhook-adapter

# Check ACR access
az acr login --name acrphotosharingprod

# Verify image in ACR
az acr repository show --name acrphotosharingprod --repository prometheus-webhook-adapter
```

#### Deployment Failures

**Symptoms:**
- Pipeline succeeds in build but fails during deployment
- Kubernetes resources not applying correctly
- Helm chart installation errors

**Steps to Troubleshoot:**
1. Check deployment logs for specific error messages
2. Validate Kubernetes manifest files and Helm charts
3. Verify connectivity to the AKS cluster
4. Check for namespace, quota, or permission issues

**Resolution Examples:**
```bash
# Check for syntax errors in Kubernetes manifests
kubectl apply --dry-run=client -f monitoring/opentelemetry/opentelemetry-deployment.yaml

# Debug Helm installation
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f infrastructure/prometheus/prometheus-values.yaml \
  --debug

# Check for resource constraints
kubectl describe quota -n monitoring
```

#### GitOps Synchronization Issues

**Symptoms:**
- Changes pushed to GitOps repository not appearing in the cluster
- Flux reporting synchronization errors

**Steps to Troubleshoot:**
1. Check Flux logs and events in the cluster
2. Verify structure and syntax of manifests in the GitOps repository
3. Check Flux components health and connectivity
4. Validate RBAC permissions for Flux controllers

**Resolution Examples:**
```bash
# Check Flux GitRepository status
kubectl get gitrepositories -n flux-system

# Check Flux Kustomization status
kubectl get kustomizations -n flux-system

# View detailed sync status
flux get all

# Check Flux controller logs
kubectl logs -n flux-system deployment/source-controller
kubectl logs -n flux-system deployment/kustomize-controller
```

## Best Practices

![img_6.png](img_6.png)

### Security Standards

#### Secret Management

Always use secure methods for managing secrets in your infrastructure:

1. **Azure Key Vault Integration**: Store sensitive data in Key Vault and access it securely.
   ```terraform
   resource "azurerm_key_vault_secret" "db_password" {
     name         = "db-password"
     value        = var.database_password
     key_vault_id = azurerm_key_vault.main.id
   }
   ```

2. **Kubernetes Secrets**: Use sealed secrets or external secret operators for Kubernetes.
   ```yaml
   apiVersion: bitnami.com/v1alpha1
   kind: SealedSecret
   metadata:
     name: database-credentials
     namespace: app
   spec:
     encryptedData:
       username: AgBy8hgJ9SDJfa...
       password: AjeD9KQ8sLkT3g...
   ```

3. **Pipeline Variables**: Use secured pipeline variables for CI/CD processes.
   ```yaml
   variables:
     - group: 'photo-sharing-platform-secrets'
   ```

#### Network Security

Implement defense-in-depth for network security:

1. **NSG Rules**: Limit traffic with Network Security Groups.
   ```terraform
   resource "azurerm_network_security_rule" "allow_https" {
     name                        = "AllowHTTPS"
     priority                    = 100
     direction                   = "Inbound"
     access                      = "Allow"
     protocol                    = "Tcp"
     source_port_range           = "*"
     destination_port_range      = "443"
     source_address_prefix       = "*"
     destination_address_prefix  = "*"
     resource_group_name         = var.resource_group_name
     network_security_group_name = azurerm_network_security_group.main.name
   }
   ```

2. **Private Endpoints**: Use private endpoints for Azure services.
   ```terraform
   resource "azurerm_private_endpoint" "sql" {
     name                = "pe-sql-${var.environment}"
     location            = var.location
     resource_group_name = var.resource_group_name
     subnet_id           = var.subnet_id
     
     private_service_connection {
       name                           = "psc-sql-${var.environment}"
       private_connection_resource_id = azurerm_sql_server.main.id
       is_manual_connection           = false
       subresource_names              = ["sqlServer"]
     }
   }
   ```

3. **Network Policies**: Implement Kubernetes network policies.
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: default-deny-all
     namespace: app
   spec:
     podSelector: {}
     policyTypes:
     - Ingress
     - Egress
   ```

#### Identity and Access

Implement proper identity management and access controls:

1. **RBAC**: Use role-based access control for all resources.
   ```terraform
   resource "azurerm_role_assignment" "example" {
     scope                = azurerm_resource_group.main.id
     role_definition_name = "Reader"
     principal_id         = data.azuread_group.developers.id
   }
   ```

2. **Managed Identities**: Use Azure Managed Identities wherever possible.
   ```terraform
   resource "azurerm_user_assigned_identity" "aks" {
     name                = "id-aks-${var.environment}"
     resource_group_name = var.resource_group_name
     location            = var.location
   }
   
   resource "azurerm_kubernetes_cluster" "main" {
     # ...
     identity {
       type = "UserAssigned"
       identity_ids = [azurerm_user_assigned_identity.aks.id]
     }
     # ...
   }
   ```

3. **Just-In-Time Access**: Implement JIT access for administrative operations.

### Performance Optimization

#### Resource Sizing

Properly size resources to balance performance and cost:

1. **AKS Node Pools**: Configure appropriate VM sizes and autoscaling.
   ```terraform
   resource "azurerm_kubernetes_cluster_node_pool" "frontend" {
     name                  = "frontend"
     kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
     vm_size               = "Standard_D4s_v3"
     node_count            = 3
     enable_auto_scaling   = true
     min_count             = 3
     max_count             = 10
     # ...
   }
   ```

2. **Database Scaling**: Configure appropriate database tiers and scaling options.
   ```terraform
   resource "azurerm_cosmosdb_account" "main" {
     # ...
     capabilities {
       name = "EnableServerless"
     }
     # ...
   }
   ```

3. **Storage Performance**: Use the right storage tier for the workload.
   ```terraform
   resource "azurerm_storage_account" "main" {
     # ...
     account_tier             = "Standard"
     account_replication_type = "GRS"
     access_tier              = "Hot"
     # ...
   }
   ```

#### Caching Strategies

Implement caching to improve performance:

1. **CDN**: Use Azure Front Door for content delivery.
   ```terraform
   resource "azurerm_frontdoor" "main" {
     # ...
     routing_rule {
       # ...
       forwarding_configuration {
         # ...
         cache_enabled                   = true
         cache_use_dynamic_compression   = true
         # ...
       }
     }
     # ...
   }
   ```

2. **Redis Cache**: Use Azure Cache for Redis for application caching.
   ```terraform
   resource "azurerm_redis_cache" "main" {
     name                = "redis-cache-${var.environment}"
     location            = var.location
     resource_group_name = var.resource_group_name
     capacity            = 2
     family              = "C"
     sku_name            = "Standard"
     # ...
   }
   ```

3. **Application-Level Caching**: Implement caching in the application code.
   ```javascript
   // Example Node.js caching middleware
   const cacheMiddleware = (req, res, next) => {
     const key = req.originalUrl;
     const cachedResponse = cache.get(key);
     
     if (cachedResponse) {
       res.send(cachedResponse);
       return;
     }
     
     res.sendResponse = res.send;
     res.send = (body) => {
       cache.set(key, body, 60 * 5); // Cache for 5 minutes
       res.sendResponse(body);
     };
     
     next();
   };
   ```

#### Performance Monitoring

Continuously monitor and optimize performance:

1. **Application Insights**: Use Application Insights for application performance monitoring.
   ```javascript
   // Integration in Node.js application
   const appInsights = require('applicationinsights');
   appInsights.setup(process.env.APPINSIGHTS_INSTRUMENTATIONKEY)
     .setAutoCollectPerformance(true)
     .setAutoCollectDependencies(true)
     .start();
   ```

2. **Container Insights**: Enable Container Insights for AKS.
   ```terraform
   resource "azurerm_kubernetes_cluster" "main" {
     # ...
     oms_agent {
       log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
     }
     # ...
   }
   ```

3. **Custom Metrics**: Implement custom metrics for business-specific performance indicators.
   ```javascript
   // Track photo upload performance
   appInsights.defaultClient.trackMetric({
     name: "PhotoUploadTime",
     value: uploadDurationMs
   });
   ```

### Cost Management

#### Resource Optimization

Optimize resources to reduce costs:

1. **Autoscaling**: Implement autoscaling for compute resources.
   ```terraform
   resource "azurerm_kubernetes_cluster" "main" {
     # ...
     default_node_pool {
       # ...
       enable_auto_scaling = true
       min_count           = 3
       max_count           = 10
       # ...
     }
     # ...
   }
   ```

2. **Storage Lifecycle Management**: Configure lifecycle policies for storage.
   ```terraform
   resource "azurerm_storage_management_policy" "main" {
     storage_account_id = azurerm_storage_account.main.id
     
     rule {
       name    = "keepLatest"
       enabled = true
       filters {
         prefix_match = ["container1/path1", "container2/path2"]
         blob_types   = ["blockBlob"]
       }
       actions {
         base_blob {
           tier_to_cool_after_days_since_modification_greater_than    = 30
           tier_to_archive_after_days_since_modification_greater_than = 90
           delete_after_days_since_modification_greater_than          = 365
         }
       }
     }
   }
   ```

3. **Reserved Instances**: Use reserved instances for stable workloads.
   ```terraform
   resource "azurerm_consumption_budget_resource_group" "main" {
     name              = "budget-${var.environment}"
     resource_group_id = azurerm_resource_group.main.id
     
     amount     = 1000
     time_grain = "Monthly"
     
     time_period {
       start_date = "2023-01-01T00:00:00Z"
       end_date   = "2023-12-31T23:59:59Z"
     }
     
     notification {
       enabled   = true
       threshold = 90.0
       operator  = "EqualTo"
       
       contact_emails = [
         "ops-team@example.com"
       ]
     }
   }
   ```

#### Cost Monitoring

Monitor and control costs:

1. **Azure Cost Management**: Configure budget alerts.
   ```terraform
   resource "azurerm_consumption_budget_resource_group" "main" {
     name              = "budget-${var.environment}"
     resource_group_id = azurerm_resource_group.main.id
     
     amount     = 1000
     time_grain = "Monthly"
     
     time_period {
       start_date = "2023-01-01T00:00:00Z"
       end_date   = "2023-12-31T23:59:59Z"
     }
     
     notification {
       enabled   = true
       threshold = 90.0
       operator  = "EqualTo"
       
       contact_emails = [
         "ops-team@example.com"
       ]
     }
   }
   ```

2. **Resource Tagging**: Use tags for cost allocation.
   ```terraform
   resource "azurerm_resource_group" "main" {
     name     = "${var.resource_group_name}-${var.environment}"
     location = var.location
     tags     = merge(var.tags, {
       Environment = var.environment
       CostCenter  = "IT-100"
       Project     = "Enterprise Photo Sharing Platform"
     })
   }
   ```

3. **Scheduled Scaling**: Implement scaling schedules for non-production environments.
   ```yaml
   apiVersion: scheduling.k8s.io/v1
   kind: CronJob
   metadata:
     name: scale-down-dev
     namespace: kube-system
   spec:
     schedule: "0 19 * * 1-5"  # 7pm weekdays
     jobTemplate:
       spec:
         template:
           spec:
             serviceAccountName: scale-dev
             containers:
             - name: kubectl
               image: bitnami/kubectl:latest
               command: ["kubectl", "scale", "deployment", "--all", "--replicas=0", "-n", "dev"]
             restartPolicy: OnFailure
   ```

## Appendix

### Useful Commands

#### Azure CLI

```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "Your Subscription Name"

# Get AKS credentials
az aks get-credentials --resource-group photo-sharing-platform-rg-prod --name aks-photo-prod --admin

# Check AKS status
az aks show --resource-group photo-sharing-platform-rg-prod --name aks-photo-prod --output table

# List AKS node pools
az aks nodepool list --resource-group photo-sharing-platform-rg-prod --cluster-name aks-photo-prod --output table

# Scale AKS node pool
az aks nodepool scale --resource-group photo-sharing-platform-rg-prod --cluster-name aks-photo-prod --name frontend --node-count 5

# Get Application Insights key
az resource show --resource-group photo-sharing-platform-rg-prod --name appi-photo-prod --resource-type microsoft.insights/components --query properties.InstrumentationKey -o tsv
```

#### Kubernetes

```bash
# Get pods across all namespaces
kubectl get pods --all-namespaces

# Get detailed information about a pod
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace> -c <container-name> --tail=100

# Port forward to a service
kubectl port-forward svc/<service-name> 8080:80 -n <namespace>

# Get cluster events
kubectl get events --sort-by='.lastTimestamp' -n <namespace>

# Check resource usage
kubectl top nodes
kubectl top pods -n <namespace>

# Execute a command in a pod
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash

# Apply a manifest
kubectl apply -f <file.yaml>

# Get all resources in a namespace
kubectl get all -n <namespace>
```

#### Terraform

```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan -var="environment=prod" -out=tfplan

# Apply changes
terraform apply tfplan

# Destroy resources
terraform destroy -var="environment=prod"

# Import existing resources
terraform import <resource_address> <azure_resource_id>

# Validate configuration
terraform validate

# Show state
terraform state list
terraform state show <resource_address>

# Workspace management
terraform workspace list
terraform workspace select <workspace_name>
terraform workspace new <workspace_name>
```

#### Helm

```bash
# Add repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install chart
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring -f values.yaml

# Upgrade chart
helm upgrade prometheus prometheus-community/kube-prometheus-stack -n monitoring -f values.yaml

# List releases
helm list -n monitoring

# Get release values
helm get values prometheus -n monitoring

# Uninstall release
helm uninstall prometheus -n monitoring

# Rollback release
helm rollback prometheus 1 -n monitoring

# Debug template rendering
helm template prometheus prometheus-community/kube-prometheus-stack -n monitoring -f values.yaml
```

#### Flux CD

```bash
# Bootstrap Flux on a cluster
flux bootstrap github \
  --owner=<org> \
  --repository=<repo> \
  --branch=main \
  --path=clusters/prod \
  --personal

# Get Flux resources
flux get all

# Reconcile sources
flux reconcile source git flux-system

# Reconcile kustomizations
flux reconcile kustomization monitoring-infra

# Create a GitRepository
flux create source git monitoring-infra \
  --url=https://github.com/enterprise-photo-sharing/monitoring-gitops \
  --branch=main \
  --interval=1m

# Create a Kustomization
flux create kustomization monitoring-infra \
  --source=monitoring-infra \
  --path="./clusters/prod" \
  --prune=true \
  --interval=10m

# Check logs
flux logs -n flux-system
```

## Enterprise Workflow Cloud-DevOps For all

### A comprehensive Solution for Enterprise Sharing Platform

![img_7.png](img_7.png)


### - Infrastructure as Code with Terraform

  This diagram shows how your Terraform modules work together to provision and manage Azure resources. 
  It highlights the modular approach and the relationship between core Terraform components and the resulting Azure infrastructure.
### - Enterprise Observability Platform 

  This visualization demonstrates your end-to-end monitoring solution, from data collection (using OpenTelemetry, Prometheus, and custom collectors) through processing and storage (with Azure Monitor, Application Insights, and Log Analytics) to visualization and alerting. 
  ### - CI/CD Pipelines  

  This design illustrates your CI/CD workflow options, including Azure DevOps, GitHub Actions, and Flux CD for GitOps. It shows the complete pipeline from source control through continuous integration and continuous deployment stages.
  ### - Troubleshooting Guide 

This diagram presents your systematic troubleshooting process alongside common issue categories (infrastructure, monitoring alerts, CI/CD pipelines) and the tools used to diagnose and resolve them.

### - Best Practices
This visual covers your recommended best practices in three key areas: security standards, performance optimization, and cost management. Each area includes specific implementation recommendations.
Summary Diagram - This overarching diagram ties all components together, showing how they interrelate around your Enterprise Photo Sharing Platform and highlighting the key benefits of your solution.

These designs provide a professional, visually appealing way to communicate the value and capabilities of your Enterprise Workflow Cloud-DevOps solution. They would be effective in both technical presentations and executive briefings, as they balance technical detail with clear, high-level concepts.

### Reference Links

- [Azure Documentation](https://docs.microsoft.com/en-us/azure/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Flux Documentation](https://fluxcd.io/docs/)
- [Azure DevOps Documentation](https://docs.microsoft.com/en-us/azure/devops/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Helm Documentation](https://helm.sh/docs/)
- [Application Insights Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
