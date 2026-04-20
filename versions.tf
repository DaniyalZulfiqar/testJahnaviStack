terraform {
  required_version = ">= 1.5.0"
  required_providers {
    # Recommendation from ORM / OCI provider teams
    oci = {
      version =">= 4.21.0"
    }
  }
}
