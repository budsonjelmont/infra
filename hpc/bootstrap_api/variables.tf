variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use for authentication. Set to null to use default credential chain."
  type        = string
  default     = null
}

variable "pcluster_api_stack_name" {
  description = "Name of the CloudFormation stack that deploys the ParallelCluster REST API"
  type        = string
  default     = "parallelcluster-api"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
