#!/bin/bash

##############################################################
# This script must be run as a prerequisite on the jumpbox ! #
##############################################################  

# Authenticate against Google
gcloud auth login

# Enable all Google APIs
gcloud services enable compute.googleapis.com && \
gcloud services enable iam.googleapis.com && \
gcloud services enable cloudresourcemanager.googleapis.com && \
gcloud services enable dns.googleapis.com && \
gcloud services enable sqladmin.googleapis.com
