FROM nextcloud:33-fpm

RUN apt-get update && apt-get install -y \
    libheif1 \
    libheif-dev \
    imagemagick \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*