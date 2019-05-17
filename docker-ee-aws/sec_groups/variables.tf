variable "sship" {
  default = "0.0.0.0/0"
}

variable "vpc_id" {}

variable "allowed_ingress_cidrs" {
  type = "list"
}
