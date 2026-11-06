# Published image: civicrm/drupal-base
#
# A runtime for CiviCRM on Drupal 10/11. It holds no Drupal or CiviCRM code:
# Drupal sites install CiviCRM with composer, so each site's own composer
# project (composer.json, vendor/ and web/) is mounted at /var/www/html and
# updated with composer inside the container.

ARG PHP_VERSION

ARG IMAGE_PREFIX=civicrm

FROM ${IMAGE_PREFIX}/common-base:php${PHP_VERSION}

# Install required packages.
#
# Please document the reason for each installed package below.
#
# git and unzip are required for composer to install packages
# less is required for drush's pager

RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    less \
    unzip \
    && \
    rm -rf /var/lib/apt/lists/*

# Serve Drupal's web/ directory (drupal/recommended-project layout)

RUN sed -i 's#DocumentRoot /var/www/html$#DocumentRoot /var/www/html/web#' /etc/apache2/sites-available/000-default.conf \
    && grep -q 'DocumentRoot /var/www/html/web$' /etc/apache2/sites-available/000-default.conf

# Drupal's .htaccess sets zend.assertions to 0. PHP's production default of -1
# can only be changed in php.ini, so mod_php would log a warning on every
# request.

RUN echo 'zend.assertions = 0' > "$PHP_INI_DIR/conf.d/drupal.ini"

# Set the CMS to Drupal 8+ (CiviCRM's name for Drupal 8 onwards)

ENV CIVICRM_UF=Drupal8

# The site's own drush and other composer tools

ENV PATH=/var/www/html/vendor/bin:${PATH}

# cv and drush find the site from the working directory, including in
# `docker exec` (eg. Ofelia cron jobs)

WORKDIR /var/www/html/web

# Add CiviCRM on Drupal specific Apache configuration

COPY apache-conf-civicrm-drupal.conf /etc/apache2/conf-available/civicrm-drupal.conf

RUN a2enconf civicrm-drupal

# Overwrite the default entrypoint for a Drupal specific one

COPY civicrm-docker-entrypoint /usr/local/bin/
