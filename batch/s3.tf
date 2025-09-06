resource "aws_s3_bucket" "nf_workdir_bucket" {
  bucket = "${var.bucket_prefix}-nf-workdir"
  force_destroy = true
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = "${var.bucket_prefix}-data"
  force_destroy = true
}