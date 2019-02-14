data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc1" {
  cidr_block = "10.2.0.0/16"

  tags = "${
    map(
     "Name", "${var.name_prefix}-tag-${random_string.suffix.result}",
     "kubernetes.io/cluster/${var.name_prefix}-cluster-${random_string.suffix.result}", "shared",
    )
  }"
}

resource "aws_subnet" "subnet1" {
  count = "${var.subnet_count}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.2.${count.index+1}.0/24"
  vpc_id            = "${aws_vpc.vpc1.id}"

  tags = "${
    map(
     "Name", "${var.name_prefix}-tag-${random_string.suffix.result}",
     "kubernetes.io/cluster/${var.name_prefix}-cluster-${random_string.suffix.result}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "gw1" {
  vpc_id = "${aws_vpc.vpc1.id}"

  tags {
    Name = "${var.name_prefix}-tag-${random_string.suffix.result}"
  }
}

resource "aws_route_table" "route_table1" {
  vpc_id = "${aws_vpc.vpc1.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw1.id}"
  }
}

resource "aws_route_table_association" "route_table_association1" {
  count = "${var.subnet_count}"

  subnet_id      = "${aws_subnet.subnet1.*.id[count.index]}"
  route_table_id = "${aws_route_table.route_table1.id}"
}
