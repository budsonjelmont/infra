// To view available images:
// aws ec2 describe-images --owners amazon --filters "Name=name,Values=ubuntu*" --query 'sort_by(Images, &CreationDate)[].Name'
data "aws_ami" "jxb_devbox" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["amazon"]
}

# data "aws_subnet" "jxb_devbox" {
#   id = "subnet_name_see_conf.private.tf"
# }

# data "aws_ec2_managed_prefix_list" "jxb_devbox" {
#   id = "prefix_list_see_conf.private.tf"
# }

# data "aws_route53_zone" "jxb_devbox" {
#   zone_id = "route_53_zone_id_see_conf.private.tf"
# }

# data "aws_iam_policy_document" "jxb_devbox" {
#   statement {
#     sid    = "AllowS3Read"
#     effect = "Allow"
#     actions = [
#       "s3:GetObject"
#     ]
#     resources = [
#       "arn:aws:s3:::resource/*",
#     ]
#   }
# }

# locals {
#   ssh_keyname = "my_keyname_see_conf.private.tf"
#   ssh_pubkey = "ssh-rsa ABCDE...XYZ see_conf.private.tf"
# }