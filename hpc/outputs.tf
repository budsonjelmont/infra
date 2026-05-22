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
  description = "ARN of the readonly S3 bucket access policy attached to the pclust launcher and head node (null when readonly_s3_bucket_access is empty)"
  value       = try(aws_iam_policy.readonly_s3_bucket_access[0].arn, null)
}

output "pclust_launcher_instance_id" {
  description = "Instance ID of the pclust launcher"
  value       = aws_instance.pclust_launcher.id
}

output "pclust_launcher_private_ip" {
  description = "Private IP address of the pclust launcher"
  value       = aws_network_interface.pclust_launcher.private_ip
}

output "cluster_name" {
  description = "ParallelCluster cluster name used by the launcher CLI"
  value       = var.cluster_name
}

output "cluster_config_s3_uri" {
  description = "S3 URI for the rendered cluster configuration consumed by launcher user data"
  value       = local.cluster_config_s3_uri
}

output "cluster_creation_log_hint" {
  description = "Path on the pclust launcher where automatic create-cluster logs are written"
  value       = "/var/log/pcluster-create.log"
}

output "manual_cluster_cleanup_command" {
  description = "Run this before or during terraform destroy to delete the cluster in hybrid mode"
  value       = "pcluster delete-cluster -n ${var.cluster_name}"
}

output "manual_cluster_cleanup_warning" {
  description = "Important lifecycle warning for hybrid mode"
  value       = "Cluster lifecycle is managed by pcluster CLI (not Terraform state). Delete cluster manually with 'pcluster delete-cluster -n ${var.cluster_name}' or delete its CloudFormation stack from the AWS console if the pclust launcher is unavailable."
}
