# create ELB
resource "aws_lb" "elb" {
  name               = "${var.name_prefix}-elb-${random_string.suffix.result}"
  internal           = false
  load_balancer_type = "${var.lb_type}"
  subnets            = ["${aws_subnet.subnet1.*.id}"]
  # needed if eip has to be allocated
  #subnet_mapping {
  #  subnet_id     = "${aws_subnet.subnet1.0.id}"
  #  allocation_id = "${aws_eip.elb.id}"
  #}
  security_groups    = ["${aws_security_group.node-sg.id}"]
  enable_cross_zone_load_balancing = false

  depends_on = [
    "null_resource.apply_config_map",
  ]

}

resource "aws_lb_listener" "elb_listener" {
  load_balancer_arn = "${aws_lb.elb.arn}"
  protocol          = "${var.lb_listener_protocol}"
  port              = "${var.lb_listener_port}"

  default_action {
    target_group_arn = "${aws_lb_target_group.elb_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "elb_target_group" {
  name     = "${var.name_prefix}-elbtg-${random_string.suffix.result}"
  protocol = "${var.lb_target_protocol}"
  port     = "${var.lb_target_port}"
  vpc_id   = "${aws_vpc.vpc1.id}"

  # disable health check
  #health_check           = []
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
    protocol            = "${var.health_protocol}"
    port                = "${var.health_port}"
  }
}

data "aws_instances" "worker-nodes" {
  instance_tags = {
    Name = "${var.name_prefix}-worker-${random_string.suffix.result}"
  }
  instance_state_names = ["running", "pending"]
  depends_on = [
    "aws_eks_cluster.my-cluster",
    "aws_autoscaling_group.worker-asg",
    "null_resource.apply_aci_deployment",
  ]

}

resource "aws_lb_target_group_attachment" "elbtg_attachment" {
  #count            = "${length(data.aws_instances.worker-nodes.ids)}"
  count            = "${var.asg_capacity}"
  target_group_arn = "${aws_lb_target_group.elb_target_group.arn}"
  target_id        = "${data.aws_instances.worker-nodes.ids[count.index]}"
  port             = "${var.nodeport}"
}

# uncomment when using EIP for NLB
/*
resource "aws_eip" "elb" {
  vpc      = true
  tags {
      CreatedByTag              = "Created by ${var.name_prefix}-cluster-${random_string.suffix.result}"
  }
}

# replace static-service-ip-pool in the aci deployment file with AWS EIP
resource "null_resource" "edit_aci_deployment_eip" {
  provisioner "local-exec" {
     command = "sed -i -e 's/10.4.63.254/${aws_eip.elb.public_ip}/g' aci_deployment.yaml && sed -i -e 's/10.4.56.2/${aws_eip.elb.public_ip}/g' aci_deployment.yaml"
  }
  depends_on = [
    "null_resource.edit_aci_deployment_epreg",
  ]

}
*/

