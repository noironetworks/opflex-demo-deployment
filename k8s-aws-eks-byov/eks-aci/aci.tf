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

ACI

  accinput = <<ACCINPUT

#
# Configuration for ACI Fabric
#
aci_config:
  system_id: "kube_${random_string.suffix.result}"                      # Every opflex cluster on the same fabric must have a distict ID
  apic_hosts:                           # List of APIC hosts to connect to for APIC API access
    - 127.0.0.1
  vmm_domain:                           # Kubernetes VMM domain configuration
    domain: kube
    controller: kube
  # The following resources must already exist on the APIC,
  # this is a reference to use them
  aep: dummy-value                        # The attachment profile for ports/VPCs connected to this cluster
  vrf:                                  # VRF used to create all subnets used by this Kubernetes cluster
    name: defaultVrf          # This should exist, the provisioning tool does not create it
    tenant: kube        # This can be tenant for this cluster (system-id) or common
  l3out:                                # L3out to use for this kubernetes cluster (in the VRF above)
    name: l3out-v1              # This is used to provision external service IPs/LB
    external_networks:
        - l3out_v1_net        # This should also exist, the provisioning tool does not create iti
  sync_login:
    username: kube
    certfile: user.crt
    keyfile: user.key
#
# Networks used by Kubernetes
#
net_config:
  node_subnet: "${var.acc_node_subnet}"              # Subnet to use for nodes, NU
  pod_subnet: "${var.acc_pod_subnet}" # Subnet to use for Kubernetes Pods
  extern_dynamic: "${var.acc_extern_dynamic}"       # Subnet to use for dynamically allocated external services, NU
  extern_static: "${var.acc_extern_static}"        # Subnet to use for statically allocated external services, NU
  node_svc_subnet: "${var.acc_node_svc_subnet}"          # Subnet to use for service graph
  kubeapi_vlan: ${var.acc_kubeapi_vlan}                    # The VLAN used by the internal physdom for nodes, NU
  service_vlan: ${var.acc_service_vlan}                    # The VLAN used for external LoadBalancer services
  infra_vlan: ${var.acc_infra_vlan}
  gbp_server_registry: "http://${var.acc_ep_registry_service_IP}:${var.acc_ep_registry_service_port}"
  opflex_server_port: ${var.acc_opflex_server_port}
  ep_registry_service_IP: "${var.acc_ep_registry_service_IP}"
  ep_registry_service_port: ${var.acc_ep_registry_service_port}
#
#
# Configuration for container registry
# Update if a custom container registry has been setup
#
registry:
  image_prefix: noirolabs
  aci_containers_controller_version: "${var.acc_aci_containers_version}"
  aci_containers_host_version: "${var.acc_aci_containers_version}"
  cnideploy_version: "${var.acc_aci_containers_version}"
  opflex_agent_version: "${var.acc_aci_containers_version}"
  opflex_server_version: "${var.acc_aci_containers_version}"
  openvswitch_version: "${var.acc_aci_containers_version}"
  gbp_version: "${var.acc_aci_containers_version}"
#
# Enable/disable logging for ACI components on kubernetes
#
logging:
  controller_log_level: debug
  hostagent_log_level: debug
  opflexagent_log_level: debug

ACCINPUT
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
    on_failure = "fail"
  }

  depends_on = [
    "aws_eks_cluster.my-cluster",
    "local_file.kube_config",
  ]
}

# apply config map
resource "null_resource" "apply_config_map" {
  provisioner "local-exec" {
    command = "sleep 60 && export PATH=$PWD/bin:$PATH && kubectl --kubeconfig=kubeconfig apply -f config_map_aws_auth.yaml"
  }

  depends_on = [
    "local_file.config_map",
    "null_resource.delete_daemonset",
  ]
}

resource "local_file" "acc_input_file" {
  content = "${local.accinput}"
  filename = "aci-containers-config.yaml"
}

# create aci deployment file
resource "null_resource" "create_aci_deployment" {
  provisioner "local-exec" {
     command = "./pvenv/bin/acc-provision -c aci-containers-config.yaml -o aci_deployment.yaml -f k8s-localhost"
  }

  depends_on = [
    "local_file.acc_input_file",
  ]
}

# apply aci deployment file
resource "null_resource" "apply_aci_deployment" {
  provisioner "local-exec" {
    command = "export PATH=$PWD/bin:$PATH && kubectl --kubeconfig=kubeconfig apply -f aci_deployment.yaml"
  }

  depends_on = [
    "null_resource.apply_config_map",
    "null_resource.create_aci_deployment",
  ]
}
