resource "aws_instance" "dev_machine" {
  ami                  = data.aws_ami.dev_machine.id
  instance_type        = var.dev_machine_instance_type
  iam_instance_profile = aws_iam_instance_profile.dev_machine.name
  key_name             = aws_key_pair.hpc.key_name

  network_interface {
    network_interface_id = aws_network_interface.dev_machine.id
    device_index         = 0
  }

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size_gb
    encrypted   = true
  }

  user_data                   = file("${path.module}/scripts/dev_machine_user_data.sh")
  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required"
  }

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }

  tags = merge(
    { Name = var.dev_machine_name_tag },
    var.tags
  )
}

resource "aws_network_interface" "dev_machine" {
  subnet_id       = data.aws_subnet.cluster.id
  security_groups = [aws_security_group.dev_machine.id]

  tags = var.tags
}

resource "aws_key_pair" "hpc" {
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
}

data "aws_subnet" "cluster" {
  id = var.subnet_id
}

data "aws_ec2_managed_prefix_list" "hpc" {
  id = var.prefix_list_id
}

data "aws_ami" "dev_machine" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  owners = var.ami_owners
}
