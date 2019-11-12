# gke variables
variable "gke_service_account_file" {
    description = "The GCP project service account credentials file."
    default  = "serviceaccount.json"
}

variable "gke_service_account_email" {
    description = "The GCP project service account email."
    default  = "noiro@noironetworks.com"
}

variable "gcp_project" {
    description = "The GCP project name."
    default  = ""
}

variable "gke_location" {
    description = "The GKE location for the cluster."
    default  = "us-west1-b"
}

variable "gke_network" {
    description = "The GKE networkfor the cluster."
    default  = "default"
}

variable "env_user" {
    description = "Local env user."
    default  = "ubuntu"
}

variable "name_prefix" {
  default = "demo"
  type    = "string"
}

variable "subnet_count" {
  default   = 3
}

variable "keyname" {
  default   = "noiro"
  type    = "string"
}

variable "public_key" {
  default   = ""
  type    = "string"
}

variable "gke_k8s_version" {
  default   = "1.12"
  type    = "string"
}

variable "instance_type" {
  default   = "n1-standard-1"
  type    = "string"
}

variable "gke_image_type" {
  default   = "UBUNTU"
  type    = "string"
}

variable "gke_testvm_image_type" {
  default   = "ubuntu-1804-lts"
  type    = "string"
}

variable "http_load_balancing" {
  default   = false
}

variable "horizontal_pod_autoscaling" {
  default   = true
}

variable "kubernetes_dashboard" {
  default   = true
}

variable "network_policy" {
  default     = false
}

variable "asg_capacity" {
  default   = 3
}

variable "asg_max_size" {
  default   = 3
}

## ACC
variable "acc_node_subnet" {
  default   = "1.100.202.1/24"
}

variable "acc_pod_subnet" {
  default   = "10.2.56.1/21"
}

variable "acc_extern_dynamic" {
  default   = "10.3.56.1/21"
}

variable "acc_extern_static" {
  default   = "10.4.56.1/21"
}

variable "acc_node_svc_subnet" {
  default   = "10.5.56.1/21"
}

variable "acc_kubeapi_vlan" {
  default   = 202
}

variable "acc_service_vlan" {
  default   = 1022
}

variable "acc_infra_vlan" {
  default   = 4093
}

variable "acc_opflex_server_port" {
  default   = 8009
}

variable "acc_ep_registry_service_IP" {
  default   = "172.20.0.2"
}

variable "acc_ep_registry_service_port" {
  default   = 14443
}

variable "acc_aci_containers_version" {
  default   = "latest"
}

variable "lb_type" {
  default   = "network"
}

variable "nodeport" {
  default   = 31313
}

variable "lb_listener_protocol" {
  default   = "TCP"
}

variable "lb_listener_port" {
  default   = 80
}

variable "lb_target_protocol" {
  default   = "TCP"
}

variable "lb_target_port" {
  default   = 31313
}

variable "health_protocol" {
  default   = "HTTP"
}

variable "health_port" {
  default   = 8000
}

variable "aci_deployment_file" {
  #default   = "https://raw.githubusercontent.com/noironetworks/vagrant-aci-containers/master/ubuntu-bionic/data/aci_deployment.yaml"
  default   = "https://raw.githubusercontent.com/dshailen/misc/master/aci_deployment_gke.yaml"
}

variable "busybox_deployment_file" {
  default   = "https://raw.githubusercontent.com/noironetworks/vagrant-aci-containers/master/ubuntu-bionic/data/bbox.yaml"
}

variable "guestbook_deployment_file" {
  default   = "https://raw.githubusercontent.com/dshailen/misc/master/guestbook.yaml"
}
