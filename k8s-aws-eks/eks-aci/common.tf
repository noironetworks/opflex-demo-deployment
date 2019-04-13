resource "random_string" "suffix" {
  length = 8
  upper = false
  special = false
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.name_prefix}-key-${random_string.suffix.result}"
  public_key = "${var.public_key}"
}

# rename the ssh key files to match the keyname
resource "null_resource" "rename_sshkey_files" {
  provisioner "local-exec" {
     command = "mv local.pem ${var.name_prefix}-key-${random_string.suffix.result}.pem && mv local.pem.pub ${var.name_prefix}-key-${random_string.suffix.result}.pem.pub"
  }

  depends_on = [
    "aws_key_pair.deployer",
  ]
}
