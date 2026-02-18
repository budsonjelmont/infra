variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use for authentication (optional)"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "ID of the subnet where the instance will be deployed"
  type        = string
}

variable "prefix_list_id" {
  description = "ID of the managed prefix list for SSH/ICMP access"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name_tag" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "jxb_devbox"
}

variable "root_volume_type" {
  description = "Type of root EBS volume"
  type        = string
  default     = "gp3"
}

variable "root_volume_size_gb" {
  description = "Size of root EBS volume in GB"
  type        = number
  default     = 100
}

// To view available images:
// aws ec2 describe-images --owners amazon --filters "Name=name,Values=ubuntu*" --query 'sort_by(Images, &CreationDate)[].Name'

variable "ami_name_filter" {
  description = "Filter pattern for AMI name lookup"
  type        = string
  default     = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
}

variable "ami_owners" {
  description = "List of AMI owner account IDs"
  type        = list(string)
  default     = ["amazon"]
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
}

variable "user_data_file" {
  description = "Path to the user data script file (relative to module)"
  type        = string
  default     = "scripts/jxb_devbox_user_data_x86_64.sh"
}

variable "readonly_s3_bucket_arns" {
  description = "List of S3 bucket ARNs for IAM policy (including /* suffix)"
  type        = list(string)
}

variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "jxb_devbox"
}

variable "iam_role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = "jxb_devbox_role"
}

variable "iam_policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = "jxb_devbox_policy"
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile"
  type        = string
  default     = "jxb_devbox_profile"
}

variable "allow_all_egress" {
  description = "Whether to allow all egress traffic"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID (optional)"
  type        = string
  default     = null
}

variable "route53_record_name" {
  description = "Route53 DNS record name (optional)"
  type        = string
  default     = null
}
