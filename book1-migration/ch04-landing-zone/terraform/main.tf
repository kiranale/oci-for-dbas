# DBA landing zone for migrations — "OCI for DBAs" Book 1, Chapter 4.
# Runs as-is in OCI Resource Manager (tenancy_ocid and region are filled in automatically).

terraform {
  required_version = ">= 1.2"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

provider "oci" {
  region = var.region
}

locals {
  tags = {
    "env"        = var.environment
    "owner"      = var.owner
    "app"        = var.prefix
    "managed-by" = "terraform"
  }
  bastion_name = "${replace(var.prefix, "-", "")}bastion"
}

# ---------------------------------------------------------------- compartments
resource "oci_identity_compartment" "lz" {
  compartment_id = var.tenancy_ocid
  name           = "${var.prefix}-lz"
  description    = "Landing zone for ${var.prefix} migrations (${var.environment})"
  enable_delete  = true
  freeform_tags  = local.tags
}

resource "oci_identity_compartment" "child" {
  for_each       = toset(["network", "database", "app", "security"])
  compartment_id = oci_identity_compartment.lz.id
  name           = each.key
  description    = "${var.prefix} landing zone: ${each.key}"
  enable_delete  = true
  freeform_tags  = local.tags
}
