resource "aws_security_group" "docker_sg" {
  name        = "docker_sg"
  description = "Security group for Docker EE manager nodes"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.sship}"]
  }

  ingress {
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    # cidr_blocks = "${var.allowed_ingress_cidrs}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2376
    to_port     = 2376
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 6444
    to_port     = 6444
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 9099
    to_port     = 9099
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 12376
    to_port     = 12376
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 12378
    to_port     = 12386
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 12388
    to_port     = 12388
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "docker_sg_id" {
  value = "${aws_security_group.docker_sg.id}"
}

resource "aws_security_group" "docker_worker_sg" {
  name        = "docker_worker_sg"
  description = "Security group for Docker EE worker nodes"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.sship}"]
  }

  ingress {
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 6444
    to_port     = 6444
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 9099
    to_port     = 9099
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 12376
    to_port     = 12376
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = 12378
    to_port     = 12378
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_ingress_cidrs}"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "docker_worker_sg_id" {
  value = "${aws_security_group.docker_worker_sg.id}"
}
