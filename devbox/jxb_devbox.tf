resource "aws_instance" "jxb_devbox" {
  tags = merge(
    {
      Name = var.instance_name_tag
    },
    var.tags
  )
  ami           = data.aws_ami.jxb_devbox.id
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.jxb_devbox.name
  key_name      = aws_key_pair.jxb_devbox.key_name
  network_interface {
    network_interface_id = aws_network_interface.jxb_devbox.id
    device_index         = 0
  }
  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size_gb
  }
  user_data                   = file("${path.module}/${var.user_data_file}")
  user_data_replace_on_change = true # see below
  lifecycle {
    ignore_changes = [
      ami,
      user_data # commenting this out would refresh the EC2 instance each time the user data script changes since user_data_replace_on_change = true
    ]
  }
  metadata_options {
    http_tokens = "required"
  }
}

resource "aws_network_interface" "jxb_devbox" {
  subnet_id       = data.aws_subnet.jxb_devbox.id
  security_groups = [aws_security_group.jxb_devbox.id]
}

resource "aws_security_group" "jxb_devbox" {
  name   = var.security_group_name
  vpc_id = data.aws_subnet.jxb_devbox.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "jxb_devbox_ssh" {
  security_group_id = aws_security_group.jxb_devbox.id

  prefix_list_id = data.aws_ec2_managed_prefix_list.jxb_devbox.id
  from_port      = 22
  ip_protocol    = "tcp"
  to_port        = 22
}

resource "aws_vpc_security_group_ingress_rule" "jxb_devbox_ping" {
  security_group_id = aws_security_group.jxb_devbox.id

  prefix_list_id = data.aws_ec2_managed_prefix_list.jxb_devbox.id
  from_port      = 8
  ip_protocol    = "icmp"
  to_port        = -1
}

resource "aws_vpc_security_group_egress_rule" "jxb_devbox" {
  security_group_id = aws_security_group.jxb_devbox.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = -1
  ip_protocol = "-1"
  to_port     = -1
}

resource "aws_key_pair" "jxb_devbox" {
  key_name   = local.ssh_keyname
  public_key = local.ssh_pubkey
}

resource "aws_iam_role" "jxb_devbox" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "jxb_devbox" {
  name        = var.iam_policy_name
  role        = aws_iam_role.jxb_devbox.id
  policy      = data.aws_iam_policy_document.jxb_devbox.json
}

resource "aws_iam_instance_profile" "jxb_devbox" {
  name = var.iam_instance_profile_name
  role = aws_iam_role.jxb_devbox.name
}

# resource "aws_route53_record" "jxb_devbox" {
#   zone_id = data.aws_route53_zone.jxb_devbox.zone_id
#   name    = "jxb-devbox"
#   type    = "A"
#   ttl     = 300
#   records = aws_network_interface.jxb_devbox.private_ip_list
# }

data "aws_subnet" "jxb_devbox" {
  id = var.subnet_id
}

data "aws_ec2_managed_prefix_list" "jxb_devbox" {
  id = var.prefix_list_id
}

// Not in use
# data "aws_route53_zone" "jxb_devbox" {
#   zone_id = "Z06994823HP6ZIULD641H"
# }

data "aws_iam_policy_document" "jxb_devbox" {
  statement {
    sid    = "AllowS3Read"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = var.readonly_s3_bucket_arns
  }
}

data "aws_ami" "jxb_devbox" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  owners = var.ami_owners
}

locals {
  ssh_keyname = var.ssh_key_name
  ssh_pubkey  = var.ssh_public_key
}