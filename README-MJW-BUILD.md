# MJW Docker CiviCRM Standalone / WordPress build

## "Generic" build:

docker build build/civicrm --build-arg CIVICRM_VERSION=6.15.3 --build-arg PHP_VERSION=8.3 -t mjw-civicrm-6.15.3

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
docker build --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-6.15.3-standalone.tar.gz" --build-arg PHP_VERSION=8.3 build/civicrm -t localhost:5000/mjw-civicrm-6.15.3
docker push localhost:5000/mjw-civicrm-6.15.3
```

For WordPress:

```
docker build --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-6.15.3-wordpress.zip" --build-arg PHP_VERSION=8.3 build/civicrm-wordpress -t localhost:5000/mjw-civicrm-wordpress-6.15.3
docker push localhost:5000/mjw-civicrm-wordpress-6.15.3
```

For WordPress (with unoconv): Required for CiviOffice (ShareSoc)

We build another image on top of mjw-civicrm-wordpress - mjw-civicrm-wordpress-unoconv

which pulls in the unoconv package (and a big stack of packages to support that).

```
docker build --build-arg CIVICRM_VERSION=6.15.3 --build-arg PHP_VERSION=8.3 build/civicrm-wordpress-unoconv -t localhost:5000/mjw-civicrm-wordpress-unoconv-6.15.3
docker push localhost:5000/mjw-civicrm-wordpress-unoconv-6.15.3
```
