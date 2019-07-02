
# Description

This image contains most commons dependency managers used to build php applications:

* Composer
* PHP Code Sniffer (PHPCS)
* PHP Mess Detector (PHPMD)
* PHPUnit

# Build a custom image

To build a custom image with differents versions of libraries you can use Docker build args.

```bash
docker build -t phpwebapp \
    --build-arg PHP_VERSION=7.3 \
    --build-arg COMPOSER_VERSION=1.8.6 \
    --build-arg PHPCS_VERSION=^3.4 \
    --build-arg PHPMD_VERSION=^2.6 \
    --build-arg PHPUNIT_VERSION=^7.0 \
    .
```
