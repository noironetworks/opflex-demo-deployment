#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "cluster-iam-role" {
  name = "${var.name_prefix}-cluster-iam-role-${random_string.suffix.result}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "my-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.cluster-iam-role.name}"
}

resource "aws_iam_role_policy_attachment" "my-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.cluster-iam-role.name}"
}

resource "aws_security_group" "cluster-sg" {
  name        = "${var.name_prefix}-cluster-sg-${random_string.suffix.result}"
  description = "Security group for cluster communication with worker nodes"
  #vpc_id      = "${aws_vpc.vpc1.id}"
  vpc_id      = "${data.aws_vpc.vpc1.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name_prefix}-tag-${random_string.suffix.result}"
  }
}

resource "aws_iam_role" "node-iam-role" {
  name = "${var.name_prefix}-node-iam-role-${random_string.suffix.result}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_security_group" "node-sg" {
  name        = "${var.name_prefix}-node-sg-${random_string.suffix.result}"
  description = "Security group for all nodes in the cluster"
  #vpc_id      = "${aws_vpc.vpc1.id}"
  vpc_id      = "${data.aws_vpc.vpc1.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "${var.name_prefix}-tag-${random_string.suffix.result}",
     "kubernetes.io/cluster/${var.name_prefix}-cluster-${random_string.suffix.result}", "owned",
     "Demo", "eks",
    )
  }"
}

resource "aws_security_group_rule" "my-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster-sg.id}"
  source_security_group_id = "${aws_security_group.node-sg.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "my-cluster-ingress-workstation-https" {
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.cluster-sg.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "my-cluster" {
  name     = "${var.name_prefix}-cluster-${random_string.suffix.result}"
  role_arn = "${aws_iam_role.cluster-iam-role.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.cluster-sg.id}"]
    subnet_ids         = ["${var.aws_capic_subnet_id1}", "${var.aws_capic_subnet_id2}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.my-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.my-cluster-AmazonEKSServicePolicy",
  ]
}
