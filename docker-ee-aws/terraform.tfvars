# AWS region
aws_region = "us-east-1"

# AWS availability zone
aws_availability_zone = "us-east-1b"

# AWS VPC cidr. Terraform will use the cidr to launch VPC
vpc_cidr = "172.0.0.0/16"

# Subnet cidrs
cidrs = {
    public1 = "172.0.1.0/24"
}

# External network from which ssh would be allowed
sship = "0.0.0.0/0"

# Instance type for Manager and Worker nodes
aws_instance_type = "m5a.4xlarge"

# AWS Key-Pair to ssh instance. Terraform will use this key-pair to launch
# instance
aws_instance_key_name = ""

# AMI ID for Ubuntu 16.04
# aws_ami = "ami-0c55b159cbfafe1f0"
aws_ami = "ami-0a313d6098716f372"

# Absolute path of AWS key-pair on workstation
aws_key_location = ""

# HTTP/HTTPS URL of CNI deployment file
cni_url = ""

# Docker EE URL from docker subscription
docker_ee_url = ""

# Docker EE version from docker subscription
docker_ee_version = ""
