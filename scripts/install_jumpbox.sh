#!/bin/bash

# Source the environment variables to keep things consistent
cp ../config/environment.cfg ~/.env
source ~/.env
echo "source ~/.env" >> ~/.bashrc

# Generate a tfvars file for the jumpbox
cat > terraform.tfvars <<-EOF
project_id      = "$(gcloud config get-value core/project)"
region          = "${PCF_REGION}"
zone            = "${PCF_AZ_1}"
credentials_file= "~/config/gcp_credentials.json"
jumpbox_name    = "jumpbox"
EOF

mv terraform.tfvars ../tf-jumpbox
cd ../tf-jumpbox
terraform init
terraform plan
terraform apply -auto-approve

