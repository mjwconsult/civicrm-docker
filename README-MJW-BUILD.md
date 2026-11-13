# MJW Docker CiviCRM Standalone / WordPress build

## "Generic" build:

docker build build/civicrm --build-arg CIVICRM_VERSION=6.20.0 --build-arg PHP_VERSION=8.4 -t mjw-civicrm-6.20.0

## Our build:

So actually using "mjw" branch here: https://github.com/mjwconsult/civicrm-docker/tree/mjw

MJW images are built from tarballs on `res.mjw.pt` instead of `download.civicrm.org`, for both amd64 and arm64 so the same tags run on x86 and Graviton hosts. `build.php` builds and pushes the whole set in one go.

### One-time builder setup

The default `docker` builder can't produce multi-platform images, so create a `docker-container` builder once, from the repository root:

```
docker buildx create --name mjw-multi --driver docker-container --driver-opt network=host \
  --buildkitd-config buildkitd.toml --bootstrap
docker run --privileged --rm tonistiigi/binfmt --install all
```

- `tonistiigi/binfmt` registers QEMU so the host can build the other architecture. Compiling the PECL extensions under emulation is slow; a native node added with `docker buildx create --append --name mjw-multi <endpoint>` avoids it.
- `network=host` gives the builder the host's `/etc/hosts`. On d1 that carries the loopback pin for `dockerhub.mjw.pt`; without it pushes go out and back in through Traefik, and the request rate gets d1 banned by CrowdSec.
- `buildkitd.toml` points build steps at the AWS VPC resolver (the VPC's base address + 2: 172.31.0.2 in the default VPC). The host's `/etc/resolv.conf` lists only systemd-resolved's 127.0.0.53, which BuildKit replaces with Google DNS, and the hosts' security groups don't allow outbound DNS. The builder reads it once, when it is created, so after changing the file `docker buildx rm mjw-multi` and create it again.

### Building

Always give the CiviCRM version and both platforms. Everything except Drupal 7 is built on PHP 8.4, including `drupal-base`; build `drupal7-base` separately (see [Drupal 7](#drupal-7)):

```
./build.php --civicrm-version=6.20.0 \
  --download-prefix=https://res.mjw.pt/dl/mjw \
  --image-prefix=dockerhub.mjw.pt \
  --image-filter=common-base,civicrm-base,civicrm,wordpress-base,wordpress,civicrm-wordpress,civicrm-wordpress-unoconv,drupal-base \
  --php-version=8.4 \
  --builder=mjw-multi \
  --platform=linux/amd64,linux/arm64
```

- `--image-filter` lists every image except `drupal7-base`; add any new `build/` directory to it.
- Each image gets its own archive flavour, eg. `https://res.mjw.pt/dl/mjwcivicrm-6.20.0-standalone.tar.gz` for standalone and `https://res.mjw.pt/dl/mjwcivicrm-6.20.0-wordpress.zip` for WordPress. Without `--civicrm-version`, `build.php` builds whatever latest.civicrm.org reports as stable, which may not have an MJW tarball yet.
- Each tag becomes a manifest list and every host pulls its own architecture.
- `--php-version` accepts a list, eg. `8.3,8.4`. Add `--dry-run` to see the `docker build` commands without running them, and `--image-filter=<dir>,<dir>` to build only some images (the `build/` directory names).
- Don't add `--skip-push`. A `docker-container` builder doesn't load images into the local Docker image store, and each image's `FROM` pulls its parent from `--image-prefix`, so the chain only works when every image is pushed as it is built.
- `--image-prefix` sets both where each image's `FROM` pulls its base from and where the built image is tagged and pushed, so the whole chain stays on one registry. This replaces the older split where bases went to `localhost:5000` but were pulled from Docker Hub.

Note the image names differ from `buildandpublish.sh`: the version is in the tag rather than the name, so `localhost:5000/mjw-civicrm-6.20.0` becomes `dockerhub.mjw.pt/civicrm:6.20.0-php8.4`, with `:6.20-php8.4` tracking the series. Compose files referencing the old names need updating.

### Drupal 7

`drupal7-base` needs PHP 8.3. Like `drupal-base` it has no CiviCRM in it (Drupal sites bring their own, see [DRUPAL.md](DRUPAL.md)), so it is tagged by PHP version only:

```
./build.php --civicrm-version=6.20.0 \
  --image-filter=common-base,drupal7-base \
  --image-prefix=dockerhub.mjw.pt \
  --php-version=8.3 \
  --builder=mjw-multi \
  --platform=linux/amd64,linux/arm64
```

## Manual builds

To build an updated image by hand:

```
docker pull php:8.4-apache-trixie
docker build build/common-base --build-arg IMAGE_TAG=8.4-apache-trixie -t localhost:5000/common-base
docker push localhost:5000/common-base
docker build build/civicrm-base -t localhost:5000/civicrm-base
docker push localhost:5000/civicrm-base
```

For Standalone:

```
docker build \
  --build-arg IMAGE_PREFIX=dockerhub.mjw.pt \
  --build-arg PHP_VERSION=8.4 \
  --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-6.20.0-standalone.tar.gz" \
  build/civicrm -t localhost:5000/mjw-civicrm-6.20.0
docker push localhost:5000/mjw-civicrm-6.20.0
```

For WordPress:

```
docker build \
  --build-arg IMAGE_PREFIX=dockerhub.mjw.pt \
  --build-arg PHP_VERSION=8.4 \
  --build-arg CIVICRM_DOWNLOAD_URL="https://res.mjw.pt/dl/mjwcivicrm-6.20.0-wordpress.zip" \
  build/civicrm-wordpress -t localhost:5000/mjw-civicrm-wordpress-6.20.0
docker push localhost:5000/mjw-civicrm-wordpress-6.20.0
```

For WordPress (with unoconv): Required for CiviOffice

We build another image on top of mjw-civicrm-wordpress - mjw-civicrm-wordpress-unoconv

which pulls in the unoconv package (and a big stack of packages to support that).

```
docker build --build-arg CIVICRM_VERSION=6.20.0 --build-arg PHP_VERSION=8.4 build/civicrm-wordpress-unoconv -t localhost:5000/mjw-civicrm-wordpress-unoconv-6.20.0
docker push localhost:5000/mjw-civicrm-wordpress-unoconv-6.20.0
```
