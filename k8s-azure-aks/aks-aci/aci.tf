#
# Configs and output for ACI CNI
#

# download aci deployment file
resource "null_resource" "download_aci_deployment" {
  provisioner "local-exec" {
    command = "curl -o aci_deployment.yaml ${var.aci_deployment_file}"
  }

  depends_on = [
    "azurerm_kubernetes_cluster.my-cluster",
  ]
}

resource "null_resource" "edit_aci_deployment_epreg" {
  provisioner "local-exec" {
     command = "sed -i -e 's/10.96.0.2/10.0.0.2/g' aci_deployment.yaml"
  }

  depends_on = [
    "null_resource.download_aci_deployment",
  ]
}

resource "null_resource" "edit_aci_deployment_image" {
  provisioner "local-exec" {
     command = "sed -i -e 's/image: challa\\/aci-containers-host:final/image: jojimt\\/aci-containers-host:azure1/g' aci_deployment.yaml"
  }

  depends_on = [
    "null_resource.edit_aci_deployment_epreg",
  ]
}


# apply aci deployment file
resource "null_resource" "apply_aci_deployment" {
  provisioner "local-exec" {
    command = "export PATH=$PWD/bin:$PATH && kubectl --kubeconfig=kubeconfig apply -f aci_deployment.yaml && sleep 20"
  }

  depends_on = [
    "null_resource.edit_aci_deployment_epreg",
    "null_resource.edit_aci_deployment_image",
    "azurerm_kubernetes_cluster.my-cluster",
  ]
}
