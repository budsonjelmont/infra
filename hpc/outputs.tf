output "ebs_volume_id" {
  description = "ID of the shared EBS volume"
  value       = aws_ebs_volume.shared.id
}

output "ssh_key_name" {
  description = "Name of the EC2 key pair"
  value       = aws_key_pair.hpc.key_name
}

output "subnet_id" {
  description = "Subnet ID used by the cluster"
  value       = var.subnet_id
}

output "bootstrap_bucket_name" {
  description = "Name of the S3 bucket hosting compute node bootstrap scripts"
  value       = aws_s3_bucket.bootstrap.id
}

output "bootstrap_script_s3_uri" {
  description = "S3 URI of the compute node bootstrap script"
  value       = "s3://${aws_s3_bucket.bootstrap.id}/${aws_s3_object.compute_node_bootstrap.key}"
}

output "readonly_s3_bucket_access_policy_arn" {
  description = "ARN of the readonly S3 bucket access policy attached to the dev machine and head node (null when readonly_s3_bucket_access is empty)"
  value       = try(aws_iam_policy.readonly_s3_bucket_access[0].arn, null)
}

output "pcluster_api_stack_name" {
  description = "Name of the ParallelCluster API CloudFormation stack"
  value       = var.pcluster_api_stack_name
}

output "dev_machine_instance_id" {
  description = "Instance ID of the dev machine"
  value       = aws_instance.dev_machine.id
}

output "dev_machine_private_ip" {
  description = "Private IP address of the dev machine"
  value       = aws_network_interface.dev_machine.private_ip
}

output "cluster_status" {
  description = "Status of the ParallelCluster cluster"
  value       = try(aws-parallelcluster_cluster.cluster.cluster_status, "not yet created")
}

output "cloudformation_stack_arn" {
  description = "ARN of the cluster CloudFormation stack"
  value       = try(aws-parallelcluster_cluster.cluster.cloudformation_stack_arn, "not yet created")
}
