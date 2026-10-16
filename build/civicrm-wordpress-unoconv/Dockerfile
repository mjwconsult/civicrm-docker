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

# unoconv left Debian after bookworm: it imports distutils, removed in Python
# 3.12. Install the upstream script with that import swapped for
# python3-looseversion. The /usr/bin link keeps CiviOffice's default path.

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends libreoffice-writer-nogui python3-uno python3-looseversion; \
    rm -rf /var/lib/apt/lists/*; \
    curl -fsSL "https://raw.githubusercontent.com/unoconv/unoconv/0.9.0/unoconv" -o /usr/local/bin/unoconv; \
    echo "f5c33a280c3050025322935687bb0b7453dc1c205c0bbe2318ff55c735b007c0  /usr/local/bin/unoconv" | sha256sum -c -; \
    sed -i -e '1s|.*|#!/usr/bin/python3|' \
        -e 's/^from distutils.version import LooseVersion$/from looseversion import LooseVersion/' /usr/local/bin/unoconv; \
    grep -q '^from looseversion import LooseVersion$' /usr/local/bin/unoconv; \
    chmod +x /usr/local/bin/unoconv; \
    ln -s /usr/local/bin/unoconv /usr/bin/unoconv
