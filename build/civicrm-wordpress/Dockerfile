# Published image: civicrm/civicrm-wordpress
#
# This is a ready to use CiviCRM on WordPress image.

ARG PHP_VERSION

ARG IMAGE_PREFIX=civicrm

FROM ${IMAGE_PREFIX}/wordpress-base:php${PHP_VERSION} AS build

# Specify a CiviCRM version

ARG CIVICRM_VERSION

# Specify a tarball URL to download (overrides CIVICRM_VERSION)

ARG CIVICRM_DOWNLOAD_URL="https://download.civicrm.org/civicrm-${CIVICRM_VERSION}-wordpress.zip"

# Download the CiviCRM tarball

RUN curl --fail --location ${CIVICRM_DOWNLOAD_URL} --output civicrm-wordpress.zip \
    && unzip -q civicrm-wordpress.zip \
    && rm civicrm-wordpress.zip

FROM ${IMAGE_PREFIX}/wordpress-base:php${PHP_VERSION}

# Copy the downloaded tarball to /var/www/html as the www-data user

# For now, we assume WordPress is bind mounted to /var/www/html. The civicrm-docker-entrypoint script
# will bind mount /var/www/html/civicrm-wordpress /var/www/html/wp-content/plugins/civicrm
COPY --from=build  --chown=www-data:www-data /var/www/html/civicrm /var/www/civicrm-wordpress

# Replace the wordpress-base entrypoint with one that links in the CiviCRM plugin

COPY civicrm-docker-entrypoint /usr/local/bin/

# Add an installation script

COPY civicrm-docker-install /usr/local/bin/
