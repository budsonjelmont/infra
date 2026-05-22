# ---- AWS Configuration ----

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

# ---- Network Configuration ----

variable "subnet_id" {
  description = "ID of the subnet for the pclust launcher and cluster head node. Must be in the same AZ as the shared EBS volume."
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the shared EBS volume. Must match the AZ of subnet_id."
  type        = string
}

variable "prefix_list_id" {
  description = "ID of the managed prefix list for SSH/ICMP access to the pclust launcher."
  type        = string
}

# ---- Pclust Launcher Configuration ----

variable "pclust_launcher_instance_type" {
  description = "EC2 instance type for the pclust launcher that runs the pcluster CLI"
  type        = string
  default     = "t3.medium"
}

variable "pclust_launcher_name_tag" {
  description = "Name tag for the pclust launcher EC2 instance"
  type        = string
  default     = "hpc-pclust-launcher"
}

variable "root_volume_type" {
  description = "Type of root EBS volume for the pclust launcher"
  type        = string
  default     = "gp3"
}

variable "root_volume_size_gb" {
  description = "Size of root EBS volume in GB for the pclust launcher"
  type        = number
  default     = 50
}

# Ubuntu 22.04 LTS is used instead of RHEL9 for consistency with other dev
# machines in this repo. Either is supported by ParallelCluster 3.14.
variable "ami_name_filter" {
  description = "Filter pattern for AMI name lookup for the pclust launcher"
  type        = string
  default     = "ubuntu/images/hvm-ssd-gp3/ubuntu-jammy-22.04-amd64-server-*"
}

variable "ami_owners" {
  description = "List of AMI owner account IDs for the pclust launcher AMI"
  type        = list(string)
  default     = ["amazon"]
}

# ---- SSH ----

variable "ssh_key_name" {
  description = "Name of the EC2 key pair to create. Also used in cluster_config.yaml HeadNode.Ssh.KeyName."
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content for the key pair"
  type        = string
}

# ---- Cluster Configuration ----

variable "cluster_name" {
  description = "Name of the ParallelCluster SLURM cluster. Max 60 characters; max 40 if Slurm accounting is enabled."
  type        = string
}

variable "head_node_instance_type" {
  description = "EC2 instance type for the cluster head node. For the default 150-node queue capacity, use at least 6.6 GB RAM (for example, t3.large)."
  type        = string
  default     = "t3.large"
}

# ---- Shared Storage ----

variable "shared_volume_size_gb" {
  description = "Size of the shared EBS volume in GB"
  type        = number
  default     = 1000
}

variable "shared_volume_type" {
  description = "Type of the shared EBS volume"
  type        = string
  default     = "gp3"
}

variable "shared_volume_name" {
  description = "Name tag for the shared EBS volume."
  type        = string
  default     = "shared"

  validation {
    condition     = var.shared_volume_name != "scratch"
    error_message = "The shared volume name cannot be 'scratch'"
  }
}

# ---- SLURM Queue Sizes ----

variable "queue_small_max_count" {
  description = "Max node count for the 'small' queue (c6i.4xlarge)"
  type        = number
  default     = 30
}

variable "queue_standard_max_count" {
  description = "Max node count for the 'standard' queue (c6i.16xlarge)"
  type        = number
  default     = 30
}

variable "queue_large_max_count" {
  description = "Max node count for the 'large' queue (c6i.24xlarge)"
  type        = number
  default     = 30
}

variable "queue_med_memory_max_count" {
  description = "Max node count for the 'med-memory' queue (m6i.4xlarge)"
  type        = number
  default     = 30
}

variable "queue_large_memory_max_count" {
  description = "Max node count for the 'large-memory' queue (m6i.16xlarge)"
  type        = number
  default     = 30
}

# ---- IAM / S3 ----

variable "readonly_s3_bucket_access" {
  description = "List of S3 bucket ARNs (bucket ARN only, no /*) that both the pclust launcher and cluster head node can access with ListBucket, GetBucketLocation, and GetObject"
  type        = list(string)
  default     = []
}

# ---- Bootstrap S3 Bucket ----

variable "bootstrap_bucket_prefix" {
  description = "Prefix for the S3 bucket that hosts compute node bootstrap scripts. The AWS account ID is appended for global uniqueness."
  type        = string
  default     = "hpc-bootstrap"
}

variable "enable_head_node_bootstrap" {
  description = "Whether to run a custom bootstrap script on the cluster head node via HeadNode.CustomActions.OnNodeConfigured"
  type        = bool
  default     = false
}

# ---- Cluster Behavior ----

variable "scaledown_idle_time" {
  description = "Minutes a compute node must be idle before it is terminated (ScaledownIdletime)"
  type        = number
  default     = 5
}

# ---- Custom AMIs (optional) ----

variable "head_node_custom_ami" {
  description = "Custom AMI ID for the cluster head node. Leave null to use the default ParallelCluster AMI for the selected OS."
  type        = string
  default     = null
}

# ---- Resource Names ----

variable "security_group_name" {
  description = "Name of the pclust launcher security group"
  type        = string
  default     = "hpc-pclust-launcher-sg"
}

variable "iam_role_name" {
  description = "Name of the pclust launcher IAM role"
  type        = string
  default     = "hpc-pclust-launcher-role"
}

variable "iam_instance_profile_name" {
  description = "Name of the pclust launcher IAM instance profile"
  type        = string
  default     = "hpc-pclust-launcher-profile"
}

# ---- Tags ----

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
