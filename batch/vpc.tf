data "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  tags = var.subnet_filter_tags
}
