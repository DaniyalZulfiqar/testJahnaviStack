locals {
  compute_raw = lower("${var.service_name}${random_string.deploy_id.result}")
  compute_alnum = replace(local.compute_raw, "/[^a-z0-9]/", "")
  compute_start = can(regex("^[a-z]", local.compute_alnum)) ? local.compute_alnum : "a${local.compute_alnum}"
  compute_label = substr(local.compute_start, 0, 15)
}

resource "oci_core_instance" "simple-vm" {
  availability_domain = local.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = local.compute_raw
  shape               = local.instance_shape.instanceShape

  dynamic "shape_config" {
    for_each = local.is_flex_shape
      content {
        ocpus         = local.instance_shape.ocpus
        memory_in_gbs = local.instance_shape.memory
      }
  }

  create_vnic_details {
    subnet_id              = local.use_existing_network ? var.subnet_id : oci_core_subnet.simple_subnet[0].id
    display_name           = "primaryvnic"
    assign_public_ip       = local.is_public_subnet
    hostname_label         = local.compute_label
    skip_source_dest_check = false
    nsg_ids                = local.create_nsg ? [oci_core_network_security_group.simple_nsg.0.id] : []
    assign_private_dns_record = true
  }

  source_details {
    source_type = "image"
    #use a marketplace image or custom image:
    source_id   = local.compute_image_id
  }

  lifecycle {
    ignore_changes = [
      source_details[0].source_id
    ]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    #user_data           = base64encode(file("./scripts/bootstrap.sh"))
    user_data           = base64encode(file("${path.module}/scripts/bootstrap.yaml"))

    https_only = var.https_only
    server_ssl_port = var.console_ssl_port
    server_port = var.console_port
    use_secrets     = var.use_secrets
    admin_user = var.admin_user
    admin_pwd = local.admin_pwd
    #This random string will be used for the new database's admin and sgtech users
    dba_password=random_string.autonomous_database_admin_password.result

    is_public = local.is_public_subnet

    #required, to distinguish if DB is new or an existing one will be used, set this to false and pass an empty adb_id 
    #to skip database metadata repository configuration
    create_adb_user = local.adb_strategy == "NEW_ADB"
    #optional, if passed a datasource will be configured for studio
    adb_id = local.adb_strategy == "NEW_ADB" ? oci_database_autonomous_database.autonomous_database[0].id : ( local.adb_strategy == "USE_ADB" ? local.adb_id : "" )
    #optional, default is low
    adb_level = var.adb_level 
    #optional
    adb_wallet_path = "/u01/oracle/wallet"
    #required when using existing adb, optional for new one and will be defaulted to sgtech
    adb_user = var.adb_user
    #required when using existing adb, optional for new one and will be defaulted to admin's
    adb_user_pwd = local.adb_user_pwd 
    #required to set max/min connections for studio
    is_free_adb = local.is_free_adb

    adb_use_secrets = var.adb_use_secrets

    enable_idcs = false
    # idcs_host = var.idcs_host
    # idcs_client_id = var.idcs_client_id
    # idcs_client_tenant = var.idcs_client_tenant
    # idcs_client_secret = var.idcs_client_secret
    debug_enabled = true

  }

  freeform_tags = var.defined_tag.freeformTags
  defined_tags  = var.defined_tag.definedTags

  depends_on = [
    oci_identity_policy.spatial_policy
  ]
}
