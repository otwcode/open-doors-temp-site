#!/usr/bin/env bash

# Make sure the network exists
#docker network create open-doors-temp-site-network

timestamp=$(date +%Y%m%d%H%M%S)
sitekey=terma
#export OD_TEMP_SITE_IMAGE_TAG=$timestamp
export OD_TEMP_SITE_IMAGE_TAG=$sitekey
export OD_TEMP_SITE_NAME=$sitekey
docker-compose -f docker-compose-terma.yml up # --build open-doors-temp-site

# Run after:
#docker-compose run $OD_TEMP_SITE_NAME rake db:setup