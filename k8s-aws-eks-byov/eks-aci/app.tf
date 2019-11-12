#
# guestbook application deployment on aci eks cluster
#

# download guestbook deployment file
resource "null_resource" "download_guestbook_deployment" {
  provisioner "local-exec" {
    command = "curl -o guestbook.yaml ${var.guestbook_deployment_file}"
  }

  depends_on = [
    "aws_eks_cluster.my-cluster",
  ]
}

# replace service node port in the guestbook deployment file
resource "null_resource" "edit_guestbook_deployment_np" {
  provisioner "local-exec" {
     command = "sed -i -e 's/nodePort: 31313/nodePort: ${var.nodeport}/g' guestbook.yaml"
  }

  depends_on = [
    "null_resource.download_guestbook_deployment",
  ]
}

# apply guestbook deployment file
resource "null_resource" "apply_guestbook_deployment" {
  provisioner "local-exec" {
    command = "export PATH=$PWD/bin:$PATH && kubectl --kubeconfig=kubeconfig apply -f guestbook.yaml"
  }

  depends_on = [
    "null_resource.edit_guestbook_deployment_np",
    "null_resource.apply_aci_deployment",
  ]
}
