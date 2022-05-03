output "pub_subnets" {
  value = aws_subnet.pub_subnet
}

output "pvt_subnets" {
  value = aws_subnet.pvt_subnet
}

output "sec_grp_http" {
  value = aws_security_group.sec_grp_http
}

output "sec_grp_https" {
  value = aws_security_group.sec_grp_https
}

output "jenkins_sec_grp_http" {
  value = aws_security_group.jenkins_sec_grp_http
}

output "sec_grp_ssh" {
  value = aws_security_group.sec_grp_ssh
}
output "sec_grp_consul" {
  value = aws_security_group.consul_sg
}
#### output "bastion_sec_grp_ssh" {
####   value = aws_security_group.bastion_sec_grp_ssh
#### }
#### 
output "vpc_id" {
  value = aws_vpc.vpc.id
}
