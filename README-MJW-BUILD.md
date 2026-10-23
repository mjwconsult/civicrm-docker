# MJW Docker CiviCRM Standalone / WordPress build

## "Generic" build:

docker build build/civicrm --build-arg CIVICRM_VERSION=6.15.3 --build-arg PHP_VERSION=8.3 -t mjw-civicrm-6.15.3

## Our build:

So actually using "mjw" branch here: https://github.com/mjwconsult/civicrm-docker/tree/mjw

MJW images are built from tarballs on `res.mjw.pt` instead of `download.civicrm.org`. `--download-prefix` swaps out that part of the URL, so `build.php` builds the whole set in one go:

```
./build.php --civicrm-version=6.17.3 \
  --download-prefix=https://res.mjw.pt/dl/mjw \
  --image-prefix=dockerhub.mjw.pt \
  --php-version=8.3
```

Each image gets its own archive flavour, eg. `https://res.mjw.pt/dl/mjwcivicrm-6.17.3-standalone.tar.gz` for standalone and `https://res.mjw.pt/dl/mjwcivicrm-6.17.3-wordpress.zip` for WordPress. Add `--dry-run` to see the `docker build` commands without running them, and `--skip-push` to build without publishing. Drop `--civicrm-version` to build the latest stable release. `--php-version` accepts a list, eg. `8.3,8.4`.

`--image-prefix` sets both where each image's `FROM` pulls its base from and where the built image is tagged and pushed, so the whole chain stays on one registry. This replaces the older split where bases went to `localhost:5000` but were pulled from Docker Hub.

Note the image names differ from `buildandpublish.sh`: the version is in the tag rather than the name, so `localhost:5000/mjw-civicrm-6.17.3` becomes `dockerhub.mjw.pt/civicrm:6.17.3-php8.3`, with `:6.17-php8.3` tracking the series. Compose files referencing the old names need updating.

## amd64 and arm64

To build both architectures, so the same tags run on x86 and Graviton hosts, add `--platform=linux/amd64,linux/arm64`. Each tag becomes a manifest list and every host pulls its own architecture.

The default `docker` builder can't produce multi-platform images, so create a `docker-container` builder once and pass it with `--builder`:

```
docker buildx create --name mjw-multi --driver docker-container --driver-opt network=host --bootstrap
docker run --privileged --rm tonistiigi/binfmt --install all

./build.php --civicrm-version=6.17.3 \
  --download-prefix=https://res.mjw.pt/dl/mjw \
  --image-prefix=dockerhub.mjw.pt \
  --php-version=8.3 \
  --builder=mjw-multi \
  --platform=linux/amd64,linux/arm64
```

- `tonistiigi/binfmt` registers QEMU so the host can build the other architecture. Compiling the PECL extensions under emulation is slow; a native node added with `docker buildx create --append --name mjw-multi <endpoint>` avoids it.
- `network=host` gives the builder the host's `/etc/hosts`. On d1 that carries the loopback pin for `dockerhub.mjw.pt`; without it pushes go out and back in through Traefik, and the request rate gets d1 banned by CrowdSec.
- Don't combine this with `--skip-push`. A `docker-container` builder doesn't load images into the local Docker image store, and each image's `FROM` pulls its parent from `--image-prefix`, so the chain only works when every image is pushed as it is built.

## Manual builds

To build an updated image by hand:

```
docker pull php:8.3-apache-trixie
docker build build/common-base --build-arg IMAGE_TAG=8.3-apache-trixie -t localhost:5000/common-base
docker push localhost:5000/common-base
docker build build/civicrm-base -t localhost:5000/civicrm-base
docker push localhost:5000/civicrm-base
```

For Standalone:

```
docker build \
  --build-arg IMAGE_PREFIX=dockerhub.mjw.pt \
  --build-arg PHP_VERSION=8.3 \
  --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-6.17.3-standalone.tar.gz" \
  build/civicrm -t localhost:5000/mjw-civicrm-6.17.3
docker push localhost:5000/mjw-civicrm-6.17.3
```

For WordPress:

```
docker build \
  --build-arg IMAGE_PREFIX=dockerhub.mjw.pt \
  --build-arg PHP_VERSION=8.3 \
  --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-6.17.3-wordpress.zip" \
  build/civicrm-wordpress -t localhost:5000/mjw-civicrm-wordpress-6.17.3
docker push localhost:5000/mjw-civicrm-wordpress-6.17.3
```

For WordPress (with unoconv): Required for CiviOffice

We build another image on top of mjw-civicrm-wordpress - mjw-civicrm-wordpress-unoconv

which pulls in the unoconv package (and a big stack of packages to support that).

```
docker build --build-arg CIVICRM_VERSION=6.15.3 --build-arg PHP_VERSION=8.3 build/civicrm-wordpress-unoconv -t localhost:5000/mjw-civicrm-wordpress-unoconv-6.15.3
docker push localhost:5000/mjw-civicrm-wordpress-unoconv-6.15.3
```
