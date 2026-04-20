# Copyright 2020, Oracle Corporation and/or affiliates.  All rights reserved.
locals {
  # Group Rule to include all instances that are created in a specific compartment
  # https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm#Writing
  compartment = format("instance.compartment.id='%s'", var.compartment_ocid)
}

resource "oci_identity_dynamic_group" "spatial_instance_principal_group" {
  count = local.create_dg ? 1 : 0
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  description    = "dynamic group to allow access to resources"
  matching_rule  = "ALL { ${local.compartment} }"
  name           = "${var.service_name}-spatial-principal-group-${random_string.deploy_id.result}"

  lifecycle {
    ignore_changes = [matching_rule]
  }
}

locals {
  ss_policy_statement1 = local.create_dg ? "Allow dynamic-group ${oci_identity_dynamic_group.spatial_instance_principal_group.0.name} to use secret-family in compartment id ${local.admin_pwd_secret_compartment}" : ""
  ss_policy_statement2 = local.create_dg ? "Allow dynamic-group ${oci_identity_dynamic_group.spatial_instance_principal_group.0.name} to use keys in compartment id ${local.admin_pwd_secret_compartment}" : ""
  ss_policy_statement3 = "Allow service VaultSecret to use keys in compartment id ${local.admin_pwd_secret_compartment}" 
  ss_statements = var.use_secrets ? [local.ss_policy_statement1,local.ss_policy_statement2,local.ss_policy_statement3] : []

  adb_policy_statement = local.create_dg ? "Allow dynamic-group ${oci_identity_dynamic_group.spatial_instance_principal_group.0.name} to manage autonomous-database-family in compartment id ${var.adb_compartment_ocid}" : ""
  adb_statements = local.adb_strategy == "SKIP" ? [] : [local.adb_policy_statement] 
  
  adb_ss_policy_statement1 = local.create_dg ? "Allow dynamic-group ${oci_identity_dynamic_group.spatial_instance_principal_group.0.name} to use secret-family in compartment id ${local.adb_user_secret_compartment}" : ""
  adb_ss_policy_statement2 = local.create_dg ? "Allow dynamic-group ${oci_identity_dynamic_group.spatial_instance_principal_group.0.name} to use keys in compartment id ${local.adb_user_secret_compartment}" : ""
  adb_ss_policy_statement3 = "Allow service VaultSecret to use keys in compartment id ${local.adb_user_secret_compartment}" 
  adb_ss_statements = var.adb_use_secrets ? [local.adb_ss_policy_statement1,local.adb_ss_policy_statement2,local.adb_ss_policy_statement3] : []

  //Get a single list without empty lists, then clear out possible duplicates (eg. add_seclist, vcn_peering are true and both networks are in same compartment)
  statements = distinct(flatten([local.ss_statements,local.adb_statements,local.adb_ss_statements]))
}

resource "oci_identity_policy" "spatial_policy" {
  count = local.create_dg ? 1 : 0
  provider       = oci.home
  compartment_id = var.tenancy_ocid
  description    = "policy that allows instance principal access to the CLI api from the instance"
  name           = "${var.service_name}-policy-${random_string.deploy_id.result}"
  statements     = local.statements

  freeform_tags = var.defined_tag.freeformTags
  defined_tags  = var.defined_tag.definedTags
}

