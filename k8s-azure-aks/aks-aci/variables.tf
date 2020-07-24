# azurerm aks variables

variable "client_id" {
    description = "The client id for creating Azure resources."
    default  = ""
}

variable "client_secret" {
    description = "The secret key for Azure RM."
    default  = ""
}

variable "azurerm_location" {
    description = "The Azure region."
    default  = "westus"
}

variable "name_prefix" {
  default = "demo"
  type    = "string"
}

variable "agent_count" {
  default   = 3
}

variable "admin_username" {
    default = "aks-user"
}

variable "admin_password" {
    default = "Ins3965!"
}

variable "keyname" {
  default   = "noiro"
  type    = "string"
}

variable "tags" {
    default  = "Production"
    type  = "string"
}

variable "instance_ostype" {
  default   = "Linux"
  type    = "string"
}

variable "instance_type" {
  #default   = "Standard_D2"
  default   = "Standard_A8m_v2"
  type    = "string"
}

variable "instance_disksize" {
  default   = 30
}

variable "asg_capacity" {
  default   = 3
}

variable "asg_max_size" {
  default   = 3
}

variable "aks_virtual_network_address_space" {
  default   = "10.0.0.0/8"
}

variable "aks_virtual_network_node_cidr" {
  default   = "10.240.0.0/16"
}

variable "aks_virtual_network_service_cidr" {
  default   = "10.0.0.0/16"
}

variable "aks_dns_service_ip" {
  default   = "10.0.0.10"
}

variable "aks_docker_bridge_cidr" {
  default   = "172.17.0.1/16"
}

variable "lb_type" {
  default   = "application"
}

variable "nodeport" {
  default   = 31313
}

variable "lb_listener_protocol" {
  default   = "HTTP"
}

variable "lb_listener_port" {
  default   = 80
}

variable "lb_target_protocol" {
  default   = "HTTP"
}

variable "lb_target_port" {
  default   = 80
}

variable "health_protocol" {
  default   = "HTTP"
}

variable "health_port" {
  default   = 8000
}

variable "aci_deployment_file" {
  default   = "https://raw.githubusercontent.com/noironetworks/vagrant-aci-containers/master/ubuntu-bionic/data/aci_deployment.yaml"
}

variable "busybox_deployment_file" {
  default   = "https://raw.githubusercontent.com/noironetworks/vagrant-aci-containers/master/ubuntu-bionic/data/bbox.yaml"
}

variable "guestbook_deployment_file" {
  default   = "https://raw.githubusercontent.com/dshailen/misc/master/guestbook.yaml"
}

variable "az_capic_subnet_id" {
  default   = ""
  type    = "string"
}
