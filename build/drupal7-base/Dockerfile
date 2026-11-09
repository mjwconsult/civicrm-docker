# Published image: civicrm/drupal7-base
#
# A runtime for CiviCRM on Drupal 7. It holds no Drupal or CiviCRM code: the
# site's Drupal 7 tree, with CiviCRM in sites/all/modules/civicrm, is mounted at
# /var/www/html and updated by hand.

ARG PHP_VERSION

ARG IMAGE_PREFIX=civicrm

FROM ${IMAGE_PREFIX}/common-base:php${PHP_VERSION}

# Install required packages.
#
# Please document the reason for each installed package below.
#
# less is required for drush's pager

RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    less \
    && \
    rm -rf /var/lib/apt/lists/*

# Drush 8, the last release that supports Drupal 7

ARG DRUSH_VERSION=8.5.0
ARG DRUSH_SHA256=d814ec11c9990f2f95fc6e91be77ec6f5deb71d1980142c3f8ce3ad651fd1bae

RUN curl -LsS "https://github.com/drush-ops/drush/releases/download/${DRUSH_VERSION}/drush.phar" -o /usr/local/bin/drush \
    && echo "${DRUSH_SHA256}  /usr/local/bin/drush" | sha256sum -c - \
    && chmod +x /usr/local/bin/drush

# Set the CMS to Drupal 7

ENV CIVICRM_UF=Drupal

# cv and drush find the site from the working directory, including in
# `docker exec` (eg. Ofelia cron jobs)

WORKDIR /var/www/html

# Add CiviCRM on Drupal 7 specific Apache configuration

COPY apache-conf-civicrm-drupal7.conf /etc/apache2/conf-available/civicrm-drupal7.conf

RUN a2enconf civicrm-drupal7

# Overwrite the default entrypoint for a Drupal 7 specific one

COPY civicrm-docker-entrypoint /usr/local/bin/
