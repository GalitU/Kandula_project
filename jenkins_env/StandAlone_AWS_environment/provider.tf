/*
  Galit Udovik

  OpsSchool DevOps cource
  Provider configuration
*/

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
