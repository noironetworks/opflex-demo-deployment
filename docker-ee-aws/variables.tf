variable "aws_region" {}
variable "aws_availability_zone" {}

variable "vpc_cidr" {}

variable "cidrs" {
  type = "map"
}

variable "sship" {}
variable "aws_instance_type" {}
variable "aws_instance_key_name" {}
variable "aws_ami" {}
variable "aws_key_location" {}
variable "cni_url" {}

variable "docker_ee_url" {}
variable "docker_ee_version" {}
