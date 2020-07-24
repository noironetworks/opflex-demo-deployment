#
# Configs and output for ACI CNI
#

# apply aci deployment file
resource "null_resource" "apply_aci_deployment" {
  provisioner "local-exec" {
    command = "export PATH=$PWD/bin:$PATH && kubectl --kubeconfig=kubeconfig apply -f akscni.yaml && sleep 20"
  }

  depends_on = [
    "azurerm_kubernetes_cluster.my-cluster",
  ]
}
