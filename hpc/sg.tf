# Security group for the dev machine only.
# ParallelCluster automatically manages its own security groups for the
# head node and compute nodes — those are not defined here.

resource "aws_security_group" "dev_machine" {
  name   = var.security_group_name
  vpc_id = data.aws_subnet.cluster.vpc_id

  tags = merge(
    { Name = var.security_group_name },
    var.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "dev_machine_ssh" {
  security_group_id = aws_security_group.dev_machine.id

  prefix_list_id = data.aws_ec2_managed_prefix_list.hpc.id
  from_port      = 22
  ip_protocol    = "tcp"
  to_port        = 22
}

resource "aws_vpc_security_group_ingress_rule" "dev_machine_ping" {
  security_group_id = aws_security_group.dev_machine.id

  prefix_list_id = data.aws_ec2_managed_prefix_list.hpc.id
  from_port      = 8
  ip_protocol    = "icmp"
  to_port        = -1
}

resource "aws_vpc_security_group_egress_rule" "dev_machine" {
  security_group_id = aws_security_group.dev_machine.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = -1
  ip_protocol = "-1"
  to_port     = -1
}
