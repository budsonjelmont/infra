Terraform templates for spinning up EC2 environments.

# devbox - Generic development environment

Templates for a general purpose dev environment. Each subdirectory under `/devbox` contains templates for a specific AMI (currently just Ubuntu).

**Note:** `conf.tf` is a template that specifies the hard-coded account-specific parameters that need to be set for the target deployment environment. Modify this file and rename it with prefix `*.private.tf` so it doesn't inadvertently get committed to git.

## Generate execution plan
```bash
cd devbox/ubuntu/ && terraform plan
```

## Deploy stack
```bash
cd devbox/ubuntu/ && terraform apply
```

## Destroy stack
```bash
cd devbox/ubuntu/ && terraform destroy
```

## Connect to the instance
```bash
ssh -i ~/.secret/<keypair_you_specified_in_ssh_keyname_in_conf.tf>.pem ubuntu@<ip_address>
```