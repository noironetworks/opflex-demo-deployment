#
# Configs and output for ACI CNI
#

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.node-iam-role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.my-cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.my-cluster.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.name_prefix}-cluster-${random_string.suffix.result}"
KUBECONFIG

  aciconfig = <<ACI

source .eksrc
kubectl get pods --all-namespaces

Guest Book URL:
http://${aws_lb.elb.dns_name}

ACI

}

output "aciconfig" {
  value = "${local.aciconfig}"
}

resource "local_file" "config_map" {
  content = "${local.config_map_aws_auth}"
  filename = "config_map_aws_auth.yaml"
}

resource "local_file" "kube_config" {
  content = "${local.kubeconfig}"
  filename = "kubeconfig"
}

# delete aws-node daemonset
resource "null_resource" "delete_daemonset" {
  provisioner "local-exec" {
    command = "export PATH=$PWD/bin:$PATH && kubectl --kubeconfig=kubeconfig delete daemonset aws-node -n kube-system"
    on_failure = "continue"
  }

  depends_on = [
    "aws_eks_cluster.my-cluster",
    #"null_resource.add_bin_to_path",
    "local_file.kube_config",
  ]
}

# apply config map
resource "null_resource" "apply_config_map" {
  provisioner "local-exec" {
    command = "export PATH=$PWD/bin:$PATH && kubectl --kubeconfig=kubeconfig apply -f config_map_aws_auth.yaml"
  }

  depends_on = [
    "local_file.config_map",
    "null_resource.delete_daemonset",
  ]
}

# download aci deployment file
resource "null_resource" "download_aci_deployment" {
  provisioner "local-exec" {
    command = "curl -o aci_deployment.yaml ${var.aci_deployment_file}"
  }

  depends_on = [
    "aws_eks_cluster.my-cluster",
  ]
}

# replace EP registry IP in the aci deployment file 10.96.0.2 to 172.20.0.2
resource "null_resource" "edit_aci_deployment_epreg" {
  provisioner "local-exec" {
     command = "sed -i -e 's/10.96.0.2/172.20.0.2/g' aci_deployment.yaml"
  }

  depends_on = [
    "null_resource.download_aci_deployment",
  ]
}

# apply aci deployment file
resource "null_resource" "apply_aci_deployment" {
  provisioner "local-exec" {
    command = "export PATH=$PWD/bin:$PATH && kubectl --kubeconfig=kubeconfig apply -f aci_deployment.yaml"
  }

  depends_on = [
    "null_resource.apply_config_map",
    "null_resource.edit_aci_deployment_epreg",
    #"null_resource.edit_aci_deployment_eip",
  ]
}
