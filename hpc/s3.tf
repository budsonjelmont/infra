data "aws_caller_identity" "current" {}

# S3 bucket for hosting compute node bootstrap scripts.
# Compute nodes pull and execute the bootstrap script at startup via
# CustomActions.OnNodeConfigured in cluster_config.yaml.tftpl.
resource "aws_s3_bucket" "bootstrap" {
  # Account ID suffix ensures global uniqueness without random resources.
  bucket = "${var.bootstrap_bucket_prefix}-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    { Name = "${var.bootstrap_bucket_prefix}-${data.aws_caller_identity.current.account_id}" },
    var.tags
  )
}

resource "aws_s3_bucket_versioning" "bootstrap" {
  bucket = aws_s3_bucket.bootstrap.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bootstrap" {
  bucket = aws_s3_bucket.bootstrap.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bootstrap" {
  bucket                  = aws_s3_bucket.bootstrap.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload the compute node bootstrap script. The etag triggers a new object
# version (and therefore a cluster update) whenever the script content changes.
resource "aws_s3_object" "compute_node_bootstrap" {
  bucket = aws_s3_bucket.bootstrap.id
  key    = "scripts/compute_node_bootstrap.sh"
  source = "${path.module}/scripts/compute_node_bootstrap.sh"
  etag   = filemd5("${path.module}/scripts/compute_node_bootstrap.sh")
}

# Optional head node bootstrap script. When enabled, this script is executed on
# the head node via HeadNode.CustomActions.OnNodeConfigured.
resource "aws_s3_object" "head_node_bootstrap" {
  count  = var.enable_head_node_bootstrap ? 1 : 0
  bucket = aws_s3_bucket.bootstrap.id
  key    = "scripts/head_node_bootstrap.sh"
  source = "${path.module}/scripts/head_node_bootstrap.sh"
  etag   = filemd5("${path.module}/scripts/head_node_bootstrap.sh")
}

# Upload the rendered cluster config used by the launcher machine to run
# pcluster create-cluster in hybrid mode.
resource "aws_s3_object" "cluster_config" {
  bucket  = aws_s3_bucket.bootstrap.id
  key     = local.cluster_config_key
  content = local.cluster_config_yaml
  etag    = md5(local.cluster_config_yaml)
}
