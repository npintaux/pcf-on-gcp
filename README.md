# pcf-on-gcp
This repo attempts to automate much of the installation of Pivotal Cloud Foundry (PCF) on the Google Cloud.
Installation of PCF is usually documented as a first step with Terraform files to lay down the infrastructure, and then a set of manual instructions to configure the system. In this exercise, we are automating as much as possible by using a jumpbox and injecting scripts into the system.

1. Configuration
   There are two files which need to be customized in order to start deploying PCF.
    - config/environment.cfg: list of settings which will customize your PCF installation (FQDN, etc.)
    - Terraform .tfvars file: this file will be used by Terraform to link correctly with your IaaS account and execute the scripts properly.
  
    First modify your config/environment.cfg file to match your environment.

    ```
        PCF_PIVNET_UAA_TOKEN=12345                  # see https://network.pivotal.io/users/dashboard/edit-profile
        PCF_DOMAIN_NAME=example.com                 # e.g. example.com
        PCF_SUBDOMAIN_NAME=pcf                      # e.g. mypcf
        PCF_OPSMAN_ADMIN_PASSWD=my_dummy_password   # e.g. make sure you can remember this password

        PCF_PROJECT_ID=$(gcloud config get-value core/project)          # your GCP project ID, which you can retrieve in your console
        PCF_OPSMAN_FQDN=pcf.${PCF_SUBDOMAIN_NAME}.${PCF_DOMAIN_NAME}    # initialization of the PCF FQDN based on previous variables
    ```
2. Installation of the jumpbox
   The jumpbox is by nature an ephemeral resource which can be installed and destroyed at will. A first Terraform script installs this VM and remotely executes the installation of all the tools and software required to operate PCF.

   Instructions:
   1. Rename the "terraform.tfvars.example" as "terraform.tfvars".
   
        `
            mv terraform.tfvars.example terraform.tfvars
        `
    1. Customize this variable files with your own settings. The Google credential files corresponds to the JSON file corresponding to your service account.
    2. Trigger the Terraform installation of the jumpbox.
   
        `
            terraform init
            terraform plan
            terraform apply
        `
