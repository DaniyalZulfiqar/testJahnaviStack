/*
* Copyright (c) 2020, 2023, Oracle and/or its affiliates. 
*
* Main modules' outputs are defined here, currently ports are fixed, we can use custom values later on
*/

locals {
  instance_ip     = local.is_public_subnet ? oci_core_instance.simple-vm.public_ip : oci_core_instance.simple-vm.private_ip
  app_url         = format("https://%s:%s/spatialstudio", local.instance_ip, var.console_ssl_port)
  app_http_url    = var.https_only ? "disabled" : format("http://%s:%s/spatialstudio", local.instance_ip, var.console_port)
}

###
# compute.tf outputs
###

output "instance_id" {
  value = oci_core_instance.simple-vm.id
}

output "instance_name" {
  value = oci_core_instance.simple-vm.display_name
}

output "instance_public_ip" {
  value = oci_core_instance.simple-vm.public_ip
}

output "instance_private_ip" {
  value = oci_core_instance.simple-vm.private_ip
}

output "instance_https_url" {
  value = local.app_url
}

output "instance_http_url" {
  value = local.app_http_url
}

###
# network.tf outputs
###

output "vcn_id" {
  value = ! local.use_existing_network ? join("", oci_core_vcn.simple.*.id) : var.existing_vcn_id
}

output "subnet_id" {
  value = ! local.use_existing_network ? join("", oci_core_subnet.simple_subnet.*.id) : var.subnet_id
}

###
# database.tf outputs
###

output "adb_password" {
  value = local.adb_strategy == "NEW_ADB" ? random_string.autonomous_database_admin_password.result : ""
  sensitive = true
}

output "adb_id" {
  value = local.adb_strategy == "NEW_ADB" ? oci_database_autonomous_database.autonomous_database[0].id : local.adb_id
}

###
# Comments
###

output "certificates_note" {
  value = "To configure your HTTPS certificate, see https://www.eclipse.org/jetty/documentation/jetty-9/index.html#loading-keys-and-certificates."
}

output "comments" {
  value = "Please wait 2-3 minutes after the deployment job has succeded before launching Spatial Studio"
}

output "idcs" {
  value = "After deployment you may configure Spatial Studio to use IDCS as its authentication provider. Please see https://docs.oracle.com/en/database/oracle/spatial-studio/23.1/spstu/administering-spatial-studio.html#GUID-F4F828D8-CB70-43E6-92CB-AE4FBC10C479"
}

