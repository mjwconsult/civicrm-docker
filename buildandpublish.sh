#!/bin/bash
set -e

if [[ -z $1 ]]; then echo "Missing CiviCRM version as parameter 1 (eg. 6.15.3)"; exit 1; fi

# Optionally set PHP version
if [[ -z $2 ]]; then PHPVER='8.3'; else PHPVER=$2; fi

CIVIVER=$1
DOCKERREGISTRY='localhost:5000'

docker pull php:${PHPVER}-apache-bookworm
# Build mjw-common-base
docker build build/common-base -t ${DOCKERREGISTRY}/mjw-common-base
docker push ${DOCKERREGISTRY}/mjw-common-base
# Build mjw-civicrm-base
docker build build/civicrm-base -t ${DOCKERREGISTRY}/mjw-civicrm-base
docker push ${DOCKERREGISTRY}/mjw-civicrm-base

# Build the CiviCRM standalone version
docker build --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-${CIVIVER}-standalone.tar.gz" \
 --build-arg PHP_VERSION="${PHPVER}" build/civicrm -t ${DOCKERREGISTRY}/mjw-civicrm-"${CIVIVER}"
docker push ${DOCKERREGISTRY}/mjw-civicrm-"${CIVIVER}"

# Build the CiviCRM WordPress version
docker build --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-${CIVIVER}-wordpress.zip" \
 --build-arg PHP_VERSION="${PHPVER}" build/civicrm-wordpress -t ${DOCKERREGISTRY}/mjw-civicrm-wordpress-"${CIVIVER}"
docker push ${DOCKERREGISTRY}/mjw-civicrm-wordpress-"${CIVIVER}"

# Build the unoconv version
docker build --build-arg CIVICRM_VERSION="${CIVIVER}" --build-arg PHP_VERSION="${PHPVER}" build/civicrm-wordpress-unoconv -t localhost:5000/mjw-civicrm-wordpress-unoconv-"${CIVIVER}"
docker push ${DOCKERREGISTRY}/mjw-civicrm-wordpress-unoconv-"${CIVIVER}"

echo "BUILD AND PUSH COMPLETE: PHP version: ${PHPVER}. CiviCRM version: ${CIVIVER}"
