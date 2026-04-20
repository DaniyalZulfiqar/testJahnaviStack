locals {

  # Logic to use AD name provided by user input on ORM or to lookup for the AD name when running from CLI
  availability_domain = (var.availability_domain_name != "" ? var.availability_domain_name : data.oci_identity_availability_domain.ad.name)

  # local.use_existing_network referenced in network.tf
  use_existing_network = var.vcn_strategy == var.vcn_strategy_enum["USE_VCN"] ? true : false
  
  # local.is_public_subnet referenced in compute.tf
  is_public_subnet = (local.use_existing_network == false) || (var.subnet_strategy_existing_vcn == var.subnet_strategy_existing_vcn_enum["PUBLIC"]) ? true : false

  create_nsg = (var.create_nsg==true && local.is_public_subnet) ? true : false

  # Local to control subscription to Marketplace image.
  mp_subscription_enabled = var.use_marketplace_image ? 1 : 0

   # Logic to choose a custom image or a marketplace image.
  compute_image_id = var.instance_image_id
  image_version = var.mp_listing_resource_version

  instance_shape = var.instance_shape

  # local.is_flex_shape referenced in compute.tf
  is_flex_shape = contains(split(".",var.instance_shape.instanceShape), "Flex") ? [1] : []

  # Marketplace Image listing variables - required for subscription only
  listing_id               = var.mp_listing_id
  listing_resource_id      = local.compute_image_id
  listing_resource_version = local.image_version

  # Database logic
  adb_strategy = [for k,v in var.adb_strategy_enum : k if v == var.adb_strategy][0]
  # NEW_ADB | USE_ADB | SKIP

  deploy_adb = local.adb_strategy == "NEW_ADB" ? true : false

  adb_license = [for k,v in var.adb_license_model_enum : k if v == var.adb_license_model][0]

  adb_workload = [for k,v in var.adb_workload_enum : k if v == var.adb_workload][0]

  adb_id = local.adb_workload == "DW" ? var.adb_id_adw : var.adb_id_atp

  adb_version = local.adb_workload == "DW" ? var.adb_version_adw : var.adb_version_atp

  is_free_adb = var.adb_type

  adb_cpu_core_count            = local.is_free_adb ? 2 : var.adb_cpu_core_count
  adb_data_storage_size_in_tbs  = local.is_free_adb ? 1 : var.adb_data_storage_size_in_tbs
  adb_enable_auto_scale         = local.is_free_adb ? false : var.adb_enable_auto_scale
  adb_license_model             = local.is_free_adb ? "LICENSE_INCLUDED" : local.adb_license
  adb_enable_storage_auto_scale = local.is_free_adb ? false : var.adb_enable_storage_auto_scale

  admin_pwd = var.use_secrets ? var.admin_pwd_ocid : var.admin_pwd
  adb_user_pwd = var.adb_use_secrets ?  var.adb_user_password_ocid : var.adb_user_pwd

  admin_pwd_secret_compartment = var.admin_pwd_secret_compartment == "" ? var.compartment_ocid : var.admin_pwd_secret_compartment
  adb_user_secret_compartment  = var.adb_user_secret_compartment == "" ? var.compartment_ocid : var.adb_user_secret_compartment
  #adb_user_secret_compartment  = local.adb_strategy == "SKIP" ? local.admin_pwd_secret_compartment : local.adb_user_secret_compartment

  create_dg = var.create_dg && (local.adb_strategy != "SKIP" || var.adb_use_secrets || var.use_secrets) ? true : false

}
