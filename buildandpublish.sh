#!/bin/bash
# Builds and pushes all docker builds
# Tagged as Major and Minor versions - eg. mjw-civicrm-6.15 will always pull the latest 6.15 release
# mjw-civicrm-6.15.3 will pull 6.15.3..

set -e

if [[ -z $1 ]]; then echo "Missing Major CiviCRM version as parameter 1 (eg. 6.15)"; exit 1; fi
if [[ -z $1 ]]; then echo "Missing Minor CiviCRM version as parameter 2 (eg. for 6.15.3 it would be 3)"; exit 1; fi

# Optionally set PHP version
if [[ -z $2 ]]; then PHPVER='8.3'; else PHPVER=$2; fi

CIVI_MAJOR_VER=$1
CIVI_MINOR_VER=$2
CIVIVER="${CIVI_MAJOR_VER}.${CIVI_MINOR_VER}"
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
docker push ${DOCKERREGISTRY}/mjw-civicrm-"${CIVI_MAJOR_VER}"
docker push ${DOCKERREGISTRY}/mjw-civicrm-"${CIVIVER}"

# Build the CiviCRM WordPress version
docker build --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-${CIVIVER}-wordpress.zip" \
 --build-arg PHP_VERSION="${PHPVER}" build/civicrm-wordpress -t ${DOCKERREGISTRY}/mjw-civicrm-wordpress-"${CIVIVER}"
docker push ${DOCKERREGISTRY}/mjw-civicrm-wordpress-"${CIVI_MAJOR_VER}"
docker push ${DOCKERREGISTRY}/mjw-civicrm-wordpress-"${CIVIVER}"

# Build the unoconv version
docker build --build-arg CIVICRM_VERSION="${CIVIVER}" --build-arg PHP_VERSION="${PHPVER}" build/civicrm-wordpress-unoconv -t localhost:5000/mjw-civicrm-wordpress-unoconv-"${CIVIVER}"
docker push ${DOCKERREGISTRY}/mjw-civicrm-wordpress-unoconv-"${CIVI_MAJOR_VER}"
docker push ${DOCKERREGISTRY}/mjw-civicrm-wordpress-unoconv-"${CIVIVER}"

echo "BUILD AND PUSH COMPLETE: PHP version: ${PHPVER}. CiviCRM version: ${CIVIVER}"
