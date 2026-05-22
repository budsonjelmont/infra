#!/bin/bash
# Dev machine user data script for the HPC ParallelCluster dev machine.
# Installs:
#   - AWS CLI v2
#   - AWS ParallelCluster 3.14.0 in a Python virtualenv
#   - Node.js 16 (Gallium) via nvm
#
# ParallelCluster 3.14 requires Node 16. Node 18+ causes the CLI to hang.
# Pin this version to match the pcluster_api.tf CloudFormation template URL.
#
# After launch, SSH in and activate the environment with:
#   source ~/pcluster-venv/bin/activate

set -euo pipefail

EC2_USER="ubuntu"
EC2_HOME="/home/${EC2_USER}"

# ----------------------------------------
# System packages
# ----------------------------------------
apt-get update -y
apt-get install -y \
  python3 \
  python3-pip \
  python3-venv \
  git \
  curl \
  unzip \
  htop \
  tmux \
  vim \
  jq \
  net-tools

# ----------------------------------------
# Dotfiles
# ----------------------------------------
sudo -u $EC2_USER git clone https://github.com/budsonjelmont/unix_utils.git $EC2_HOME/unix_utils

sudo -u $EC2_USER rm $EC2_HOME/.bashrc
sudo -u $EC2_USER ln -s $EC2_HOME/unix_utils/bash_config/.bashrc $EC2_HOME/.bashrc
sudo -u $EC2_USER ln -s $EC2_HOME/unix_utils/bash_config/.bash_aliases $EC2_HOME/.bash_aliases
sudo -u $EC2_USER ln -s $EC2_HOME/unix_utils/bash_config/.bash_funcs $EC2_HOME/.bash_funcs

# ----------------------------------------
# AWS CLI v2
# ----------------------------------------
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp/
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip

# ----------------------------------------
# AWS ParallelCluster 3.14.0 in a virtualenv
#
# Activate with: source ~/pcluster-venv/bin/activate
# Verify with:   pcluster version
# ----------------------------------------
sudo -u "${EC2_USER}" python3 -m venv "${EC2_HOME}/pcluster-venv"
sudo -u "${EC2_USER}" "${EC2_HOME}/pcluster-venv/bin/pip" install --upgrade pip
sudo -u "${EC2_USER}" "${EC2_HOME}/pcluster-venv/bin/pip" install "aws-parallelcluster==3.15.0"

# ----------------------------------------
# Node.js 16 (Gallium) via nvm
#
# IMPORTANT: Node 18+ (Hydrogen) causes pcluster to hang silently. Always use
# Node 16 as the default. If you later install another Node version, reset the
# default with: nvm alias default 16
# ----------------------------------------
sudo -u "${EC2_USER}" bash -c "
  curl -fsSLo- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  export NVM_DIR=\"${EC2_HOME}/.nvm\"
  [ -s \"\${NVM_DIR}/nvm.sh\" ] && source \"\${NVM_DIR}/nvm.sh\"
  nvm install --lts=iron
  nvm alias default 20
  nvm use default
"

# ----------------------------------------
# Shell init: auto-activate pcluster venv and nvm on login
# ----------------------------------------
cat >> "${EC2_HOME}/.bashrc" << 'BASHRC'

# AWS ParallelCluster environment (added by user_data)
source ~/pcluster-venv/bin/activate

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
nvm use default &>/dev/null
BASHRC

chown "${EC2_USER}:${EC2_USER}" "${EC2_HOME}/.bashrc"