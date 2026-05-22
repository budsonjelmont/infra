# Example tfvars for the hpc/ ParallelCluster module.
# Copy to <environment>.tfvars and fill in actual values before applying.

# ---- AWS Configuration ----
aws_region  = "us-east-1"
aws_profile = null  # or a named profile, e.g. "my-aws-profile"

# ---- Network Configuration ----
# The subnet and AZ must be in the same availability zone.
# Verify the AZ of your subnet with:
#   aws ec2 describe-subnets --subnet-ids <subnet_id> --query 'Subnets[].AvailabilityZone'
subnet_id         = "subnet-xxxxxxxxxxxxxxxxx"
availability_zone = "us-east-1a"
prefix_list_id    = "pl-xxxxxxxxxxxxxxxxx"

# ---- ParallelCluster API ----
# Name of the CloudFormation stack that will host the ParallelCluster REST API.
# This name is also used by the aws-parallelcluster provider to find the endpoint.
pcluster_api_stack_name = "parallelcluster-api"

# ---- Dev Machine Configuration ----
dev_machine_instance_type = "t3.medium"
dev_machine_name_tag      = "jxb-pclust-launcher"
root_volume_type          = "gp3"
root_volume_size_gb       = 50

ami_name_filter = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
ami_owners      = ["amazon"]

# ---- SSH ----
ssh_key_name   = "hpc-keypair"
ssh_public_key = "ssh-rsa AAAA...replace_with_your_actual_public_key..."

# ---- Cluster Configuration ----
cluster_name            = "jxb-pclust"
head_node_instance_type = "t3.medium"

# ---- Shared Storage ----
shared_volume_size_gb = 1000
shared_volume_type    = "gp3"
shared_volume_name    = "shared"

# ---- SLURM Queue Sizes ----
queue_small_max_count          = 30
queue_standard_max_count       = 30
queue_large_max_count          = 30
queue_med_memory_max_count     = 30
queue_large_memory_max_count   = 30

# ---- IAM / S3 ----
# Bucket-level access for BOTH EC2s (dev machine + cluster head node).
# Use bucket ARNs only (no /*). Grants s3:ListBucket, s3:GetBucketLocation,
# and s3:GetObject on all objects in the bucket.
readonly_s3_bucket_access = [
  # "arn:aws:s3:::my-shared-data-bucket",
]

# ---- Bootstrap S3 Bucket ----
# The AWS account ID is automatically appended for global uniqueness.
# e.g. "hpc-bootstrap" becomes "hpc-bootstrap-123456789012"
bootstrap_bucket_prefix = "jxb-pclust-bootstrap"

# Enable a custom bootstrap script on the head node.
# Script path is fixed at scripts/head_node_bootstrap.sh and is uploaded to the
# bootstrap bucket automatically when enabled.
enable_head_node_bootstrap = false

# ---- Cluster Behavior ----
# Minutes a compute node must be idle before it is terminated.
scaledown_idle_time = 5

# ---- Custom AMIs (optional) ----
# Leave commented out to use the default ParallelCluster AMI for alinux2.
# head_node_custom_ami = "ami-xxxxxxxxxxxxxxxxx"

# ---- Resource Names ----
security_group_name       = "jxb-pclust-launcher-sg"
iam_role_name             = "jxb-pclust-launcher-role"
iam_instance_profile_name = "jxb-pclust-launcher-profile"

# ---- Tags ----
tags = {
  Environment = "dev"
  ManagedBy   = "terraform"
  Project     = "hpc"
}
