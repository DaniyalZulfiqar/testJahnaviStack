provider "oci" {
  region           = var.region
}

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_regions" "home-region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenancy.home_region_key]
  }
}

provider "oci" {
  alias            = "home"
  region           = data.oci_identity_regions.home-region.regions[0]["name"]
}