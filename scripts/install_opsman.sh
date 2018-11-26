#!/bin/bash

# Download the YML definition for the installation of Opsman
OPSMAN_VERSION=2.3.5

PRODUCT_NAME="Pivotal Cloud Foundry Operations Manager" \
DOWNLOAD_REGEX="Pivotal Cloud Foundry Ops Manager YAML for GCP" \
PRODUCT_VERSION=${OPSMAN_VERSION} \
  ./scripts/download-product.sh

OPSMAN_IMAGE=$(bosh interpolate ./downloads/ops-manager_${OPSMAN_VERSION}_*/OpsManager*onGCP.yml --path /us)

# Donwload the terraform files to install either PAS or PKS
PAS_VERSION=2.3.3

PRODUCT_NAME="Pivotal Application Service (formerly Elastic Runtime)" \
DOWNLOAD_REGEX="GCP Terraform Templates" \
PRODUCT_VERSION=${PAS_VERSION} \
  ./scripts/download-product.sh
    
unzip ./downloads/elastic-runtime_${PAS_VERSION}_*/terraforming-gcp-*.zip -d .

# Make a multi-domain cert
./scripts/mk-ssl-cert-key.sh


cd ~/ops-manager-automation/pivotal-cf-terraforming-gcp-pks/*

cat > terraform.tfvars <<-EOF
env_name            = "${PCF_SUBDOMAIN_NAME}"
project             = "$(gcloud config get-value core/project)"
region              = "${PCF_REGION}"
zones               = ["${PCF_AZ_2}", "${PCF_AZ_1}", "${PCF_AZ_3}"]
dns_suffix          = "${PCF_DOMAIN_NAME}"
opsman_image_url    = "https://storage.googleapis.com/${OPSMAN_IMAGE}"
create_gcs_buckets  = "false"
external_database   = 0
isolation_segment   = "false"
ssl_cert            = <<SSL_CERT
$(cat ../${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.crt)
SSL_CERT
ssl_private_key     = <<SSL_KEY
$(cat ../${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}.key)
SSL_KEY
service_account_key = <<SERVICE_ACCOUNT_KEY
$(cat ../gcp_credentials.json)
SERVICE_ACCOUNT_KEY
EOF
