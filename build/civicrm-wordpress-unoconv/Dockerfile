# Published image: civicrm-wordpress-unoconv
#
# CiviCRM on WordPress with unoconv, for CiviOffice document rendering.

ARG PHP_VERSION=8.3

ARG IMAGE_PREFIX=civicrm

# Specify a CiviCRM version. Both this and PHP_VERSION carry defaults only so
# that the FROM below is a valid reference when parsed without build args;
# build.php always passes real values.

ARG CIVICRM_VERSION=latest

FROM ${IMAGE_PREFIX}/civicrm-wordpress:${CIVICRM_VERSION}-php${PHP_VERSION}

# unoconv pulls in LibreOffice and the rest of its dependency stack.

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends unoconv; \
    rm -rf /var/lib/apt/lists/*
