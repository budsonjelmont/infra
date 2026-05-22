# Create the SLURM cluster via the ParallelCluster REST API.
#
# cluster_config.yaml.tftpl is rendered at apply time via templatefile().
# All values (subnet, key name, EBS volume ID, bootstrap S3 URI) are injected
# directly from Terraform resource attributes — no manual YAML editing required.
resource "aws-parallelcluster_cluster" "cluster" {
  cluster_name             = var.cluster_name
  region                   = var.aws_region
  rollback_on_failure      = true
  validation_failure_level = "WARNING"

  cluster_configuration = templatefile("${path.module}/cluster_config.yaml.tftpl", {
    region                    = var.aws_region
    head_node_instance_type   = var.head_node_instance_type
    head_node_custom_ami      = var.head_node_custom_ami
    head_node_s3_policy_arn   = try(aws_iam_policy.readonly_s3_bucket_access[0].arn, null)
    head_node_bootstrap_script_s3_uri = try("s3://${aws_s3_bucket.bootstrap.id}/${aws_s3_object.head_node_bootstrap[0].key}", null)
    subnet_id                 = var.subnet_id
    key_name                  = aws_key_pair.hpc.key_name
    ebs_volume_id             = aws_ebs_volume.shared.id
    ebs_volume_name           = var.shared_volume_name
    bootstrap_bucket_name     = aws_s3_bucket.bootstrap.id
    bootstrap_script_s3_uri   = "s3://${aws_s3_bucket.bootstrap.id}/${aws_s3_object.compute_node_bootstrap.key}"
    scaledown_idle_time       = var.scaledown_idle_time
    queue_small_max_count           = var.queue_small_max_count
    queue_standard_max_count        = var.queue_standard_max_count
    queue_large_max_count           = var.queue_large_max_count
    queue_med_memory_max_count      = var.queue_med_memory_max_count
    queue_large_memory_max_count    = var.queue_large_memory_max_count
  })

  depends_on = [
    aws_s3_object.compute_node_bootstrap,
    aws_s3_object.head_node_bootstrap,
  ]
}
