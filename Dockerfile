ARG PHP_VERSION=7.1
FROM php:${PHP_VERSION}-cli-jessie

LABEL maintainer="Julien Langlois"

ENV HOME /tmp

########################
# Install common tools
########################

RUN echo "deb http://deb.debian.org/debian jessie-backports main contrib non-free" >> /etc/apt/sources.list.d/jessie-backports.list && \
    echo "deb http://deb.debian.org/debian jessie-backports-sloppy main contrib non-free" >> /etc/apt/sources.list.d/jessie-backports.list && \
    apt-get update && apt-get -y -t jessie-backports install \
    curl \
    git \
    subversion \
    mercurial \
    openssh-client \
    openssl \
    bash \
    zlib1g-dev \
    build-essential \
    libssl-dev \
    gnupg \
    unzip \
    zip \
    libpng-dev

########################
# Install Composer
########################

ARG COMPOSER_VERSION=1.7.2

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV PATH "$PATH:/tmp/vendor/bin"

RUN echo "memory_limit=-1" > "$PHP_INI_DIR/conf.d/memory-limit.ini" && echo "date.timezone=${PHP_TIMEZONE:-UTC}" > "$PHP_INI_DIR/conf.d/date_timezone.ini"

RUN docker-php-ext-install zip
RUN docker-php-ext-install gd

RUN set -ex \
    && curl -s -f -L -o /tmp/installer.php https://raw.githubusercontent.com/composer/getcomposer.org/877cb10b101957ef8bbb9d196f711dbb8a011bb4/web/installer \
    && php -r " \
        if (!hash_file('SHA384', '/tmp/installer.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { \
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
ARG PHPCS_VERSION=^3.3
ARG PHPMD_VERSION=^2.6

RUN composer global require phpunit/phpunit ${PHPUNIT_VERSION} && composer global require squizlabs/php_codesniffer ${PHPCS_VERSION} && composer global require phpmd/phpmd ${PHPMD_VERSION}

ENTRYPOINT ["/usr/bin/env"]