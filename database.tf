# creates an ADW database
## ADW Instance
resource "oci_database_autonomous_database" "autonomous_database" {
  count                    = local.adb_strategy == "NEW_ADB" ? 1 : 0

  admin_password           = random_string.autonomous_database_admin_password.result
  compartment_id           = var.adb_compartment_ocid
  #cpu_core_count           = local.adb_cpu_core_count
  data_storage_size_in_tbs = local.adb_data_storage_size_in_tbs
  db_name                  = "${var.adb_name}${random_string.deploy_id.result}"
  db_version               = local.adb_version
  db_workload              = local.adb_workload
  display_name             = "${var.adb_name}-${random_string.deploy_id.result}"
  license_model            = local.adb_license_model
  is_free_tier             = local.is_free_adb
  is_auto_scaling_enabled  = local.adb_enable_auto_scale
  is_auto_scaling_for_storage_enabled = local.adb_enable_storage_auto_scale
  compute_model = "ECPU"
  compute_count = local.adb_cpu_core_count

  freeform_tags = var.defined_tag.freeformTags
  defined_tags  = var.defined_tag.definedTags
}
