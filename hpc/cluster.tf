locals {
  # Render the ParallelCluster YAML from Terraform-managed values.
  cluster_config_yaml = templatefile("${path.module}/cluster_config.yaml.tftpl", {
    region                            = var.aws_region
    head_node_instance_type           = var.head_node_instance_type
    head_node_custom_ami              = var.head_node_custom_ami
    head_node_s3_policy_arn           = try(aws_iam_policy.readonly_s3_bucket_access[0].arn, null)
    head_node_bootstrap_script_s3_uri = try("s3://${aws_s3_bucket.bootstrap.id}/${aws_s3_object.head_node_bootstrap[0].key}", null)
    subnet_id                         = var.subnet_id
    key_name                          = aws_key_pair.hpc.key_name
    ebs_volume_id                     = aws_ebs_volume.shared.id
    ebs_volume_name                   = var.shared_volume_name
    bootstrap_bucket_name             = aws_s3_bucket.bootstrap.id
    bootstrap_script_s3_uri           = "s3://${aws_s3_bucket.bootstrap.id}/${aws_s3_object.compute_node_bootstrap.key}"
    scaledown_idle_time               = var.scaledown_idle_time
    queue_small_max_count             = var.queue_small_max_count
    queue_standard_max_count          = var.queue_standard_max_count
    queue_large_max_count             = var.queue_large_max_count
    queue_med_memory_max_count        = var.queue_med_memory_max_count
    queue_large_memory_max_count      = var.queue_large_memory_max_count
  })

  cluster_config_key    = "configs/${var.cluster_name}.yaml"
  cluster_config_s3_uri = "s3://${aws_s3_bucket.bootstrap.id}/${local.cluster_config_key}"
}

# Surface a destroy-time warning since cluster lifecycle is handled by the
# pcluster CLI in hybrid mode and not by Terraform state.
resource "terraform_data" "cluster_destroy_warning" {
  input = var.cluster_name

  provisioner "local-exec" {
    when = destroy
    command = "echo WARNING: ParallelCluster cluster '${self.input}' is not Terraform-managed in hybrid mode. Run 'pcluster delete-cluster -n ${self.input}' first, or delete the cluster CloudFormation stack manually if the pclust launcher is unavailable."
  }
}
