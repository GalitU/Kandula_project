##### Not used - will be self register by module
#####  resource "null_resource" "add_jenkins_slaves" {
#####    depends_on = [module.gu_jenkins_agent]
#####    provisioner "local-exec" {
#####      command = "python3 ${path.module}/add_jenkins_node.py"
#####    }
#####  }
