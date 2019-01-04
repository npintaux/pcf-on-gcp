#!/bin/bash
  
source ~/.env

om --skip-ssl-validation -t "${OM_TARGET}" -tr \
    --username "${OM_USERNAME}" --password "${OM_PASSWORD}" \
  configure-director \
    --config "../templates/director.yml" \
    --vars-file config.yml
