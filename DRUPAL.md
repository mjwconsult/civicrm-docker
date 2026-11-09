# Drupal

`drupal-base` runs CiviCRM on Drupal 10 or 11. Unlike the WordPress and Standalone images it holds no Drupal or CiviCRM code: on Drupal, CiviCRM is installed with composer alongside the site's own modules, so each site brings its own composer project (a [drupal/recommended-project](https://www.drupal.org/docs/develop/using-composer/starting-a-site-using-drupal-composer-project-templates) layout with `civicrm/civicrm-core`, `civicrm/civicrm-drupal-8` and `civicrm/civicrm-packages`).

Mount the project at `/var/www/html`; Apache serves `/var/www/html/web`.

```yaml
services:
  app:
    image: civicrm/drupal-base:php8.3
    volumes:
      - ./drupal:/var/www/html
      - ./patches:/var/www/patches:ro   # optional, see below
```

## Composer, drush and cv

Run them as `www-data`, inside the container. The working directory is `/var/www/html/web` and the project's `vendor/bin` is on the `PATH`, so the site's own drush and `cv` find the site without options:

```shell
docker compose exec -u www-data app composer install --no-dev
docker compose exec -u www-data app drush status
docker compose exec -u www-data app cv api4 Contact.get +l 1
```

Install the project's dependencies with the image's PHP, not on another machine, so that `vendor/` matches the PHP version that runs it.

Updating CiviCRM is a composer update of the site:

```shell
docker compose exec -u www-data app composer require 'civicrm/civicrm-core:~6.20.0' 'civicrm/civicrm-drupal-8:~6.20.0' 'civicrm/civicrm-packages:~6.20.0' -W --no-dev
docker compose exec -u www-data app cv upgrade:db
docker compose exec -u www-data app drush updatedb -y
docker compose exec -u www-data app drush cache:rebuild
docker compose restart app   # re-applies local patches to the new core
```

## Environment variables

- `CIVICRM_DRUPAL_MODULE_DIR` - the CiviCRM Drupal module, for patches (default: `/var/www/html/web/modules/contrib/civicrm`)
- `PHP_MEMORY_LIMIT`, `PHP_CLI_MEMORY_LIMIT`, `APACHE_MAX_REQUEST_WORKERS`, `APACHE_PORT` - as for the other images, see [README.md](README.md#environment-variables)

Database settings live in the site's `settings.php` and `civicrm.settings.php`, as on any Drupal site; both can read the container's environment with `getenv()`.

Behind a reverse proxy, set Drupal's `$settings['reverse_proxy']` and `$settings['reverse_proxy_addresses']`, or Drupal won't see that requests arrived over HTTPS.

## Patching CiviCRM

Patches mounted at `/var/www/patches` are applied to `vendor/civicrm/civicrm-core` at container start, and those in its `drupal` subdirectory to the CiviCRM Drupal module, as described in [Patching CiviCRM core](README.md#patching-civicrm-core). `composer install` or `update` replaces the patched code; restart the container to patch it again. `patchlog.log` goes to `web/sites/default/files/civicrm/ConfigAndLog`.

## Files

`web/sites/*/files` may serve files but never runs PHP. CiviCRM keeps its logs, uploads, custom field files and compiled templates under `web/sites/default/files/civicrm`; the image refuses to serve `ConfigAndLog`, `upload`, `custom` and `templates_c` from there. Keep Drupal's private files outside `web/`, eg. `$settings['file_private_path'] = '../private';`.

## Drupal 7

`drupal7-base` runs CiviCRM on Drupal 7. Drupal 7 is past its end of life; this image exists to move existing sites, not to start new ones. Like `drupal-base` it holds no Drupal or CiviCRM code: mount the site's Drupal tree, with CiviCRM's Drupal 7 tarball unpacked in `sites/all/modules/civicrm`, at `/var/www/html`, which is also the docroot.

```yaml
services:
  app:
    image: civicrm/drupal7-base:php8.3
    volumes:
      - ./drupal:/var/www/html
      - ./private:/var/www/private      # Drupal's private files, outside the docroot
      - ./patches:/var/www/patches:ro   # optional
```

- The tree must be owned by `www-data`, or patches can't be applied (and Drupal can't write `sites/default/files`).
- The image has drush 8 (the last release for Drupal 7) on the `PATH`, and the working directory is `/var/www/html`, so `drush` and `cv` find the site without options.
- Patches apply to `sites/all/modules/civicrm`, and those in the `drupal` subdirectory to `sites/all/modules/civicrm/drupal`. Set `CIVICRM_CORE_DIR` if CiviCRM is elsewhere.
- Drupal 7 only takes HTTPS from `$_SERVER['HTTPS']`. Behind a reverse proxy, set it in `settings.php` from `X-Forwarded-Proto` (when only the proxy can reach the container), or Drupal builds `http://` links.
- The same `files` rules apply, without the `web/` prefix.

Update CiviCRM by replacing `sites/all/modules/civicrm` with the new Drupal 7 tarball, then:

```shell
docker compose exec -u www-data app cv upgrade:db
docker compose exec -u www-data app drush cc all
docker compose restart app   # re-applies local patches to the new code
```
