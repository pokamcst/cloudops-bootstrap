locals {
  resource_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  })
}
