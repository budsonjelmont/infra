#!/bin/bash

UBUNTU_HOME="/home/ubuntu"

apt-get update && apt-get install -y htop jq less tmux vim git net-tools pv parallel iftop ca-certificates curl
snap install aws-cli --classic

####################

# Get my dotfiles
sudo -u ubuntu git clone https://github.com/budsonjelmont/unix_utils.git $UBUNTU_HOME/unix_utils

sudo -u ubuntu rm $UBUNTU_HOME/.bashrc
sudo -u ubuntu ln -s $UBUNTU_HOME/unix_utils/bash_config/.bashrc $UBUNTU_HOME/.bashrc
sudo -u ubuntu ln -s $UBUNTU_HOME/unix_utils/bash_config/.bash_aliases $UBUNTU_HOME/.bash_aliases
sudo -u ubuntu ln -s $UBUNTU_HOME/unix_utils/bash_config/.bash_funcs $UBUNTU_HOME/.bash_funcs

####################

# Docker install -- from https://docs.docker.com/engine/install/ubuntu/

# Add Docker's official GPG key:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Required for dockerd to work in some environments. See https://github.com/WhitewaterFoundry/Pengwin/issues/485#issuecomment-518028465
# sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
# sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

####################

# Create docker group and add user to it

sudo usermod -aG docker ubuntu

####################

# Install miniconda

sudo -u ubuntu mkdir $UBUNTU_HOME/miniconda3
sudo -u ubuntu wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $UBUNTU_HOME/miniconda3/miniconda.sh
sudo -u ubuntu bash $UBUNTU_HOME/miniconda3/miniconda.sh -b -u -p $UBUNTU_HOME/miniconda3
sudo -u ubuntu rm $UBUNTU_HOME/miniconda3/miniconda.sh

sudo -u ubuntu $UBUNTU_HOME/miniconda3/condabin/conda init bash

####################

# Install java

sudo apt install default-jdk -y

####################

# Install nodeJS

sudo -u ubuntu bash -c "cd $UBUNTU_HOME && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash"
sudo -u ubuntu bash -c "export NVM_DIR=\"$UBUNTU_HOME/.nvm\" && [ -s \"$UBUNTU_HOME/.nvm/nvm.sh\" ] && source \"$UBUNTU_HOME/.nvm/nvm.sh\" &&  nvm install --lts && npm install --global yarn"

####################

# Install uv

sudo -u ubuntu bash -c "curl -LsSf https://astral.sh/uv/install.sh | bash"

####################

# TODO Commands below don't work in non-interactive shell

####################

# Install lazygit

sudo -u ubuntu LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
sudo -u ubuntu curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
sudo -u ubuntu tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

####################