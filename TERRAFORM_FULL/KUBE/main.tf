/*
  Galit Udovik
  OpsSchool DevOps cource
  Main file
*/

module "reguest_data" {
  source           = "../../modules/data"
  region           = var.region
  application_name = var.application_name
  application_task = var.application_task
  created_by       = var.created_by
  vpc_name         = join("-", ["VPC", lower(var.application_name), var.application_task])
}



#########################################################################################
/* EKS environment */
module "kubernetes" {
  source               = "../../modules/kubernetes"
  vpc_id               = module.reguest_data.vpc_id
  application_task     = var.application_task
  application_name     = var.application_name
  created_by           = var.created_by
  cluster_name         = "kandula-mid-kube"
  kube_node_sec_groups = concat(module.reguest_data.kube_security_group_ids, module.reguest_data.sec_grp_consul_ids)
  kube_pub_subnets_ids = module.reguest_data.pub_subnets_ids
  kube_pvt_subnets_ids = module.reguest_data.workers_pvt_subnets_ids
  kube_additional_role_names = ["JenkinsSrv_Describe", "JenkinsAgent_Describe"]
 }
