resource "null_resource" "update_ssh_keys" {
  depends_on = [module.gu_key_credentials_consul,
    module.gu_key_credentials_bastion,
    module.gu_key_credentials_master,
    module.gu_key_credentials_webserver]
  provisioner "local-exec" {
    command = "cp ${path.module}/Key*.pem ~/.ssh/SSH_KEYS_FOR_Amazon/ -f"
  }
  provisioner "local-exec" {
    command = "chmod 400 ~/.ssh/SSH_KEYS_FOR_Amazon/*.pem"
  }
}
