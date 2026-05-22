# HPC — AWS ParallelCluster / SLURM

Provisions a SLURM cluster on AWS ParallelCluster 3.15.0 using Terraform.

## Architecture

| Component | Description |
|---|---|
| `bootstrap_api/` | Separate Terraform root that deploys the ParallelCluster REST API CloudFormation stack (API Gateway + Lambda). This must be applied before `hpc/` so the `aws-tf/aws-parallelcluster` provider can initialize. |
| `dev_machine.tf` | EC2 dev machine with the `pcluster` CLI pre-installed. Used to interact with the cluster after it is created. |
| `ebs.tf` | Shared EBS volume mounted cluster-wide at `/shared`. |
| `s3.tf` | S3 bucket hosting compute node bootstrap scripts. |
| `iam.tf` | IAM role and instance profile for the dev machine, plus optional shared S3 bucket access policy attached to both the dev machine and cluster head node. |
| `sg.tf` | Security group for the dev machine (SSH + ICMP from a managed prefix list). |
| `cluster.tf` | The `aws-parallelcluster_cluster` resource that creates the SLURM cluster. |
| `cluster_config.yaml.tftpl` | Terraform template for the ParallelCluster YAML config. All values (subnet, key, EBS volume ID, bootstrap S3 URI) are injected automatically at apply time via `templatefile()`. |
| `scripts/compute_node_bootstrap.sh` | Bash script run on each compute node at startup. Installs and starts Docker, adds `ec2-user` to the docker group. Uploaded to S3 and referenced via `CustomActions.OnNodeConfigured` in every queue. |
| `scripts/head_node_bootstrap.sh` | Optional Bash script run on the head node at startup. Uploaded to S3 and referenced via `HeadNode.CustomActions.OnNodeConfigured` when `enable_head_node_bootstrap = true`. |

### SLURM Queues

| Partition | Instance Type | Default Max Nodes |
|---|---|---|
| `small` | c6i.4xlarge | 30 |
| `standard` | c6i.16xlarge | 30 |
| `large` | c6i.24xlarge | 30 |
| `med-memory` | m6i.4xlarge | 30 |
| `large-memory` | m6i.16xlarge | 30 |

---

## Prerequisites

1. Export temporary AWS credentials into your environment from the AWS account access portal.

2. Ensure Terraform >= 1.5.7 is installed.

3. Copy `tfvars/example.tfvars` to `tfvars/<your-environment>.tfvars` and fill in all values. Note: `subnet_id` and `availability_zone` **must** be in the same AZ, or the EBS volume attachment will fail.

4. Verify the AZ of your chosen subnet:
   ```
   aws ec2 describe-subnets --subnet-ids <subnet_id> --query 'Subnets[].AvailabilityZone'
   ```

5. If the shared EBS volume you intend to use already exists (i.e., it was previously attached to another cluster), detach it before applying:
   EC2 → Volumes → right-click VolumeID → Detach volume. Wait for status to become `Available`.

---

## Deployment

All values required by the cluster configuration (EBS volume ID, SSH key name, subnet ID, bootstrap script S3 URI) are injected automatically via `templatefile()`. No manual YAML editing is required.

### Step A: Bootstrap the ParallelCluster API

```bash
cd hpc/bootstrap_api
terraform init
terraform apply -var-file=tfvars/<your-environment>.tfvars
```

### Step B: Deploy the cluster stack

```bash
cd hpc/
terraform init
terraform apply -var-file=tfvars/<your-environment>.tfvars
```

> The bootstrap API stack can take up to 30 minutes to complete.

---

## Post-Deploy Verification

1. SSH into the dev machine using the private IP from `terraform output dev_machine_private_ip`.

2. Confirm the pcluster CLI is working and the cluster is listed:
   ```bash
   source ~/pcluster-venv/bin/activate
   pcluster list-clusters
   ```

3. Find the new **HeadNode** EC2 instance in the console, note its IP, and SSH in.

4. Check all SLURM partitions are online:
   ```bash
   sinfo
   ```
   Expected output — all 5 partitions in `idle~` state:
   ```
   PARTITION              AVAIL  TIMELIMIT  NODES  STATE NODELIST
   small*                    up   infinite     30  idle~ small-dy-c6i4xlarge-[1-30]
   standard                  up   infinite     30  idle~ standard-dy-c6i16xlarge-[1-30]
   large                     up   infinite     30  idle~ large-dy-c6i24xlarge-[1-30]
   med-memory                up   infinite     30  idle~ med-memory-dy-m6i4xlarge-[1-30]
   large-memory              up   infinite     30  idle~ large-memory-dy-m6i16xlarge-[1-30]
   ```

---

## Teardown

> **Warning**: Deleting the cluster will destroy all data on the head node root volume. Ensure any important data on `/shared` is backed up before proceeding.

**Step 1** — Delete the cluster from the dev machine (or any machine with the pcluster CLI):
```bash
source ~/pcluster-venv/bin/activate
pcluster delete-cluster -n <cluster_name>
```

Wait until the cluster no longer appears in:
```bash
pcluster list-clusters
```

**Step 2** — Destroy the main cluster stack:
```bash
cd hpc/
terraform destroy -var-file=tfvars/<your-environment>.tfvars
```

**Step 3** — Destroy the bootstrap API stack:
```bash
cd hpc/bootstrap_api
terraform destroy -var-file=tfvars/<your-environment>.tfvars
```

> Destroy in this order: `hpc/` first, then `hpc/bootstrap_api/`.

---

## Notes

### Shared S3 Bucket Access (Dev Machine + Head Node)
Use `readonly_s3_bucket_access` in your tfvars to grant both EC2s bucket-level access to the same S3 buckets.

- Accepted format: bucket ARNs only, e.g. `arn:aws:s3:::my-bucket`
- Granted actions: `s3:ListBucket`, `s3:GetBucketLocation`, `s3:GetObject` (on all objects under each listed bucket)
- Attached to:
   - Dev machine IAM role directly
   - Cluster head node via `HeadNode.Iam.AdditionalIamPolicies` in `cluster_config.yaml.tftpl`

Example:
```hcl
readonly_s3_bucket_access = [
   "arn:aws:s3:::my-shared-data-bucket",
]
```

### Head Node User Data Equivalent
To run custom setup logic when the head node is created, use the head-node custom action hook (ParallelCluster equivalent of head-node user data):

- Set `enable_head_node_bootstrap = true` in your tfvars.
- Edit `scripts/head_node_bootstrap.sh` with your desired setup commands.

When enabled, Terraform uploads this script to the bootstrap S3 bucket and injects it into `HeadNode.CustomActions.OnNodeConfigured` in the rendered cluster configuration.

### Temporary Credentials
AWS security policy requires temporary credentials (from the account access portal) rather than permanent user or service role credentials. Export fresh credentials before running any Terraform or pcluster commands.

### Node.js Version
ParallelCluster 3.15.0 requires Node.js 16 (Gallium). Node 18+ causes the CLI to hang silently. If you return to the dev machine after a period of time, confirm the active Node version:
```bash
node --version  # must be v16.x.x
```
If another version is active, reset with:
```bash
nvm use 16
nvm alias default 16
```

### Pinned Versions
Both the ParallelCluster API CloudFormation template URL (`bootstrap_api/main.tf`) and the pip install in `scripts/dev_machine_user_data.sh` are pinned to version `3.15.0`. Do not change one without updating the other.
