#
# Configs and output for ACI CNI
#

locals {
  node_init = <<NODEINIT

kind: DaemonSet
apiVersion: extensions/v1beta1
metadata:
  name: node-init
  labels:
    app: node-init
spec:
  template:
    metadata:
      labels:
        app: node-init
    spec:
      tolerations:
      - operator: Exists
      hostPID: true
      hostNetwork: true
      containers:
        - name: node-init
          image: gcr.io/google-containers/startup-script:v1
          imagePullPolicy: IfNotPresent
          securityContext:
            privileged: true
          env:
          - name: STARTUP_SCRIPT
            value: |
              #!/bin/bash

              set -o errexit
              set -o pipefail
              set -o nounset

              if [[ ! -f /tmp/node-init ]]; then

                echo "Changing kubelet configuration to use CNI pluging..."
                mkdir -p /home/kubernetes/bin
                sed -i "s:--network-plugin=kubenet:--network-plugin=cni\ --cni-bin-dir=/home/kubernetes/bin:g" /etc/default/kubelet
                echo "Restarting kubelet..."
                systemctl restart kubelet

                if ip link show cbr0; then
                  echo "Detected cbr0 bridge. Deleting interface..."
                  ip link del cbr0
                fi

                echo "Link information:"
                ip link

                echo "Routing table:"
                ip route

                echo "Node initialization complete"

                touch /tmp/node-init
              fi
NODEINIT

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

resource "local_file" "node_init" {
  content = "${local.node_init}"
  filename = "node_init.yaml"
}

# apply node_init yaml -> changes from kubenet to CNI, restarts kubelet and then apply aci_deployment.yaml
resource "null_resource" "node_init_and_apply" {
  #apply
  provisioner "local-exec" {
    command = "export PATH=$PWD/bin:$PATH && kubectl --kubeconfig=kubeconfig apply -f ${local_file.node_init.filename} && sleep 60"
  }
  #delete
  provisioner "local-exec" {
    command = "export PATH=$PWD/bin:$PATH && kubectl --kubeconfig=kubeconfig delete -f ${local_file.node_init.filename} && sleep 60"
    on_failure = "continue"
  }

  #apply aci deployment
  provisioner "local-exec" {
    command = "export PATH=$PWD/bin:$PATH && kubectl --kubeconfig=kubeconfig apply -f aci_deployment.yaml && sleep 60"
  }

  #restart all pods
  provisioner "local-exec" {
    command = "export PATH=$PWD/bin:$PATH && kubectl --kubeconfig=kubeconfig delete pods -n kube-system $(kubectl --kubeconfig=kubeconfig get pods -n kube-system -o custom-columns=NAME:.metadata.name,HOSTNETWORK:.spec.hostNetwork --no-headers=true | grep '<none>' | awk '{ print $1 }')"
  }

  depends_on = [
    "google_container_cluster.gke-cluster",
    "local_file.node_init",
    "null_resource.create_aci_deployment",
    "null_resource.create_kubeconfig",
  ]
}

resource "local_file" "acc_input_file" {
  content = "${local.accinput}"
  filename = "aci-containers-config.yaml"
}

# create aci deployment file
resource "null_resource" "create_aci_deployment" {
  provisioner "local-exec" {
     #command = "./pvenv/bin/acc-provision -c aci-containers-config.yaml -o aci_deployment.yaml -f k8s-localhost"
     command = "curl -o aci_deployment.yaml ${var.aci_deployment_file}"
  }

  depends_on = [
    "local_file.acc_input_file",
  ]
}
