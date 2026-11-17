# ---------------------------------------------------------------- Vault + TDE master key
resource "oci_kms_vault" "lz" {
  count          = var.create_vault ? 1 : 0
  compartment_id = oci_identity_compartment.child["security"].id
  display_name   = "${var.prefix}-vault"
  vault_type     = "DEFAULT"
  freeform_tags  = local.tags
}

resource "oci_kms_key" "tde" {
  count               = var.create_vault ? 1 : 0
  compartment_id      = oci_identity_compartment.child["security"].id
  display_name        = "${var.prefix}-tde-master-key"
  management_endpoint = oci_kms_vault.lz[0].management_endpoint
  protection_mode     = "SOFTWARE"
  freeform_tags       = local.tags
  key_shape {
    algorithm = "AES"
    length    = 32
  }
}

resource "oci_ons_notification_topic" "ops" {
  compartment_id = oci_identity_compartment.child["security"].id
  name           = "${var.prefix}-ops-alerts"
  description    = "Alarms and events for the ${var.prefix} landing zone"
  freeform_tags  = local.tags
}

# ---------------------------------------------------------------- Object Storage
data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "b" {
  for_each       = toset(["migration", "backups"])
  compartment_id = oci_identity_compartment.child["database"].id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "${var.prefix}-${each.key}"
  access_type    = "NoPublicAccess"
  versioning     = "Disabled"
  freeform_tags  = local.tags
}

# ---------------------------------------------------------------- Budget
resource "oci_budget_budget" "lz" {
  compartment_id = var.tenancy_ocid
  display_name   = "${var.prefix}-lz-budget"
  description    = "Monthly budget for the ${var.prefix} landing zone"
  amount         = var.budget_amount
  reset_period   = "MONTHLY"
  target_type    = "COMPARTMENT"
  targets        = [oci_identity_compartment.lz.id]
  freeform_tags  = local.tags
}

resource "oci_budget_alert_rule" "lz" {
  count          = var.budget_alert_email == "" ? 0 : 1
  budget_id      = oci_budget_budget.lz.id
  display_name   = "${var.prefix}-80pct"
  threshold      = 80
  threshold_type = "PERCENTAGE"
  type           = "ACTUAL"
  recipients     = var.budget_alert_email
  message        = "${var.prefix} landing zone has used 80% of its monthly budget"
}

# ---------------------------------------------------------------- outputs
output "compartments" {
  value = merge({ lz = oci_identity_compartment.lz.id }, { for k, v in oci_identity_compartment.child : k => v.id })
}
output "vcn_id" { value = oci_core_vcn.lz.id }
output "subnets" { value = { for k, v in oci_core_subnet.lz : k => v.id } }
output "nsgs" { value = { for k, v in oci_core_network_security_group.nsg : k => v.id } }
output "bastion_id" { value = oci_bastion_bastion.lz.id }
output "buckets" { value = [for b in oci_objectstorage_bucket.b : b.name] }
output "tde_key_id" { value = var.create_vault ? oci_kms_key.tde[0].id : "" }
