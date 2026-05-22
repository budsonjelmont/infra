output "pcluster_api_stack_name" {
  description = "Name of the ParallelCluster API CloudFormation stack"
  value       = aws_cloudformation_stack.pcluster_api.name
}

output "pcluster_api_endpoint" {
  description = "Invoke URL for the ParallelCluster REST API"
  value       = lookup(aws_cloudformation_stack.pcluster_api.outputs, "ParallelClusterApiInvokeUrl", "")
}
