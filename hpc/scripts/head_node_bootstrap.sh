#!/bin/bash
# Head node bootstrap script for AWS ParallelCluster.
# Executed on the head node at startup via HeadNode.CustomActions.OnNodeConfigured.

set -euo pipefail

echo "[head-bootstrap] Starting head node bootstrap"

# Install lightweight admin tooling commonly used for SLURM cluster operations.
yum install -y htop jq tmux vim git

# Get my dotfiles
EC2_USER=ec2_user
EC2_HOME=/home/ec2-user

git clone https://github.com/budsonjelmont/unix_utils.git "$EC2_HOME/unix_utils"

rm -f "$EC2_HOME/.bashrc"
ln -s "$EC2_HOME/unix_utils/bash_config/.bashrc" "$EC2_HOME/.bashrc"
ln -s "$EC2_HOME/unix_utils/bash_config/.bash_aliases" "$EC2_HOME/.bash_aliases"
ln -s "$EC2_HOME/unix_utils/bash_config/.bash_funcs" "$EC2_HOME/.bash_funcs"

echo "[head-bootstrap] Head node bootstrap complete"
