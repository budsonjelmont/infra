output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.jxb_devbox.id
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_network_interface.jxb_devbox.private_ip
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance (if assigned)"
  value       = aws_instance.jxb_devbox.public_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.jxb_devbox.id
}

output "ami_id" {
  description = "ID of the AMI used for the instance"
  value       = data.aws_ami.jxb_devbox.id
}

output "ami_name" {
  description = "Name of the AMI used for the instance"
  value       = data.aws_ami.jxb_devbox.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.jxb_devbox.arn
}

output "iam_instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.jxb_devbox.arn
}
