#!/bin/bash

source ~/.env

# Create a download folder to download all artefacts
cd ~/
mkdir products_downloads
cd products_downloads

AUTHENTICATION_RESPONSE=$(curl \
  --fail \
  --data "{\"refresh_token\": \"${PCF_PIVNET_UAA_TOKEN}\"}" \
  https://network.pivotal.io/api/v2/authentication/access_tokens)

PIVNET_ACCESS_TOKEN=$(echo ${AUTHENTICATION_RESPONSE} | jq -r '.access_token')

RELEASE_JSON=$(curl \
  --fail \
  "https://network.pivotal.io/api/v2/products/${PRODUCT_SLUG}/releases/${RELEASE_ID}")

EULA_ACCEPTANCE_URL=$(echo ${RELEASE_JSON} |\
  jq -r '._links.eula_acceptance.href')

curl \
  --fail \
  --header "Authorization: Bearer ${PIVNET_ACCESS_TOKEN}" \
  --request POST \
  ${EULA_ACCEPTANCE_URL}


DOWNLOAD_ELEMENT=$(echo ${RELEASE_JSON} |\
  jq -r '.product_files[] | select(.aws_object_key | contains("terraforming-gcp"))')

FILENAME=$(echo ${DOWNLOAD_ELEMENT} |\
  jq -r '.aws_object_key | split("/") | last')

URL=$(echo ${DOWNLOAD_ELEMENT} |\
  jq -r '._links.download.href')

curl \
  --fail \
  --location \
  --output ${FILENAME} \
  --header "Authorization: Bearer ${PIVNET_ACCESS_TOKEN}" \
  ${URL}

# Unzip the artefact and move the resulting folder to the root folder
unzip ./${FILENAME}
mv ./pivotal-cf-terraforming-gcp-*/ ..


# Generate a multi-domain certificate and private key
cd ~/generate-multidomain-cert

cat > selfsignedca.cnf <<-EOF

[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
C = FR
ST = FR
L = Paris
O = Pivotal 
CN = *.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}

[v3_req]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:TRUE
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
DNS.2 = *.apps.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
DNS.3 = *.sys.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
DNS.4 = *.login.sys.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
DNS.5 = *.uaa.sys.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}
## on so on, and so forth.
EOF

./generate_ca.sh

# Generate the terraform.tfvars file
cd ~/pivotal-cf-terraforming-gcp-*/

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
$(cat ~/generate-multidomain-cert/server.crt)
SSL_CERT
ssl_private_key     = <<SSL_KEY
$(cat ~/generate-multidomain-cert/server.key)
SSL_KEY
service_account_key = <<SERVICE_ACCOUNT_KEY
$(cat ~/config/gcp_credentials.json)
SERVICE_ACCOUNT_KEY
EOF

