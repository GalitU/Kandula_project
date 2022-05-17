/*
  Galit Udovik

  OpsSchool DevOps cource
  Move current state to cloud
*/

terraform {
  backend "s3" {
    bucket = "s3-mprj-kandula-bucket"
    key    = "keys/terraform.tfstate"
    region = "eu-central-1"
  }
}
