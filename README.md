<div align="center">

# Nextcloud HEIC

**A ready-to-run Nextcloud image with HEIC and HEIF preview support.**

[![Nextcloud](https://img.shields.io/badge/Nextcloud-33-0082C9?logo=nextcloud&logoColor=white)](https://nextcloud.com/)
[![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Container](https://img.shields.io/badge/GHCR-nextcloud--heic-181717?logo=github)](https://github.com/prinako/nextcloud-heic/pkgs/container/nextcloud-heic)
[![License](https://img.shields.io/github/license/prinako/nextcloud-heic)](LICENSE)

[Quick start](#quick-start) · [Configuration](#configuration) · [HEIC previews](#enable-heic-previews) · [Troubleshooting](#troubleshooting)

</div>

---

## Overview

Nextcloud HEIC extends the official `nextcloud:33.0.1-fpm` image with the tools required to read and generate previews for modern Apple image formats.

The image adds:

- **ImageMagick** for image processing and preview generation
- **libheif** for HEIC and HEIF decoding
- **FFmpeg** for additional media support
- A complete Compose stack with **MariaDB**, **Redis**, and a dedicated **cron** worker
- Persistent volumes for both application and database data

## Architecture

| Service | Image | Purpose |
| --- | --- | --- |
| `app` | `ghcr.io/prinako/nextcloud-heic:main` | Nextcloud application with HEIC support |
| `cron` | `ghcr.io/prinako/nextcloud-heic:main` | Runs Nextcloud background jobs |
| `db` | `mariadb:11` | Stores Nextcloud application data |
| `redis` | `redis:7-alpine` | Provides caching and transactional file locking |

## Requirements

- [Docker Engine](https://docs.docker.com/engine/install/)
- Docker Compose v2 (`docker compose`)

## Quick start

### 1. Clone the repository

```bash
git clone https://github.com/prinako/nextcloud-heic.git
cd nextcloud-heic
```

### 2. Configure the environment

Create a `.env` file in the project root:

```env
MYSQL_ROOT_PASSWORD=replace-with-a-strong-root-password
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud
MYSQL_PASSWORD=replace-with-a-strong-database-password

NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=replace-with-a-strong-admin-password
NEXTCLOUD_TRUSTED_DOMAINS=localhost
NEXTCLOUD_PORT=8080
```

> [!IMPORTANT]
> Use unique, strong passwords before exposing the service to a network. Do not commit your `.env` file.

### 3. Start the stack

```bash
docker compose up -d
```

Check that the services are running:

```bash
docker compose ps
```

Then open [http://localhost:8080](http://localhost:8080). If you changed `NEXTCLOUD_PORT`, use the configured port instead.

## Enable HEIC previews

After the initial Nextcloud installation is complete, configure the preview provider:

```bash
docker compose exec app php occ config:app:set preview jpeg_quality --value=60
docker compose exec app php occ config:system:set preview_max_x --type=integer --value=2048
docker compose exec app php occ config:system:set preview_max_y --type=integer --value=2048
docker compose exec app php occ config:system:set enabledPreviewProviders --type=json \
  --value='["OC\\Preview\\BMP","OC\\Preview\\GIF","OC\\Preview\\JPEG","OC\\Preview\\Krita","OC\\Preview\\MarkDown","OC\\Preview\\MP3","OC\\Preview\\OpenDocument","OC\\Preview\\PNG","OC\\Preview\\TXT","OC\\Preview\\XBitmap","OC\\Preview\\HEIC"]'
```

Upload a `.heic` or `.heif` image and browse to its folder. The first preview may take a moment while background jobs run.

## Configuration

The Compose stack accepts the following environment variables:

| Variable | Default | Required | Description |
| --- | --- | :---: | --- |
| `MYSQL_ROOT_PASSWORD` | — | Yes | MariaDB root password |
| `MYSQL_DATABASE` | `nextcloud` | No | Nextcloud database name |
| `MYSQL_USER` | `nextcloud` | No | Nextcloud database user |
| `MYSQL_PASSWORD` | — | Yes | Password for `MYSQL_USER` |
| `NEXTCLOUD_ADMIN_USER` | `admin` | No | Initial administrator username |
| `NEXTCLOUD_ADMIN_PASSWORD` | — | Yes | Initial administrator password |
| `NEXTCLOUD_TRUSTED_DOMAINS` | `localhost` | No | Space-separated hostnames or IP addresses trusted by Nextcloud |
| `NEXTCLOUD_PORT` | `8080` | No | Host port exposed by the application service |

For remote access, set `NEXTCLOUD_TRUSTED_DOMAINS` to the domain name or LAN IP used to reach your instance.

## Build locally

Build the custom image from the included Dockerfile:

```bash
docker build -t nextcloud-heic:local .
```

Then replace the image used by both `app` and `cron` in `docker-compose.yml`:

```yaml
image: nextcloud-heic:local
```

Recreate the services after changing the image:

```bash
docker compose up -d --force-recreate
```

## Operations

```bash
# View service status
docker compose ps

# Follow all logs
docker compose logs -f

# Follow application logs only
docker compose logs -f app

# Run an occ command
docker compose exec app php occ status

# Pull updates and recreate the stack
docker compose pull
docker compose up -d

# Stop the stack without deleting data
docker compose down
```

> [!CAUTION]
> `docker compose down -v` permanently deletes the named database and Nextcloud volumes. Back up your data before using it.

## Troubleshooting

### HEIC previews do not appear

Confirm that the provider is enabled:

```bash
docker compose exec app php occ config:system:get enabledPreviewProviders
```

Verify that ImageMagick recognizes HEIC:

```bash
docker compose exec app identify -list format | grep HEIC
```

Check the application and cron services:

```bash
docker compose logs app
docker compose ps cron
```

### Nextcloud reports an untrusted domain

Add the hostname or IP address to `NEXTCLOUD_TRUSTED_DOMAINS` in `.env`, then recreate the application container:

```bash
docker compose up -d --force-recreate app
```

### Inspect the Nextcloud installation

```bash
docker compose exec app php occ status
docker compose exec app php occ config:list system
```

## Updating

Pull the newest published image and recreate the services:

```bash
docker compose pull
docker compose up -d
```

Back up the database and Nextcloud volume before major upgrades. Review the official [Nextcloud upgrade documentation](https://docs.nextcloud.com/server/latest/admin_manual/maintenance/upgrade.html) when changing major versions.

## Contributing

Issues and pull requests are welcome. When reporting a problem, include the relevant Compose logs, Docker version, and a description of the HEIC or HEIF file that triggered it. Do not include passwords, tokens, or other secrets.

## License

Distributed under the [MIT License](LICENSE).
