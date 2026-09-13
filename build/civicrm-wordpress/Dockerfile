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

# Use the default production PHP configuration

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php-cli.ini" \
    && echo 'memory_limit = ${PHP_MEMORY_LIMIT:-"256M"}\n'  >> $PHP_INI_DIR/php.ini \
    && echo 'memory_limit = ${PHP_CLI_MEMORY_LIMIT:-"-1"}\n' >> $PHP_INI_DIR/php-cli.ini

# Copy the downloaded tarball to /var/www/html as the www-data user

# For now, we assume WordPress is bind mounted to /var/www/html. The civicrm-docker-entrypoint script
# will bind mount /var/www/html/civicrm-wordpress /var/www/html/wp-content/plugins/civicrm
COPY --from=build  --chown=www-data:www-data /var/www/html/civicrm /var/www/civicrm-wordpress

# Add our own entrypoint

COPY civicrm-docker-entrypoint /usr/local/bin/
COPY civicrm-docker-applypatches /usr/local/bin/

# Add an installation script

COPY civicrm-docker-install /usr/local/bin/

ENV CIVICRM_UF=WordPress

# Allow Apache port to be configurable

RUN sed -i 's/80/${APACHE_PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

ENV APACHE_PORT=80  

# Set ENTRYPOINT

ENTRYPOINT ["civicrm-docker-entrypoint"]

# Set CMD
#
# Necessary because we redefined CMD. See
# https://docs.docker.com/reference/dockerfile/#understand-how-cmd-and-entrypoint-interact

CMD ["apache2-foreground"]
