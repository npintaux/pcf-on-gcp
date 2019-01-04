#!/bin/bash

# Reset the network communication channels in the reverse order they were created 
gcloud compute --project=${PCF_PROJECT_ID} firewall-rules delete bosh 
gcloud compute networks peerings delete ${PCF_SUBDOMAIN_NAME}-pcf-network-to-default
gcloud compute networks peerings delete default-to-${PCF_SUBDOMAIN_NAME}-pcf-network


