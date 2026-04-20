/* 
* Copyright (c) 2020, 2025, Oracle and/or its affiliates. 
 * Variables file with defaults. These can be overridden from environment variables TF_VAR_<variable name>
 *
 * Following are generally configured in environment variables - please use env_vars_template to create env_vars and source it as:
 * source ./env_vars
 * before running terraform init
 */

/*
********************
* Instance Config
********************
*/

variable "service_name" {
  default = "sgtech"
}

variable "instance_shape" {
  type = map(any)
  default = {
    "instanceShape" = "VM.Standard.E4.Flex"
    "ocpus" = 1
    "memory" = 16
  }
  #Default in instance creation page is {"instanceShape"="VM.Standard.E4.Flex","ocpus"=1,"memory"=16}
}

variable "add_ssh" {
  default = true
}
// Note: This is the opc user's SSH public key text and not the key file path.
variable "ssh_public_key" { 
  default = ""
 }

variable "availability_domain_name" {}

variable "https_only" {
  default = true
}

variable "console_ssl_port" {
  default = "4040"
}

variable "console_port" {
  default = "8080"
}

variable "admin_user" {
  default = "admin"
}

variable "admin_pwd_secret_compartment" { 
  default = ""
}

variable "admin_pwd_ocid" { 
    default = ""
 }

variable "use_secrets" {
  default = false
}

variable "admin_pwd" {
  default = ""
}

/*
********************
* Network Config
********************
*/

variable "network_compartment_id" {}

variable "subnet_compartment_id" {
  default = ""
}

variable "vcn_strategy_enum" {
  type = map
  default = {
    CREATE_VCN = "Create New VCN"
    USE_VCN    = "Use Existing VCN"
  }
}

variable "vcn_strategy" {
  default = "Create New VCN"
}

variable "existing_vcn_id" {
  default = ""
}

variable "vcn_name" {
  default = "vcn"
}

variable "subnet_name" {
  default = "subnet"
}

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_id" {
  default = ""
}

variable "subnet_strategy_existing_vcn_enum" {
  type = map
  default = {
    PUBLIC  = "Use Existing Public Subnet"
    PRIVATE = "Use Existing Private Subnet"
  }
}

variable "subnet_strategy_existing_vcn" {
  default = "Use Existing Public Subnet"
}

variable "subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "create_nsg" {
  default = true
}

/*
********************
* ADB Config
********************
*/
variable "adb_strategy_enum" {
    type = map
    default = {
      NEW_ADB = "Create New Autonomous database"
      USE_ADB = "Use Existing Autonomous database"
      SKIP    = "Configure later"
    }
}

variable "adb_strategy" {
    default = "Configure later"
}

variable "adb_id_adw" {
    default = ""
}

variable "adb_id_atp" {
    default = ""
}

variable "adb_type" {
  default = false
}

variable "adb_workload_enum" {
  type = map
  default = {
    DW   = "Data Warehouse (Serverless Infrastructure)"
    OLTP = "Transaction Processing (Serverless Infrastructure)"
  }
}

variable "adb_workload" {
  default = "Data Warehouse (Serverless Infrastructure)"
}

variable "adb_user_secret_compartment" {
  default = ""
}

variable "adb_compartment_ocid" {
  default = ""
}

variable "adb_level" {
  default = "low"
}

variable "adb_user" {
  default = "studio_repo"
}

variable "adb_use_secrets" {
  default = false
}

variable "adb_user_pwd" {
    default = ""
}

variable "adb_user_password_ocid" { 
  default = ""
 }
   
variable "adb_name" {
  default = "adb"
}

variable "adb_version_adw" {
  default = "19c"
}

variable "adb_version_atp" {
  default = "19c"
}

variable "adb_license_model_enum" {
    type = map
    default = {
        LICENSE_INCLUDED       = "License Included"
        BRING_YOUR_OWN_LICENSE = "Bring Your Own License (BYOL)"
    }
}

variable "adb_license_model" {
  default = "License Included"
}
variable "adb_cpu_core_count" {
  default = 2
}
variable "adb_data_storage_size_in_tbs" {
  default = 1
}
variable "adb_enable_auto_scale" {
  default = true
}

variable "adb_enable_storage_auto_scale" {
  default = false
}

/*
*******************
* IAM Dynamic Group 
*******************
*/

variable "create_dg" {
  default = true
}

/*
********************
* IDCS Config
********************
*/
# variable "show_idcs_options" {
#     default = false
# }

# variable "idcs_host" {
#     default = "identity.oraclecloud.com"
# }

# variable "idcs_client_tenant" {
#     default = ""
# }

# variable "idcs_client_id" {
#     default = ""
# }

# variable "idcs_client_secret" {
#     default = ""
# }

/*
********************
* Tag Config
********************
*/

variable "show_tag_options" {
  default = true
}

variable  "defined_tag" {
  type = map(map(string))
  default = {
    "freeformTags" = {
      # "oci-marketplace" = "spatialstudio"
    }
    "definedTags" = {}
  }
}

/*
********************
* Hidden Variables
********************
*/
variable "tenancy_ocid" {}

variable "region" {}

variable "compartment_ocid" {}

variable "use_marketplace_image" {
  default = true
}

# Published Spatial Studio Image Listing OCID
variable "mp_listing_id" {
  default = "ocid1.appcataloglisting.oc1..aaaaaaaaxfsimxy72yxnm4zllryolsjyrgaczimlyyahbmryga3nyehxythq"
}

# Package version Reference
variable "mp_listing_resource_version" {
  default = "25.2.1.0"
}

# Use this variable along the use_marketplace_image to specify either the
# Image artifact ocid to use the latest official marketplace image or your custom image ocid
variable "instance_image_id" {
  default = "ocid1.image.oc1..aaaaaaaan3cw2ohxols2doccotc7ygoim2znye4brl4v27sqhrqcev2xsdwq"
}

