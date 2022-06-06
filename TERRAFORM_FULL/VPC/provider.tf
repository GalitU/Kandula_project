/*
  Galit Udovik

  OpsSchool DevOps cource
  Provider configuration
*/

terraform {
  required_version = "1.2.1"

  required_providers {
    aws        = "4.12.1"
    kubernetes = "2.11.0"
    local      = "2.2.2"
    null       = "~> 3.1.0"
    template   = "~> 2.2.0"
    random = "~> 3.1.0"

  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      App_name  = var.application_name
      Task      = var.application_task
      Owner     = var.application_owner
      CreatedBy = var.created_by
    }
  }
}
