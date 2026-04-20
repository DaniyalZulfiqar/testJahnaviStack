locals {
  vcn_raw   = lower("${var.service_name}${var.vcn_name}")
  subnet_raw = lower("${var.service_name}${var.subnet_name}")
  # allow only a-z0-9
  vcn_alnum    = replace(local.vcn_raw, "/[^a-z0-9]/", "")
  subnet_alnum = replace(local.subnet_raw, "/[^a-z0-9]/", "")
  # must start with a letter
  vcn_start    = can(regex("^[a-z]", local.vcn_alnum)) ? local.vcn_alnum : "a${local.vcn_alnum}"
  subnet_start = can(regex("^[a-z]", local.subnet_alnum)) ? local.subnet_alnum : "a${local.subnet_alnum}"

  vcn_dns_label    = substr(local.vcn_start, 0, 15)
  subnet_dns_label = substr(local.subnet_start, 0, 15)

  // If ends up empty after cleaning, set a default
  vcn_label = length(local.vcn_dns_label) > 0 ? local.vcn_dns_label : "sgtechvcn"
  subnet_label = length(local.subnet_dns_label) > 0 ? local.subnet_dns_label : "sgtechnet"
}

resource "oci_core_vcn" "simple" {
  count          = local.use_existing_network ? 0 : 1
  cidr_block     = var.vcn_cidr
  dns_label      = local.vcn_label
  compartment_id = var.network_compartment_id
  display_name   = local.vcn_raw

  freeform_tags = var.defined_tag.freeformTags
  defined_tags  = var.defined_tag.definedTags
}

#IGW
resource "oci_core_internet_gateway" "simple_internet_gateway" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_id
  vcn_id         = oci_core_vcn.simple[count.index].id
  enabled        = "true"
  display_name   = "${var.service_name}igw"

  freeform_tags = var.defined_tag.freeformTags
  defined_tags  = var.defined_tag.definedTags
}

#DHCP options
resource "oci_core_dhcp_options" "simple_dhcp" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_id
  vcn_id         = oci_core_vcn.simple[count.index].id
  display_name   = "${var.service_name}dhcp"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  # Ensure short-name resolution works for OCI private DNS hostnames
  options {
    type                = "SearchDomain"
    search_domain_names = [
      "${local.subnet_label}.${local.vcn_label}.oraclevcn.com"
      # optionally also add "${local.vcn_label}.oraclevcn.com"
    ]
  }
}

#simple subnet
resource "oci_core_subnet" "simple_subnet" {
  count                      = local.use_existing_network ? 0 : 1
  cidr_block                 = var.subnet_cidr
  compartment_id             = var.network_compartment_id
  vcn_id                     = oci_core_vcn.simple[count.index].id
  display_name               = local.subnet_raw
  dns_label                  = local.subnet_label
  prohibit_public_ip_on_vnic = ! local.is_public_subnet
  dhcp_options_id = oci_core_dhcp_options.simple_dhcp[count.index].id

  freeform_tags = var.defined_tag.freeformTags
  defined_tags  = var.defined_tag.definedTags
}

resource "oci_core_route_table" "simple_route_table" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_id
  vcn_id         = oci_core_vcn.simple[count.index].id
  display_name   = "${var.service_name}-${var.subnet_name}-rt"

  route_rules {
    network_entity_id = oci_core_internet_gateway.simple_internet_gateway[count.index].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  freeform_tags = var.defined_tag.freeformTags
  defined_tags  = var.defined_tag.definedTags
}

resource "oci_core_route_table_attachment" "route_table_attachment" {
  count          = local.use_existing_network ? 0 : 1
  subnet_id      = oci_core_subnet.simple_subnet[count.index].id
  route_table_id = oci_core_route_table.simple_route_table[count.index].id
}
