resource "aws_iam_role" "pclust_launcher" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# SSM access for Session Manager connectivity
resource "aws_iam_role_policy_attachment" "pclust_launcher_ssm" {
  role       = aws_iam_role.pclust_launcher.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# AdministratorAccess is required for the pcluster CLI to create and manage
# clusters. The CLI creates CloudFormation stacks, EC2 instances, IAM roles,
# VPC resources, and FSx/EBS volumes on your behalf.
# TODO: Scope down to least-privilege once the cluster configuration is stable.
#   Reference: https://docs.aws.amazon.com/parallelcluster/latest/ug/iam-roles-in-parallelcluster-v3.html
resource "aws_iam_role_policy_attachment" "pclust_launcher_admin" {
  role       = aws_iam_role.pclust_launcher.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Shared bucket-level access for both EC2s (pclust launcher + cluster head node).
# This grants bucket metadata/list access and object reads.
resource "aws_iam_policy" "readonly_s3_bucket_access" {
  count       = length(var.readonly_s3_bucket_access) > 0 ? 1 : 0
  name        = "${var.cluster_name}-shared-s3-bucket-access"
  description = "Shared S3 bucket-level access for pclust launcher and cluster head node"
  policy      = data.aws_iam_policy_document.readonly_s3_bucket_access[0].json
}

resource "aws_iam_role_policy_attachment" "pclust_launcher_readonly_s3_bucket_access" {
  count      = length(var.readonly_s3_bucket_access) > 0 ? 1 : 0
  role       = aws_iam_role.pclust_launcher.name
  policy_arn = aws_iam_policy.readonly_s3_bucket_access[0].arn
}

data "aws_iam_policy_document" "readonly_s3_bucket_access" {
  count = length(var.readonly_s3_bucket_access) > 0 ? 1 : 0

  statement {
    sid    = "AllowS3BucketRead"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = var.readonly_s3_bucket_access
  }

  statement {
    sid    = "AllowS3ObjectRead"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [for arn in var.readonly_s3_bucket_access : "${arn}/*"]
  }
}

resource "aws_iam_instance_profile" "pclust_launcher" {
  name = var.iam_instance_profile_name
  role = aws_iam_role.pclust_launcher.name
}
