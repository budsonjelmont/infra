variable "aws_account_id" {
  description = "AWS numeric account ID for resource ARNs and permissions."
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "subnet_filter_tags" {
  description = "Tags to filter public subnets in the VPC."
  type        = map(string)
  default     = {}
}

variable "compute_env_max_vcpus" {
  description = "Maximum vCPUs for AWS Batch compute environment."
  type        = number
  default     = 1000
}

variable "instance_allocation_strategy" {
  description = "Allocation strategy for AWS Batch compute environment."
  type        = string
  default     = "BEST_FIT_PROGRESSIVE"
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket names."
  type        = string
}
