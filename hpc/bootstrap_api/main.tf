# Deploy the ParallelCluster REST API as a CloudFormation stack.
#
# The aws-parallelcluster Terraform provider communicates with clusters through
# this API (an API Gateway + Lambda backed service). This stack must exist
# before the main hpc/ Terraform root is initialized/applied.
resource "aws_cloudformation_stack" "pcluster_api" {
  name = var.pcluster_api_stack_name

  template_url = "https://us-east-1-aws-parallelcluster.s3.amazonaws.com/parallelcluster/3.15.0/api/parallelcluster-api.yaml"

  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]

  parameters = {
    EnableIamAdminAccess = "true"
  }

  tags = merge(
    { Name = var.pcluster_api_stack_name },
    var.tags
  )

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}
