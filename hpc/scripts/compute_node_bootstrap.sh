#!/bin/bash
# Compute node bootstrap script for AWS ParallelCluster.
# Executed on each compute node at startup via CustomActions.OnNodeConfigured.
#
# Base OS: Amazon Linux 2 (alinux2)
#
# What this script does:
#   1. Installs Docker via amazon-linux-extras
#   2. Enables and starts the Docker daemon
#   3. Adds ec2-user to the docker group for rootless docker usage

set -euo pipefail

echo "[bootstrap] Starting compute node bootstrap"

# ----------------------------------------
# Docker
# ----------------------------------------
echo "[bootstrap] Installing Docker via amazon-linux-extras"
amazon-linux-extras enable docker
yum install -y docker

echo "[bootstrap] Enabling and starting Docker daemon"
systemctl enable docker
systemctl start docker

echo "[bootstrap] Adding ec2-user to the docker group"
usermod -aG docker ec2-user

echo "[bootstrap] Compute node bootstrap complete"
