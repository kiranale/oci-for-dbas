# Three roles instead of "everyone is an administrator".
resource "oci_identity_group" "role" {
  for_each       = toset(["db-admins", "network-admins", "migration-ops"])
  compartment_id = var.tenancy_ocid
  name           = "${var.prefix}-${each.key}"
  description    = "${var.prefix} landing zone: ${each.key}"
  freeform_tags  = local.tags
}

locals {
  c   = { for k, v in oci_identity_compartment.child : k => v.id }
  dba = oci_identity_group.role["db-admins"].name
  net = oci_identity_group.role["network-admins"].name
  ops = oci_identity_group.role["migration-ops"].name
}

resource "oci_identity_policy" "lz" {
  compartment_id = var.tenancy_ocid
  name           = "${var.prefix}-lz-policy"
  description    = "Least-privilege access to the ${var.prefix} landing zone"
  freeform_tags  = local.tags
  statements = [
    # DBAs own the databases and their backups
    "Allow group ${local.dba} to manage database-family in compartment id ${local.c["database"]}",
    "Allow group ${local.dba} to manage autonomous-database-family in compartment id ${local.c["database"]}",
    "Allow group ${local.dba} to manage object-family in compartment id ${local.c["database"]}",
    "Allow group ${local.dba} to use virtual-network-family in compartment id ${local.c["network"]}",
    "Allow group ${local.dba} to read vaults in compartment id ${local.c["security"]}",
    "Allow group ${local.dba} to use keys in compartment id ${local.c["security"]}",
    "Allow group ${local.dba} to use bastion in compartment id ${local.c["network"]}",
    "Allow group ${local.dba} to manage bastion-session in compartment id ${local.c["network"]}",
    "Allow group ${local.dba} to read all-resources in compartment id ${oci_identity_compartment.lz.id}",
    # Network team owns the network
    "Allow group ${local.net} to manage virtual-network-family in compartment id ${local.c["network"]}",
    "Allow group ${local.net} to manage bastion-family in compartment id ${local.c["network"]}",
    "Allow group ${local.net} to read all-resources in compartment id ${oci_identity_compartment.lz.id}",
    # Migration operators move data, nothing else
    "Allow group ${local.ops} to manage objects in compartment id ${local.c["database"]}",
    "Allow group ${local.ops} to read buckets in compartment id ${local.c["database"]}",
    "Allow group ${local.ops} to read database-family in compartment id ${local.c["database"]}",
    "Allow group ${local.ops} to use bastion in compartment id ${local.c["network"]}",
    "Allow group ${local.ops} to manage bastion-session in compartment id ${local.c["network"]}",
  ]
}
