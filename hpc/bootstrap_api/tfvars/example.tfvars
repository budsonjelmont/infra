# Example tfvars for bootstrap_api/.
# Copy to <environment>.tfvars and fill in actual values before applying.

aws_region  = "us-east-1"
aws_profile = null

# Must match the value used in hpc/tfvars/<environment>.tfvars.
pcluster_api_stack_name = "parallelcluster-api"

tags = {
  Environment = "dev"
  ManagedBy   = "terraform"
  Project     = "pclust"
}
