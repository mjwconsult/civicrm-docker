# MJW Docker CiviCRM Standalone / WordPress build

## "Generic" build:

docker build build/civicrm --build-arg CIVICRM_VERSION=6.12.0 --build-arg PHP_VERSION=8.3 -t mjw-civicrm-6.12.0

## Our build:


So actually using "mjw" branch here: https://github.com/mjwconsult/civicrm-docker/tree/mjw

To build an updated image:

```
docker pull php:8.3-apache-bookworm
docker build build/common-base -t localhost:5000/mjw-common-base
docker push localhost:5000/mjw-common-base
docker build build/civicrm-base -t localhost:5000/mjw-civicrm-base
docker push localhost:5000/mjw-civicrm-base
```

For Standalone:

```
docker build --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-6.15.1-standalone.tar.gz" --build-arg PHP_VERSION=8.3 build/civicrm -t localhost:5000/mjw-civicrm-6.15.1
docker push localhost:5000/mjw-civicrm-6.15.1
```

For WordPress:

```
docker build --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-6.15.1-wordpress.zip" --build-arg PHP_VERSION=8.3 build/civicrm-wordpress -t localhost:5000/mjw-civicrm-wordpress-6.15.1
docker push localhost:5000/mjw-civicrm-wordpress-6.15.1
```

For WordPress (with unoconv): Required for CiviOffice (ShareSoc)

Why not default? Because it brings in a huge stack of packages.

Uncomment `unoconv` in civicrm-wordpress/Dockerfile

```
docker build --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-6.15.1-wordpress.zip" --build-arg PHP_VERSION=8.3 build/civicrm-wordpress -t localhost:5000/mjw-civicrm-wordpress-6.15.1-unoconv
docker push localhost:5000/mjw-civicrm-wordpress-6.15.1-unoconv
```
