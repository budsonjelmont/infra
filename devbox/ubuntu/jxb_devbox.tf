resource "aws_instance" "jxb_devbox" {
  tags = {
    Name = "jxb_devbox"
  }
  ami           = data.aws_ami.jxb_devbox.id
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.jxb_devbox.name
  key_name      = aws_key_pair.jxb_devbox.key_name
  network_interface {
    network_interface_id = aws_network_interface.jxb_devbox.id
    device_index         = 0
  }
  root_block_device {
    volume_type = "gp3"
    volume_size = 100
  }
  user_data                   = file("${path.module}/jxb_devbox_user_data_x86_64.sh")
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
  name   = "jxb_devbox"
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
  name = "jxb_devbox_role"

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
  name        = "jxb_devbox_policy"
  role        = aws_iam_role.jxb_devbox.id
  policy      = data.aws_iam_policy_document.jxb_devbox.json
}

resource "aws_iam_instance_profile" "jxb_devbox" {
  name = "jxb_devbox_profile"
  role = aws_iam_role.jxb_devbox.name
}

# resource "aws_route53_record" "jxb_devbox" {
#   zone_id = data.aws_route53_zone.jxb_devbox.zone_id
#   name    = "jxb-devbox"
#   type    = "A"
#   ttl     = 300
#   records = aws_network_interface.jxb_devbox.private_ip_list
# }
