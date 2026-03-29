# nextcloud-heic

A Docker-based Nextcloud setup with HEIC/HEIF image preview support powered by [libheif](https://github.com/strukturag/libheif) and ImageMagick.

## Features

- Nextcloud 29 (Apache)
- MariaDB 11 database
- Redis for caching and session storage
- Background job runner (cron)
- HEIC/HEIF thumbnail and preview generation via `imagick` + `libheif`

## Quick Start

1. **Copy the example environment file and set your secrets:**

   ```bash
   cp .env.example .env
   # Edit .env and replace all placeholder values
   ```

2. **Build and start the stack:**

   ```bash
   docker compose up -d --build
   ```

3. **Open Nextcloud** in your browser at `http://localhost:8080` (or the port you configured in `.env`).

## Enable HEIC Previews

After the first login, run the following commands to enable HEIC/HEIF preview generation:

```bash
docker compose exec app php occ config:app:set preview jpeg_quality --value=60
docker compose exec app php occ config:app:set preview max_x --value=2048
docker compose exec app php occ config:app:set preview max_y --value=2048
docker compose exec app php occ config:app:set preview enabledProviders \
  --value='["OC\\Preview\\PNG","OC\\Preview\\JPEG","OC\\Preview\\GIF","OC\\Preview\\BMP","OC\\Preview\\XBitmap","OC\\Preview\\HEIC"]'
```

Alternatively, add the following to your `config/config.php` inside the Nextcloud volume:

```php
'enabledPreviewProviders' => [
    'OC\Preview\PNG',
    'OC\Preview\JPEG',
    'OC\Preview\GIF',
    'OC\Preview\BMP',
    'OC\Preview\XBitmap',
    'OC\Preview\HEIC',
],
```

## Stopping the Stack

```bash
docker compose down
```

To also remove all data volumes:

```bash
docker compose down -v
```

## Environment Variables

See [`.env.example`](.env.example) for all available options and their defaults.