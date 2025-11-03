# Published image: civicrm/civicrm
#
# This is a ready to use CiviCRM standalone image.

ARG PHP_VERSION=8.3

ARG IMAGE_PREFIX=civicrm

FROM ${IMAGE_PREFIX}/civicrm-base:php${PHP_VERSION} AS build

RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    unzip \
    && \
    rm -rf /var/lib/apt/lists/*

# Specify a CiviCRM version

ARG CIVICRM_VERSION

# Specify a tarball URL to download (overrides CIVICRM_VERSION)

ARG CIVICRM_DOWNLOAD_URL="https://download.civicrm.org/civicrm-${CIVICRM_VERSION}-wordpress.zip"

RUN echo "CiviCRM Download URL: $CIVICRM_DOWNLOAD_URL"
RUN echo "PHP Version: $PHP_VERSION"

# Download the tarball

RUN curl --fail --location ${CIVICRM_DOWNLOAD_URL} --output civicrm-wordpress.zip \
    && unzip -q civicrm-wordpress.zip \
    && rm civicrm-wordpress.zip

FROM ${IMAGE_PREFIX}/civicrm-base:php${PHP_VERSION}

# Install less (required by wp-cli)
RUN set -eux; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    less \
    && \
    rm -rf /var/lib/apt/lists/*

# Download wp-cli (https://wp-cli.org/#installing)

RUN curl -LsS https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

# Use the default production configuration

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

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
