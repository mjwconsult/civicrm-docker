# Published image: mjw-civicrm-wordpress-unoconv-CIVICRM_VERSION
#
# CiviCRM WordPress with unoconv

# Specify a CiviCRM version

ARG CIVICRM_VERSION

FROM dockerhub.mjw.pt/mjw-civicrm-wordpress-${CIVICRM_VERSION}:latest

RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    unoconv \
    && \
    rm -rf /var/lib/apt/lists/* \
