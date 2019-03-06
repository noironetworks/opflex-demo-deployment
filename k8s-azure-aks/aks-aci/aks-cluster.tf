#
# AKS Cluster Resources
#  * ARM resource group
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

locals {
  screen = <<CONFIGURE

Run the following commands to configure kubernetes client:
$ source .aksrc
Test configuration using kubectl
$ kubectl get nodes,pods,svc --all-namespaces -o wide

To open ssh to nodes, first create a pod and install ssh client
kubectl run -it --rm aks-ssh --image=debian
apt-get update && apt-get install openssh-client -y

On another terminal
source .aksrc
kubectl get pods
kubectl cp aks-aci/.ssh/id_rsa <podname>:/id_rsa

On pod
chmod 0600 id_rsa
echo "    ServerAliveInterval 100" >> /etc/ssh/ssh_config

Now SSH into the nodes
kubectl exec -it <podname>  -- /bin/bash
CONFIGURE
}

# create a random string
resource "random_string" "suffix" {
  length = 8
  upper = false
  special = false
}

resource "azurerm_resource_group" "my-rg" {
  name = "${var.name_prefix}-rg-${random_string.suffix.result}"
  location = "${var.azurerm_location}"
}

# private key for the k8s cluster
resource "tls_private_key" "key" {
  algorithm   = "RSA"
}

# save the private key
resource "null_resource" "save-key" {
  triggers {
    key = "${tls_private_key.key.private_key_pem}"
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.ssh
      echo "${tls_private_key.key.private_key_pem}" > ${path.module}/.ssh/id_rsa
      chmod 0600 ${path.module}/.ssh/id_rsa
EOF
  }
}

resource "azurerm_virtual_network" "my-vnet" {
 name                = "${var.name_prefix}-vnet-${random_string.suffix.result}"
 address_space       = ["${var.aks_virtual_network_address_space}"]
 location            = "${azurerm_resource_group.my-rg.location}"
 resource_group_name = "${azurerm_resource_group.my-rg.name}"
 tags {
    Environment = "Production"
 }

}

resource "azurerm_subnet" "my-node-snet" {
 name                 = "${var.name_prefix}-snet-${random_string.suffix.result}"
 resource_group_name  = "${azurerm_resource_group.my-rg.name}"
 virtual_network_name = "${azurerm_virtual_network.my-vnet.name}"
 address_prefix       = "${var.aks_virtual_network_node_cidr}"
}

# AKS cluster
resource "azurerm_kubernetes_cluster" "my-cluster" { 
  name                = "${var.name_prefix}-cluster-${random_string.suffix.result}"
  location            = "${azurerm_resource_group.my-rg.location}"
  resource_group_name = "${azurerm_resource_group.my-rg.name}"
  dns_prefix          = "${var.name_prefix}-${random_string.suffix.result}"

  linux_profile {
    admin_username = "${var.admin_username}"

    ssh_key {
      #key_data = "${trimspace(tls_private_key.key.public_key_openssh)} ${var.admin_username}@cisco.com"
      key_data = "${trimspace(tls_private_key.key.public_key_openssh)} ${var.admin_username}@cisco.com"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_count}"
    vm_size         = "${var.instance_type}"
    os_type         = "${var.instance_ostype}"
    os_disk_size_gb = "${var.instance_disksize}"
    vnet_subnet_id  = "${azurerm_subnet.my-node-snet.id}"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr = "${var.aks_virtual_network_service_cidr}"
    dns_service_ip = "${var.aks_dns_service_ip}"
    docker_bridge_cidr = "${var.aks_docker_bridge_cidr}"
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  tags {
    Environment = "Production"
  }
}

resource "local_file" "kube_config" {
  content = "${azurerm_kubernetes_cluster.my-cluster.kube_config_raw}"
  filename = "kubeconfig"
}

## Outputs ##

# Example attributes available for output
#output "id" {
#    value = "${azurerm_kubernetes_cluster.my-cluster.id}"
#}
#
#output "client_key" {
#  value = "${azurerm_kubernetes_cluster.my-cluster.kube_config.0.client_key}"
#}
#
#output "client_certificate" {
#  value = "${azurerm_kubernetes_cluster.my-cluster.kube_config.0.client_certificate}"
#}
#
#output "cluster_ca_certificate" {
#  value = "${azurerm_kubernetes_cluster.my-cluster.kube_config.0.cluster_ca_certificate}"
#}
#
#output "kube_config" {
#  value = "${azurerm_kubernetes_cluster.my-cluster.kube_config_raw}"
#}
#
#output "host" {
#  value = "${azurerm_kubernetes_cluster.my-cluster.kube_config.0.host}"
#}

output "configure" {
  value = "${local.screen}"
}
