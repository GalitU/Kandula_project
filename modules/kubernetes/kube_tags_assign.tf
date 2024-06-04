
resource "aws_ec2_tag" "ingress_tag_pub_subnet_kube" {
  count       = length(var.kube_pub_subnets_ids)
  resource_id = var.kube_pub_subnets_ids[count.index]
  key         = "kubernetes.io/cluster/${local.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "ingress_tag_pub_subnet_elb" {
  count       = length(var.kube_pub_subnets_ids)
  resource_id = var.kube_pub_subnets_ids[count.index]
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "ingress_tag_pvt_subnet_kube" {
  count       = length(var.kube_pvt_subnets_ids)
  resource_id = var.kube_pvt_subnets_ids[count.index]
  key         = "kubernetes.io/cluster/${local.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "ingress_tag_pvt_subnet_elb" {
  count       = length(var.kube_pvt_subnets_ids)
  resource_id = var.kube_pvt_subnets_ids[count.index]
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}
