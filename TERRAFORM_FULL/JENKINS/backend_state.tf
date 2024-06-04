/*
  Galit Udovik

  OpsSchool DevOps cource
  Move current state to cloud
*/
terraform {
  backend "s3" {
    bucket = "s3-fprj-kandula-bucket"
    key    = "jenkins/terraform.tfstate"
    region = "eu-central-1"
  }
}
