# HPC — AWS ParallelCluster / SLURM

Provisions a SLURM cluster on AWS ParallelCluster 3.15.0 using Terraform.

## Architecture

| Component | Description |
|---|---|
| `pclust_launcher.tf` | EC2 pclust launcher with the `pcluster` CLI pre-installed. User data automatically runs `pcluster create-cluster` from a Terraform-rendered YAML config. |
| `ebs.tf` | Shared EBS volume mounted cluster-wide at `/shared`. |
| `s3.tf` | S3 bucket hosting compute node bootstrap scripts. |
| `iam.tf` | IAM role and instance profile for the pclust launcher, plus optional shared S3 bucket access policy attached to both the pclust launcher and cluster head node. |
| `sg.tf` | Security group for the pclust launcher (SSH + ICMP from a managed prefix list). |
| `cluster.tf` | Renders the ParallelCluster YAML config from Terraform values and defines a destroy-time lifecycle warning. |
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

### Step A: Deploy infrastructure and trigger cluster creation

```bash
cd hpc/
terraform init
terraform apply -var-file=tfvars/<your-environment>.tfvars
```

> After apply, pclust launcher user data installs ParallelCluster dependencies and runs `pcluster create-cluster` automatically.

---

## Post-Deploy Verification

1. SSH into the pclust launcher using the private IP from `terraform output pclust_launcher_private_ip`.

2. Confirm the pcluster CLI is working and the cluster is listed:
   ```bash
   source ~/pcluster-venv/bin/activate
   pcluster list-clusters
   ```

3. If cluster creation is still in progress or failed, inspect launcher logs:
   ```bash
   sudo tail -n 200 /var/log/pcluster-create.log
   ```

4. Find the new **HeadNode** EC2 instance in the console, note its IP, and SSH in.

5. Check all SLURM partitions are online:
   ```bash
   sinfo
   ```
   Expected output — all partitions in `idle~` state:
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

**Step 1** — Delete the cluster from the pclust launcher (or any machine with the pcluster CLI):
```bash
source ~/pcluster-venv/bin/activate
pcluster delete-cluster -n <cluster_name>
```

Wait until the cluster no longer appears in:
```bash
pcluster list-clusters
```

**Step 2** — Destroy the main Terraform-managed infrastructure:
```bash
cd hpc/
terraform destroy -var-file=tfvars/<your-environment>.tfvars
```

> Terraform prints a warning during destroy to remind you that cluster deletion is manual in hybrid mode.

---

## Notes

### Shared S3 Bucket Access (Pclust Launcher + Head Node)
Use `readonly_s3_bucket_access` in your tfvars to grant both EC2s bucket-level access to the same S3 buckets.

- Accepted format: bucket ARNs only, e.g. `arn:aws:s3:::my-bucket`
- Granted actions: `s3:ListBucket`, `s3:GetBucketLocation`, `s3:GetObject` (on all objects under each listed bucket)
- Attached to:
   - Pclust launcher IAM role directly
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

### Cluster Lifecycle Warning
Note that Terraform does **not** own the cluster lifecycle in state. Always delete the cluster manually before/around `terraform destroy`:

```bash
pcluster delete-cluster -n <cluster_name>
```

If the pclust launcher is unavailable, delete the cluster CloudFormation stack from the AWS console.

### Node.js Version
ParallelCluster 3.15.0 requires Node.js 16 (Gallium). Node 18+ causes the CLI to hang silently. If you return to the pclust launcher after a period of time, confirm the active Node version:
```bash
node --version  # must be v18.x.x
```
If another version is active, reset with:
```bash
nvm use 20
nvm alias default 20
```

### Pinned Versions
The pip install in `scripts/pclust_launcher_user_data.sh.tftpl` is pinned to ParallelCluster version `3.15.0`. Do not change this without validating cluster config compatibility.
