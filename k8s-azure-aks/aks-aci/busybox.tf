#
# Configs and output for ACI CNI
#

# download busybox deployment file
resource "null_resource" "download_busybox_deployment" {
  provisioner "local-exec" {
    command = "curl -o bbox.yaml ${var.busybox_deployment_file}"
  }

  depends_on = [
    "azurerm_kubernetes_cluster.my-cluster",
  ]
}

# apply busy deployment file
resource "null_resource" "apply_busybox_deployment" {
  provisioner "local-exec" {
    command = "export PATH=$PWD/bin:$PATH && kubectl --kubeconfig=kubeconfig apply -f bbox.yaml"
  }

  depends_on = [
    "null_resource.download_busybox_deployment",
    "null_resource.apply_aci_deployment",
  ]
}
