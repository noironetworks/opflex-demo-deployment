provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "docker_vpc" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "DockerVPC"
  }

  enable_dns_hostnames = true
}

resource "aws_subnet" "docker_pub_sub1" {
  vpc_id                  = "${aws_vpc.docker_vpc.id}"
  cidr_block              = "${var.cidrs["public1"]}"
  map_public_ip_on_launch = true

  tags {
    Name = "Public-Sub-1"
  }

  availability_zone = "${var.aws_availability_zone}"
}

resource "aws_internet_gateway" "docker_gw" {
  vpc_id = "${aws_vpc.docker_vpc.id}"

  tags {
    Name = "Docker VPC GW"
  }
}

resource "aws_route_table" "docker_public_rt" {
  vpc_id = "${aws_vpc.docker_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.docker_gw.id}"
  }

  tags {
    Name = "DockerPublicRt"
  }
}

resource "aws_default_route_table" "docker_deault_rt" {
  default_route_table_id = "${aws_vpc.docker_vpc.default_route_table_id}"

  tags {
    Name = "DockerPrivateRt"
  }
}

resource "aws_route_table_association" "docker_publ1_rt_assoc" {
  subnet_id      = "${aws_subnet.docker_pub_sub1.id}"
  route_table_id = "${aws_route_table.docker_public_rt.id}"
}

resource "aws_instance" "docker_master1" {
  instance_type = "${var.aws_instance_type}"
  ami           = "${var.aws_ami}"

  tags {
    Name = "Docker-Master"
  }

  key_name               = "${var.aws_instance_key_name}"
  vpc_security_group_ids = ["${module.sec_groups.docker_sg_id}"]
  subnet_id              = "${aws_subnet.docker_pub_sub1.id}"
  availability_zone      = "${var.aws_availability_zone}"

  provisioner "file" {
    source      = "./scripts/install_docker.sh"
    destination = "/tmp/install_docker.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.aws_key_location}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_docker.sh",
      "/tmp/install_docker.sh ${var.docker_ee_url} ${var.docker_ee_version}",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.aws_key_location}")}"
    }
  }

  provisioner "file" {
    source      = "./scripts/install_ucp.sh"
    destination = "/tmp/install_ucp.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.aws_key_location}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_ucp.sh",
      "/tmp/install_ucp.sh ${aws_instance.docker_master1.private_ip} ${aws_instance.docker_master1.private_dns} ${aws_instance.docker_master1.public_dns} ${aws_instance.docker_master1.public_ip} ${var.cni_url}",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.aws_key_location}")}"
    }
  }
}

resource "aws_instance" "docker_worker1" {
  instance_type = "${var.aws_instance_type}"
  ami           = "${var.aws_ami}"

  tags {
    Name = "Docker-Worker1"
  }

  key_name               = "${var.aws_instance_key_name}"
  vpc_security_group_ids = ["${module.sec_groups.docker_worker_sg_id}"]
  subnet_id              = "${aws_subnet.docker_pub_sub1.id}"
  availability_zone      = "${var.aws_availability_zone}"

  provisioner "file" {
    source      = "./scripts/install_docker.sh"
    destination = "/tmp/install_docker.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.aws_key_location}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_docker.sh",
      "/tmp/install_docker.sh ${var.docker_ee_url} ${var.docker_ee_version}",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.aws_key_location}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join --token ${data.external.swarm_tokens.result.worker_token} ${aws_instance.docker_master1.private_ip}:2377",
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${var.aws_key_location}")}"
  }
}

module "sec_groups" {
  source                = "./sec_groups"
  vpc_id                = "${aws_vpc.docker_vpc.id}"
  allowed_ingress_cidrs = ["${var.cidrs["public1"]}"]
}

data "external" "swarm_tokens" {
  program = ["bash", "./scripts/fetch_token.sh"]

  query = {
    key_pair  = "${var.aws_key_location}"
    public_ip = "${aws_instance.docker_master1.public_ip}"
  }

  depends_on = ["aws_instance.docker_master1"]
}
