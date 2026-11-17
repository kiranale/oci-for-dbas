# Private-only network: no subnet allows public IPs; admins come in through the Bastion service.

data "oci_core_services" "osn" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

locals {
  net_cid = oci_identity_compartment.child["network"].id
  osn     = data.oci_core_services.osn.services[0]
}

resource "oci_core_vcn" "lz" {
  compartment_id = local.net_cid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${var.prefix}-vcn"
  dns_label      = substr(replace(var.prefix, "-", ""), 0, 15)
  freeform_tags  = local.tags
}

# Replace the default security list: by default it allows SSH from 0.0.0.0/0.
resource "oci_core_default_security_list" "lz" {
  manage_default_resource_id = oci_core_vcn.lz.default_security_list_id
  display_name               = "${var.prefix}-default-sl (egress only)"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    description = "Path MTU discovery"
    protocol    = "1"
    source      = "0.0.0.0/0"
    icmp_options {
      type = 3
      code = 4
    }
  }
  ingress_security_rules {
    description = "ICMP unreachable inside the VCN"
    protocol    = "1"
    source      = var.vcn_cidr
    icmp_options {
      type = 3
    }
  }
}

resource "oci_core_nat_gateway" "lz" {
  compartment_id = local.net_cid
  vcn_id         = oci_core_vcn.lz.id
  display_name   = "${var.prefix}-natgw"
  freeform_tags  = local.tags
}

resource "oci_core_service_gateway" "lz" {
  compartment_id = local.net_cid
  vcn_id         = oci_core_vcn.lz.id
  display_name   = "${var.prefix}-sgw"
  freeform_tags  = local.tags
  services {
    service_id = local.osn.id
  }
}

resource "oci_core_drg" "lz" {
  compartment_id = local.net_cid
  display_name   = "${var.prefix}-drg"
  freeform_tags  = local.tags
}

resource "oci_core_drg_attachment" "lz" {
  drg_id       = oci_core_drg.lz.id
  display_name = "${var.prefix}-drg-vcn"
  network_details {
    id   = oci_core_vcn.lz.id
    type = "VCN"
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = local.net_cid
  vcn_id         = oci_core_vcn.lz.id
  display_name   = "${var.prefix}-rt-private"
  freeform_tags  = local.tags

  route_rules {
    description       = "Internet egress for patches (outbound only)"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.lz.id
  }
  route_rules {
    description       = "Object Storage and OCI services without the internet"
    destination       = local.osn.cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.lz.id
  }
  route_rules {
    description       = "On-premises over VPN or FastConnect"
    destination       = var.onprem_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.lz.id
  }
  depends_on = [oci_core_drg_attachment.lz]
}

locals {
  subnets = {
    db   = var.db_subnet_cidr
    app  = var.app_subnet_cidr
    mgmt = var.mgmt_subnet_cidr
  }
}

resource "oci_core_subnet" "lz" {
  for_each                   = local.subnets
  compartment_id             = local.net_cid
  vcn_id                     = oci_core_vcn.lz.id
  cidr_block                 = each.value
  display_name               = "${var.prefix}-${each.key}-subnet"
  dns_label                  = each.key
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_vcn.lz.default_security_list_id]
  freeform_tags              = local.tags
}

# ---------------------------------------------------------------- NSGs
resource "oci_core_network_security_group" "nsg" {
  for_each       = toset(["db", "app"])
  compartment_id = local.net_cid
  vcn_id         = oci_core_vcn.lz.id
  display_name   = "${var.prefix}-nsg-${each.key}"
  freeform_tags  = local.tags
}

locals {
  # name => [nsg, source, source_type, port_min, port_max, description]
  nsg_rules = {
    db_listener_from_app = ["db", oci_core_network_security_group.nsg["app"].id, "NETWORK_SECURITY_GROUP", 1521, 1522, "SQL*Net from application NSG"]
    db_listener_onprem   = ["db", var.onprem_cidr, "CIDR_BLOCK", 1521, 1522, "SQL*Net from on-premises (migration traffic)"]
    db_tls_from_app      = ["db", oci_core_network_security_group.nsg["app"].id, "NETWORK_SECURITY_GROUP", 2484, 2484, "TCPS from application NSG"]
    db_ssh_from_mgmt     = ["db", var.mgmt_subnet_cidr, "CIDR_BLOCK", 22, 22, "SSH from Bastion / management subnet"]
    db_ons_from_app      = ["db", oci_core_network_security_group.nsg["app"].id, "NETWORK_SECURITY_GROUP", 6200, 6200, "ONS (FAN) from application NSG"]
    app_ssh_from_mgmt    = ["app", var.mgmt_subnet_cidr, "CIDR_BLOCK", 22, 22, "SSH from Bastion / management subnet"]
  }
}

resource "oci_core_network_security_group_security_rule" "ingress" {
  for_each                  = local.nsg_rules
  network_security_group_id = oci_core_network_security_group.nsg[each.value[0]].id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = each.value[1]
  source_type               = each.value[2]
  description               = each.value[5]
  tcp_options {
    destination_port_range {
      min = each.value[3]
      max = each.value[4]
    }
  }
}

resource "oci_core_network_security_group_security_rule" "egress" {
  for_each                  = oci_core_network_security_group.nsg
  network_security_group_id = each.value.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# ---------------------------------------------------------------- Bastion
resource "oci_bastion_bastion" "lz" {
  bastion_type                 = "STANDARD"
  compartment_id               = local.net_cid
  target_subnet_id             = oci_core_subnet.lz["mgmt"].id
  name                         = local.bastion_name
  client_cidr_block_allow_list = var.bastion_client_cidrs
  max_session_ttl_in_seconds   = 10800
  freeform_tags                = local.tags
}
