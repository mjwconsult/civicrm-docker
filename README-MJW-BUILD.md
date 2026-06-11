# MJW Docker CiviCRM Standalone / WordPress build

## "Generic" build:

docker build build/civicrm --build-arg CIVICRM_VERSION=6.12.0 --build-arg PHP_VERSION=8.3 -t mjw-civicrm-6.12.0

## Our build:


So actually using "mjw" branch here: https://github.com/mjwconsult/civicrm-docker/tree/mjw

To build an updated image:

```
docker pull php:8.3-apache-bookworm
docker build build/common-base -t mjw-common-base
docker build build/civicrm-base -t mjw-civicrm-base
```

For Standalone:

```
docker build --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-6.15.1-standalone.tar.gz" --build-arg PHP_VERSION=8.3 build/civicrm -t mjw-civicrm-6.15.1
```

For WordPress:

```
docker build --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-6.15.1-wordpress.zip" --build-arg PHP_VERSION=8.3 build/civicrm-wordpress -t mjw-civicrm-wordpress-6.15.1
```



