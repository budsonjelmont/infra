### ec2 instance role 

data "aws_iam_policy_document" "assume_role_policy_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type  = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_instance_role" {
  name = "${local.app_name}-ec2_instance_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_ec2.json
}

data "aws_iam_policy_document" "ecr_access_policy_document" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchImportUpstreamImage"
    ]
    resources = [aws_ecr_repository.runtime_ecr.arn]
  }
}

resource "aws_iam_policy" "ecr_access_policy" {
  name        = "${local.app_name}-ecr-access-policy"
  description = "Policy for EC2 to access ECR repository"
  policy      = data.aws_iam_policy_document.ecr_access_policy_document.json
}

resource "aws_iam_role_policy_attachment" "ec2_role_ecr_access" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.ecr_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_role_ecr_pullonly" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "ec2_instance_role" {
  role = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ec2_role_container_service_role_attachment" {
  role = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy_attachment" "ec2_role_ssm_managed_instance_core_role_attachment" {
  role = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_role" {
  name = "${local.app_name}-ec2_instance_role"
  role = aws_iam_role.ec2_instance_role.name
}

data "aws_iam_policy_document" "s3_access_policy_document" {
  statement {
    actions   = ["s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject"]
    resources = [
      aws_s3_bucket.nf_workdir_bucket.arn,
      "${aws_s3_bucket.nf_workdir_bucket.arn}/*"
    ]
  }

  statement {
    actions   = [
                "s3:GetObject",
                "s3:ListBucket"]
    resources = [
      aws_s3_bucket.data_bucket.arn,
      "${aws_s3_bucket.data_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.bucket_prefix}-nf-workdir-access-policy"
  description = "Policy for accessing s3 resources"
  policy      = data.aws_iam_policy_document.s3_access_policy_document.json
}

resource "aws_iam_role_policy_attachment" "ec2_instance_s3_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

### batch service role (not needed: omit this & use a service-linked role instead)

# data "aws_iam_policy_document" "assume_role_policy_batch" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     effect  = "Allow"
#     principals {
#       type  = "Service"
#       identifiers = ["batch.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "aws_batch_service_role" {
#   name = "${local.app_name}-aws_batch_service_role"

#   assume_role_policy = data.aws_iam_policy_document.assume_role_policy_batch.json
# }

# resource "aws_iam_role_policy_attachment" "aws_batch_service_role" {
#   role = aws_iam_role.aws_batch_service_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
# }

### spot fleet service role (only needed if compute env is type=="SPOT" and a custom role is needed)

# data "aws_iam_policy_document" "assume_role_policy_spot_service" {
#   statement {
#     effect = "Allow"
#     actions = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["spot.amazonaws.com"]
#     }
#   }
# }
# resource "aws_iam_role" "spot_service_role" {
#   name = "aws-ec2-spot-service-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role_policy_spot_service.json
# }

# resource "aws_iam_role_policy_attachment" "spot_service_role_policy" {
#   role       = aws_iam_role.spot_service_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSEC2SpotServiceRolePolicy"
# }

### compute environment

resource "aws_security_group" "compute_env_sg" {
  name   = "${local.app_name}-compute-environment-security-group"
  vpc_id = data.aws_vpc.vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_batch_compute_environment" "batch_environment" {
  # Create before destroy and neame prefix instead of name should
  # allow updating the compute environment without error
  name = "${local.app_name}-compute-env"
  lifecycle {
    create_before_destroy = true
  }
  compute_resources {
    allocation_strategy = var.instance_allocation_strategy

    instance_role = aws_iam_instance_profile.ec2_instance_role.arn
    instance_type = ["optimal"]
    max_vcpus     = var.compute_env_max_vcpus
    min_vcpus     = 0
    security_group_ids = [
      aws_security_group.compute_env_sg.id,
    ]
    subnets = data.aws_subnets.public_subnets.ids
    type    = "SPOT"
    bid_percentage = 100
    # spot_iam_fleet_role = aws_iam_role.spot_service_role.arn # omit to use default auto-created role
  }

  # service_role = aws_iam_role.aws_batch_service_role.arn # omit to use the batch service-linked role
  type         = "MANAGED"
  # depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role] # must be included if a custom service role is used instead of batch service-linked role
}

### job queue
resource "aws_batch_job_queue" "job_queue" {
  name = "${local.app_name}-job-queue"
  state = "ENABLED"
  priority = 1

    compute_environment_order {
    order = 1
    compute_environment = aws_batch_compute_environment.batch_environment.arn
  }
 
}