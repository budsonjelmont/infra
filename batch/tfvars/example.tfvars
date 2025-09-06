aws_account_id = "6666666666666666"
aws_region = "us-east-1"

# VPC
# Can be retrieved with: aws ec2 describe-vpcs --query "Vpcs[*].{ID:VpcId,CIDR:CidrBlock}" --output table
vpc_cidr = "66.666.66.6/66"
# To find appropriate tags for filter: aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id-retrieved-above>" --region <region> --query "Subnets[*].Tags"
subnet_filter_tags = {
  routed = "true" # Must use public subnets to access other AWS APIs
}

# Batch
compute_env_max_vcpus = 256
instance_allocation_strategy = "SPOT_PRICE_CAPACITY_OPTIMIZED"

# S3
bucket_prefix = "jxb-batch"