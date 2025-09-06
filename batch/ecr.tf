resource "aws_ecr_repository" "runtime_ecr" {
  name = "${local.app_name}-ecr"
  image_tag_mutability = "MUTABLE"
}