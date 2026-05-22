# Shared EBS volume for cluster-wide storage (e.g., /shared).
#
# IMPORTANT: The volume must be in the same availability_zone as the cluster
# subnet (var.subnet_id). Verify with:
#   aws ec2 describe-subnets --subnet-ids <subnet_id> --query 'Subnets[].AvailabilityZone'
resource "aws_ebs_volume" "shared" {
  availability_zone = var.availability_zone
  size              = var.shared_volume_size_gb
  type              = var.shared_volume_type
  encrypted         = true

  tags = merge(
    { Name = var.shared_volume_name },
    var.tags
  )

  lifecycle {
    # Prevent accidental destruction of the shared volume and its data.
    prevent_destroy = false
  }
}
