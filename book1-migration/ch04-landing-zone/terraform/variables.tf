# Filled in automatically by Resource Manager
variable "tenancy_ocid" {}
variable "region" {}

variable "prefix" {
  description = "Short name used in every resource name"
  default     = "meridian"
}

variable "environment" {
  description = "prod or nonprod"
  default     = "nonprod"
}

variable "owner" {
  description = "Owner tag value"
  default     = "dba-team"
}

variable "vcn_cidr" {
  default = "10.20.0.0/16"
}

variable "db_subnet_cidr" {
  default = "10.20.1.0/24"
}

variable "app_subnet_cidr" {
  default = "10.20.2.0/24"
}

variable "mgmt_subnet_cidr" {
  description = "Bastion and admin hosts"
  default     = "10.20.3.0/24"
}

variable "onprem_cidr" {
  description = "On-premises network that will reach OCI over VPN or FastConnect (via the DRG)"
  default     = "192.168.0.0/16"
}

variable "bastion_client_cidrs" {
  description = "Public IP ranges allowed to open Bastion sessions — set this to your office or VPN egress IP"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "create_vault" {
  description = "Create a Vault and a master encryption key for TDE (Vault deletion takes 7+ days)"
  type        = bool
  default     = true
}

variable "budget_amount" {
  description = "Monthly budget for the landing zone compartment, in your billing currency"
  default     = 10
}

variable "budget_alert_email" {
  description = "Email for the budget alert at 80% (leave empty for no alert)"
  default     = ""
}
