# syntax=docker/dockerfile:1
ARG PHP_VERSION=8.4

# Step 1: Extract official Caddy binary
FROM caddy:2-alpine AS caddy-bin

# Step 2: Build Grav Caddy image
FROM php:${PHP_VERSION}-fpm-alpine

ARG GRAV_VERSION=2.1.2
ENV GRAV_VERSION=${GRAV_VERSION}

LABEL org.opencontainers.image.title="Grav Caddy"
LABEL org.opencontainers.image.description="Ultra-lightweight Grav CMS image powered by Alpine Linux, PHP 8.4-FPM, and Caddy v2 with HTTP/3 support."
LABEL org.opencontainers.image.source="https://github.com/HomelessAvatar/grav-caddy"
LABEL org.opencontainers.image.licenses="MIT"

# Install required runtime & build dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    unzip \
    libzip \
    libzip-dev \
    icu \
    icu-dev \
    freetype \
    freetype-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    libpng \
    libpng-dev \
    libwebp \
    libwebp-dev \
    yaml \
    yaml-dev \
    su-exec \
    tzdata \
    ca-certificates \
    autoconf \
    gcc \
    g++ \
    make \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd zip intl opcache \
    && pecl install yaml \
    && docker-php-ext-enable yaml \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && apk del autoconf gcc g++ make yaml-dev freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev icu-dev libzip-dev \
    && rm -rf /tmp/pear /var/cache/apk/*

# Copy Caddy v2 binary
COPY --from=caddy-bin /usr/bin/caddy /usr/bin/caddy

# Copy configurations
COPY Caddyfile /etc/caddy/Caddyfile
COPY config/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY config/fpm-pool.conf /usr/local/etc/php-fpm.d/zz-custom.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    mkdir -p /var/www/html /etc/caddy /var/log/caddy && \
    chown -R www-data:www-data /var/www/html /var/log/caddy

WORKDIR /var/www/html
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
