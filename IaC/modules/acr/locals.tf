locals {
  acr_name = replace("${var.environment}kustomeracr", "-", "")
}
