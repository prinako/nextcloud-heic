FROM nextcloud:35.0.3-fpm

RUN apt-get update && apt-get install -y --no-install-recommends \
    libheif1 \
    imagemagick \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*
