#!/bin/bash

##########################################################
# Jumpbox Toolset                                        #
#     This script initializes all the tools required to  #
#     operate Pivotal Cloud Foundry.                     #
##########################################################

# We first make sure that all the variables are exported in our bash
source ~/.env
echo "source ~/.env" >> ~/.bashrc

# We then download all tools necessary to operate PCF
sudo apt update
sudo apt --yes install unzip
sudo apt --yes install jq

# Terraform
wget -O terraform.zip https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip && \
  unzip terraform.zip && \
  sudo mv terraform /usr/local/bin

# PCF OM CLI
wget -O om https://github.com/pivotal-cf/om/releases/download/0.41.0/om-linux && \
  chmod +x om && \
  sudo mv om /usr/local/bin/

# BOSH CLI
wget -O bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-5.3.1-linux-amd64 && \
  chmod +x bosh && \
  sudo mv bosh /usr/local/bin/

# BBR CLI
wget -O /tmp/bbr.tar https://github.com/cloudfoundry-incubator/bosh-backup-and-restore/releases/download/v1.2.8/bbr-1.2.8.tar && \
  tar xvC /tmp/ -f /tmp/bbr.tar && \
  sudo mv /tmp/releases/bbr /usr/local/bin/