# Terraform Azure Provider Deprecation Warnings

## Overview
The following deprecation warnings were identified during Terraform plan execution. These should be addressed to maintain compatibility with future versions of the Azure provider.

## Issues Found

### 1. **docker_bridge_cidr Deprecation** (AKS Module)
- **Location**: `modules/aks/main.tf` line 82
- **Property**: `docker_bridge_cidr = "172.17.0.1/16"`
- **Status**: Deprecated in Azure Provider v3.x
- **Removal**: Will be removed in Azure Provider v4.0
- **Impact**: Medium - Only affects AKS configuration
- **Solution**: Remove the `docker_bridge_cidr` argument from the `azurerm_kubernetes_cluster` resource

**Example Fix:**
```hcl
# Remove this line:
# docker_bridge_cidr = "172.17.0.1/16"
```

### 2. **connection_strings Attribute Deprecation** (CosmosDB)
- **Location**: `modules/databases/main.tf` line 151
- **Property**: `azurerm_cosmosdb_account.main.connection_strings`
- **Status**: Deprecated in Azure Provider
- **Impact**: Low - Only affects output values
- **Solution**: Use `primary_sql_connection_string` or `primary_readonly_sql_connection_string` instead

**Example Fix:**
```hcl
# Change from:
value = azurerm_cosmosdb_account.main.connection_strings

# To:
value = azurerm_cosmosdb_account.main.primary_sql_connection_string
```

## Additional Warnings

The output indicates there are **9 more similar warnings** throughout the codebase. Common deprecations to check:
- Azure Provider deprecated attributes (review [Azure Provider docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs))
- Network configuration parameters
- Database configuration parameters
- Authentication configuration parameters

## Next Steps

1. **Priority 1 (Medium)**: Fix `docker_bridge_cidr` in AKS module
2. **Priority 2 (Low)**: Fix `connection_strings` in CosmosDB output
3. **Priority 3**: Identify and fix remaining 9 warnings
4. **Testing**: Re-run `terraform plan` to verify all warnings are resolved
5. **Provider Upgrade**: Plan for Azure Provider v4.0 upgrade when available

## Commands to Identify All Deprecations

```bash
# Run terraform plan with deprecation warnings
cd IaC
terraform plan -var="environment=dev" 2>&1 | grep -i "deprecated"

# Check provider documentation
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
```

## Prevention

- Enable provider version constraints in `providers.tf` to control upgrades
- Subscribe to Azure Terraform Provider release notes
- Regular review of deprecation warnings during CI/CD pipeline runs
- Include deprecation warning checks in your code review process

---

**Last Updated**: December 27, 2025
**Terraform Version**: 1.5.0
**Azure Provider**: Check `providers.tf` for current version constraint
