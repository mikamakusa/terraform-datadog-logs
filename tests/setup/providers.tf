terraform {
  required_version = ">= 1.0.0" # Ensure that the Terraform version is 1.0.0 or higher

  required_providers {
    datadog = {
      source = "DataDog/datadog"
      version = "~>3.56.0"
    }
  }
}

provider "datadog" {}