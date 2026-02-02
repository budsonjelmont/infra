# Example tfvars file
# Copy this to <environment>.tfvars and update with actual values

# AWS Configuration
aws_region  = "us-east-1"
aws_profile = "default" # or null to use default AWS credentials

# Network Configuration
subnet_id      = "subnet-xxxxxxxxxxxxxxxxx" # Replace with actual subnet ID
prefix_list_id = "pl-xxxxxxxxxxxxxxxxx"     # Replace with actual prefix list ID

# Instance Configuration
instance_type       = "t2.micro"
instance_name_tag   = "jxb_devbox"
root_volume_type    = "gp3"
root_volume_size_gb = 100

# AMI Configuration
ami_name_filter = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
ami_owners      = ["amazon"]

# SSH Key Configuration
ssh_key_name   = "jxb_ec2_rsa_keypair"
ssh_public_key = "ssh-rsa AAAA...replace_with_your_actual_public_key..."

# User Data Script
user_data_file = "jxb_devbox_user_data_x86_64.sh"

# S3 Bucket Access (for IAM policy)
readonly_s3_bucket_arns = [
  "arn:aws:s3:::read-only-bucket/*",
]

# Resource Names (optional, defaults are provided)
security_group_name        = "jxb_devbox"
iam_role_name              = "jxb_devbox_role"
iam_policy_name            = "jxb_devbox_policy"
iam_instance_profile_name  = "jxb_devbox_profile"

# Network Settings
allow_all_egress = true

# Additional Tags
tags = {
  Environment = "dev"
  Owner       = "jxb"
  ManagedBy   = "terraform"
}

# Route53 (optional - set to null if not using)
route53_zone_id     = null
route53_record_name = null
