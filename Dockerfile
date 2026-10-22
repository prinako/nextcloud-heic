FROM nextcloud:34.0.5-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
    libheif1 \
    imagemagick \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*
