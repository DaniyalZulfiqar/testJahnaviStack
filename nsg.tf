resource "oci_core_network_security_group" "simple_nsg" {
  count = local.create_nsg ? 1 : 0

  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = local.use_existing_network ? var.existing_vcn_id : oci_core_vcn.simple.0.id

  #Optional
  display_name = "${var.service_name}-nsg"

  freeform_tags = var.defined_tag.freeformTags
  defined_tags  = var.defined_tag.definedTags
}

# Allow Egress traffic to all networks
resource "oci_core_network_security_group_security_rule" "simple_rule_egress" {
  count = local.create_nsg ? 1 : 0

  network_security_group_id = oci_core_network_security_group.simple_nsg.0.id

  direction   = "EGRESS"
  protocol    = "all"
  destination = "0.0.0.0/0"

}

# Allow SSH (TCP port 22) Ingress traffic from any network
resource "oci_core_network_security_group_security_rule" "simple_rule_ssh_ingress" {
  count = local.create_nsg ? 1 : 0

  network_security_group_id = oci_core_network_security_group.simple_nsg.0.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = "0.0.0.0/0"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

# Allow HTTPS (TCP port 4040) Ingress traffic from any network
resource "oci_core_network_security_group_security_rule" "simple_rule_https_ingress" {
  count = local.create_nsg ? 1 : 0

  network_security_group_id = oci_core_network_security_group.simple_nsg.0.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = "0.0.0.0/0"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.console_ssl_port
      max = var.console_ssl_port
    }
  }
}

# Allow HTTP (TCP port 8080) Ingress traffic from any network
resource "oci_core_network_security_group_security_rule" "simple_rule_http_ingress" {
  count = local.create_nsg && !var.https_only ? 1 : 0

  network_security_group_id = oci_core_network_security_group.simple_nsg.0.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = "0.0.0.0/0"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = var.console_port
      max = var.console_port
    }
  }
}

# Allow ANY Ingress traffic from within vcn
resource "oci_core_network_security_group_security_rule" "simple_rule_all_simple_vcn_ingress" {
  count = local.create_nsg ? 1 : 0
  
  network_security_group_id = oci_core_network_security_group.simple_nsg.0.id
  protocol                  = "all"
  direction                 = "INGRESS"
  source                    = var.vcn_cidr
  stateless                 = false
}
