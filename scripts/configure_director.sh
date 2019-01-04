#!/bin/bash
  
source ~/.env

#
# Configure Ops Manager with the correct settings
#
om --skip-ssl-validation -t "${OM_TARGET}" -tr \
    --username "${OM_USERNAME}" --password "${OM_PASSWORD}" \
  configure-director \
    --config "../templates/director.yml" \
    --vars-file config.yml


#
# Apply changes to Director
#
om --skip-ssl-validation -t "${OM_TARGET}" -tr \
    --username "${OM_USERNAME}" --password "${OM_PASSWORD}" \
  apply-changes \
    --skip-deploy-products
