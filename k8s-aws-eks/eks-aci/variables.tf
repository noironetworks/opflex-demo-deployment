# aws variables
/*
variable "aws_access_key" {
    description = "The access key for AWS."
    default  = ""
}

variable "aws_secret_key" {
    description = "The secret key for AWS."
    default  = ""
}
*/

variable "aws_region" {
    description = "The AWS region."
    default  = "us-east-2"
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

variable "instance_type" {
  default   = "t3.small"
  type    = "string"
}

variable "asg_capacity" {
  default   = 3
}

variable "asg_max_size" {
  default   = 3
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

variable "guestbook_deployment_file" {
  default   = "https://raw.githubusercontent.com/dshailen/misc/master/guestbook.yaml"
}
