ARG PHP_VERSION=7.3
FROM php:${PHP_VERSION}-cli

LABEL maintainer="Julien Langlois"

ENV HOME /tmp

########################
# Install common tools
########################

RUN apt-get update -y \
    && apt-get install -y \
    software-properties-common \
    build-essential \
    apt-utils \
    wget \
    curl \
    git \
    ssh \
    openssh-client \
    bash \
    unzip \
    libzip-dev \
    zlib1g-dev \
    libpng-dev \
    && rm -rf /var/lib/apt/lists/*

########################
# Install Composer
########################

ARG COMPOSER_VERSION=1.8.6

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV PATH "$PATH:/tmp/vendor/bin"

RUN echo "memory_limit=-1" > "$PHP_INI_DIR/conf.d/memory-limit.ini" && echo "date.timezone=${PHP_TIMEZONE:-UTC}" > "$PHP_INI_DIR/conf.d/date_timezone.ini"

RUN docker-php-ext-install zip
RUN docker-php-ext-install gd
RUN docker-php-ext-install bcmath

RUN set -ex \
    && curl -s -f -L -o /tmp/installer.php https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer \
    && php -r " \
    if (!hash_file('SHA384', '/tmp/installer.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { \
    unlink('/tmp/installer.php'); \
    echo 'Integrity check failed, installer is either corrupt or worse.' . PHP_EOL; \
    exit(1); \
    }" \
    && php /tmp/installer.php --no-ansi --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
    && composer --ansi --version --no-interaction \
    && rm -rf /tmp/* /tmp/.htaccess

########################
# Install PHPCS, PHPMD and PHPUnit
########################

ARG PHPUNIT_VERSION=^7.0
ARG PHPCS_VERSION=^3.4
ARG PHPMD_VERSION=^2.6

RUN composer global require phpunit/phpunit ${PHPUNIT_VERSION} && composer global require squizlabs/php_codesniffer ${PHPCS_VERSION} && composer global require phpmd/phpmd ${PHPMD_VERSION}

WORKDIR /var/www/
ENTRYPOINT ["/bin/bash"]
