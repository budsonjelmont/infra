#!/bin/bash
# Head node bootstrap script for AWS ParallelCluster.
# Executed on the head node at startup via HeadNode.CustomActions.OnNodeConfigured.

set -euo pipefail

echo "[head-bootstrap] Starting head node bootstrap"

# Install lightweight admin tooling commonly used for SLURM cluster operations.
yum install -y htop jq tmux vim git

echo "[head-bootstrap] Head node bootstrap complete"
