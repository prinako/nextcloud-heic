FROM php:8.5.12-fpm-trixie AS patched-php

FROM nextcloud:34.0.4-fpm

# Keep the Nextcloud image intact while replacing its vulnerable PHP 8.5.11
# runtime with the ABI-compatible 8.5.12 security release.
COPY --from=patched-php /usr/local/ /usr/local/
ENV PHP_VERSION=8.5.12

RUN apt-get update && apt-get install -y --no-install-recommends \
    libheif1 \
    imagemagick \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*
