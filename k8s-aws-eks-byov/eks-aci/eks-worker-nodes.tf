#
# EKS Worker Nodes Resources
#  * EC2 Security Group to allow networking traffic
#  * Data source to fetch latest EKS worker AMI
#  * AutoScaling Launch Configuration to configure worker instances
#  * AutoScaling Group to launch worker instances
#


resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.node-iam-role.name}"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.node-iam-role.name}"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.node-iam-role.name}"
}

#FIXME

resource "aws_iam_instance_profile" "node-iam-instance-profile" {
  name = "${var.name_prefix}-node-instance-profile-${random_string.suffix.result}"
  role = "${aws_iam_role.node-iam-role.name}"

  # create a dependency here so that we can execute kubectl commands
  depends_on = [
    "null_resource.delete_daemonset",
  ]

}

resource "aws_security_group_rule" "my-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.node-sg.id}"
  source_security_group_id = "${aws_security_group.node-sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "my-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.node-sg.id}"
  source_security_group_id = "${aws_security_group.cluster-sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "my-node-ingress-ssh" {
  description              = "SSH for nodes"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.node-sg.id}"
  cidr_blocks              = ["0.0.0.0/0"]
  to_port                  = 22
  type                     = "ingress"
}

resource "aws_security_group_rule" "my-node-ingress-lbhealth" {
  description              = "Health check for LB"
  from_port                = "${var.health_port}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.node-sg.id}"
  #cidr_blocks              = ["${aws_vpc.vpc1.cidr_block}"]
  cidr_blocks              = ["${data.aws_vpc.vpc1.cidr_block}"]
  #source_security_group_id = "${aws_security_group.node-sg.id}"
  to_port                  = "${var.health_port}"
  type                     = "ingress"
}

resource "aws_security_group_rule" "my-node-ingress-fe" {
  description              = "LB redirected traffic to front end"
  from_port                = "${var.lb_listener_port}"
  protocol                 = "TCP"
  security_group_id        = "${aws_security_group.node-sg.id}"
  cidr_blocks              = ["0.0.0.0/0"]
  #to_port                  = "${var.lb_listener_port}"
  to_port                  = "${var.nodeport}"
  type                     = "ingress"
}

#FIXME

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    #values = ["amazon-eks-node-v*"]
    values = ["${var.eks_worker_ami}"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# Encode bootstrap information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  my-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.my-cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.my-cluster.certificate_authority.0.data}' '${var.name_prefix}-cluster-${random_string.suffix.result}'
python -m SimpleHTTPServer '${var.health_port}' &>/dev/null&
USERDATA
}

resource "aws_launch_configuration" "worker-alc" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.node-iam-instance-profile.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.instance_type}"
  name_prefix                 = "${var.name_prefix}"
  security_groups             = ["${aws_security_group.node-sg.id}"]
  user_data_base64            = "${base64encode(local.my-node-userdata)}"
  key_name                    = "${aws_key_pair.deployer.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker-asg" {
  desired_capacity     = "${var.asg_capacity}"
  launch_configuration = "${aws_launch_configuration.worker-alc.id}"
  max_size             = "${var.asg_max_size}"
  min_size             = 1
  name                 = "${var.name_prefix}-asg-${random_string.suffix.result}"
  # use only the first subnet
  #vpc_zone_identifier  = ["${data.aws_subnet_ids.capic_subnet_ids.0.id}"]
  vpc_zone_identifier  = ["${aws_subnet.subnet1.0.id}"]

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-worker-${random_string.suffix.result}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.name_prefix}-cluster-${random_string.suffix.result}"
    value               = "owned"
    propagate_at_launch = true
  }
}

