#!/bin/bash
set -e

if [[ -z $1 ]]; then echo "Missing CiviCRM version as parameter 1 (eg. 6.15.2)"; exit 1; fi

CIVIVER=$1
PHPVER='8.3'
DOCKERREGISTRY='localhost:5000'

docker pull php:${PHPVER}-apache-bookworm
docker build build/common-base -t ${DOCKERREGISTRY}/mjw-common-base
docker push ${DOCKERREGISTRY}/mjw-common-base
docker build build/civicrm-base -t ${DOCKERREGISTRY}/mjw-civicrm-base
docker push ${DOCKERREGISTRY}/mjw-civicrm-base

docker build --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-${CIVIVER}-standalone.tar.gz" \
 --build-arg PHP_VERSION=${PHPVER} build/civicrm -t ${DOCKERREGISTRY}/mjw-civicrm-"${CIVIVER}"

docker push ${DOCKERREGISTRY}/mjw-civicrm-"${CIVIVER}"

docker build --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-${CIVIVER}-wordpress.zip" \
 --build-arg PHP_VERSION=${PHPVER} build/civicrm-wordpress -t ${DOCKERREGISTRY}/mjw-civicrm-wordpress-"${CIVIVER}"

docker push ${DOCKERREGISTRY}/mjw-civicrm-wordpress-"${CIVIVER}"

echo "BUILD AND PUSH COMPLETE: PHP version: ${PHPVER}. CiviCRM version: ${CIVIVER}"
