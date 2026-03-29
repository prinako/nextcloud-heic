FROM nextcloud:29-apache

# Install HEIC/HEIF support dependencies
RUN apt-get update && apt-get install -y \
    libheif-dev \
    libheif1 \
    imagemagick \
    libmagickcore-6.q16-6-extra \
    && rm -rf /var/lib/apt/lists/*

# Enable the HEIC/HEIF delegate for ImageMagick
RUN sed -i 's/rights="none" pattern="HEIC"/rights="read|write" pattern="HEIC"/' /etc/ImageMagick-6/policy.xml 2>/dev/null || true && \
    sed -i 's/rights="none" pattern="HEIF"/rights="read|write" pattern="HEIF"/' /etc/ImageMagick-6/policy.xml 2>/dev/null || true

# Increase ImageMagick resource limits for larger images
RUN sed -i 's/<policy domain="resource" name="memory" value="[^"]*"\/>/<policy domain="resource" name="memory" value="512MiB"\/>/' /etc/ImageMagick-6/policy.xml 2>/dev/null || true && \
    sed -i 's/<policy domain="resource" name="disk" value="[^"]*"\/>/<policy domain="resource" name="disk" value="2GiB"\/>/' /etc/ImageMagick-6/policy.xml 2>/dev/null || true

# Verify that imagick PHP extension is available (bundled in nextcloud image)
RUN php -m | grep -i imagick || (pecl install imagick && docker-php-ext-enable imagick)
