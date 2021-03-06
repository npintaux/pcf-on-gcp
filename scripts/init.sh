#!/bin/bash

##########################################################
# Jumpbox Toolset                                        #
#     This script initializes all the tools required to  #
#     operate Pivotal Cloud Foundry.                     #
##########################################################

# We first make sure that all the variables are exported in our bash
mv config/environment.cfg ~/.env
source ~/.env
echo "source ~/.env" >> ~/.bashrc

# We then download all tools necessary to operate PCF
sudo apt-get update
sudo apt update --yes && \
sudo apt install --yes unzip && \
sudo apt install --yes jq && \
sudo apt install --yes build-essential && \
sudo apt install --yes ruby-dev && \
sudo gem install --no-ri --no-rdoc cf-uaac

# GCloud CLI
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
echo "Adding the GCLOUD repo to apt-get"
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
echo "Downloading the GCloud key"
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echoo "Installing the GCLOUD SDK"
sudo apt-get install --yes google-cloud-sdk

# Terraform
wget -O terraform.zip https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip && \
  unzip terraform.zip && \
  sudo mv terraform /usr/local/bin && \
  rm terraform.zip

# PCF OM CLI
wget -O om https://github.com/pivotal-cf/om/releases/download/0.48.0/om-linux && \
  chmod +x om && \
  sudo mv om /usr/local/bin/

# BOSH CLI
wget -O bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-5.4.0-linux-amd64 && \
  chmod +x bosh && \
  sudo mv bosh /usr/local/bin/

# BBR CLI
wget -O /tmp/bbr.tar https://github.com/cloudfoundry-incubator/bosh-backup-and-restore/releases/download/v1.3.2/bbr-1.3.2.tar && \
  tar xvC /tmp/ -f /tmp/bbr.tar && \
  sudo mv /tmp/releases/bbr /usr/local/bin/

# PivNet CLI
VERSION=0.0.55
wget -O pivnet https://github.com/pivotal-cf/pivnet-cli/releases/download/v${VERSION}/pivnet-linux-amd64-${VERSION} && \
  chmod +x pivnet && \
  sudo mv pivnet /usr/local/bin/

# let's make sure that our environment is still up-to-date
sudo apt-get upgrade --yes
sudo apt-get update --yes
sudo apt update --yes

# Download utility to generate a multi-domain cert
git clone https://github.com/npintaux/generate-multidomain-cert.git

# Last, we rename the gcloud JSON file 
mv ~/config/*.json ~/config/gcp_credentials.json

