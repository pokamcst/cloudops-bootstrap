# Enterprise Photo Sharing Platform Infrastructure

This repository contains the Terraform configuration for the Enterprise Photo Sharing Platform infrastructure on Azure.

## Architecture Overview

The infrastructure consists of the following components:

- **Networking**: Virtual Network, Subnets, Network Security Groups, and Private Endpoints
- **Security**: Key Vault, Managed Identities, and RBAC
- **Compute**: Azure Kubernetes Service (AKS) with multiple node pools
- **Storage**: Azure Blob Storage for media files
- **Databases**: Cosmos DB for application data
- **CDN**: Azure Front Door for global content delivery
- **Monitoring**: Application Insights, Log Analytics, and Alert Rules

## Prerequisites

- Azure CLI
- Terraform >= 1.5.0
- Azure subscription with appropriate permissions
- Azure Storage Account for Terraform state

## Directory Structure

```
terraform/
├── main.tf              # Main Terraform configuration
├── variables.tf         # Input variables
├── outputs.tf          # Output values
├── providers.tf        # Provider configuration
├── locals.tf           # Local values
├── resource_group.tf   # Resource group configuration
├── modules/            # Reusable modules
│   ├── networking/     # Networking module
│   ├── security/       # Security module
│   ├── aks/           # AKS module
│   ├── front_door/    # Front Door module
│   ├── storage/       # Storage module
│   ├── databases/     # Databases module
│   └── monitoring/    # Monitoring module
└── tests/             # Test configurations
    └── terraform-compliance/  # Security compliance tests
```

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Review the plan:
   ```bash
   terraform plan -var="environment=prod"
   ```

3. Apply the configuration:
   ```bash
   terraform apply -var="environment=prod"
   ```

## Variables

Key variables that can be customized:

- `environment`: Environment name (dev, staging, prod)
- `location`: Azure region for resources
- `resource_group_name`: Name of the resource group
- `kubernetes_version`: Kubernetes version for AKS
- `address_space`: Virtual network address space
- `enable_private_endpoints`: Enable private endpoints for Azure services
- `enable_diagnostic_settings`: Enable diagnostic settings for resources
- `log_retention_days`: Number of days to retain logs

## Outputs

The configuration provides the following outputs:

- Resource group name
- AKS cluster name and kubeconfig
- Front Door endpoint
- Cosmos DB endpoint
- Blob Storage endpoint
- Key Vault ID
- Log Analytics workspace ID
- Application Insights ID and instrumentation key

## Security

The infrastructure implements several security measures:

- Private endpoints for Azure services
- Network security groups with restricted access
- Key Vault for secrets management
- Managed identities for service authentication
- Diagnostic settings for audit logging
- RBAC for access control

## Monitoring

The infrastructure includes comprehensive monitoring:

- Application Insights for application monitoring
- Log Analytics for log aggregation
- Alert rules for key metrics
- Diagnostic settings for Azure resources
- Global availability monitoring

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 