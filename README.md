# nextcloud-heic

A small Docker Compose stack for running Nextcloud with HEIC/HEIF preview support.

The published app image includes ImageMagick, FFmpeg, and `libheif` so photos
from iPhones and other HEIC-capable devices can generate previews inside
Nextcloud.

## What's Included

- Nextcloud app container with HEIC/HEIF tooling
- MariaDB 11 for the database
- Redis for caching and file locking support
- A dedicated Nextcloud cron container for background jobs
- Persistent Docker volumes for database and Nextcloud data

## Requirements

- Docker
- Docker Compose v2

## Quick Start

Create a `.env` file in the repository root:

```env
MYSQL_ROOT_PASSWORD=change-this-root-password
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud
MYSQL_PASSWORD=change-this-db-password

NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=change-this-admin-password
NEXTCLOUD_TRUSTED_DOMAINS=localhost
NEXTCLOUD_PORT=8080
```

Start the stack:

```bash
docker compose up -d
```

Open Nextcloud at:

```text
http://localhost:8080
```

If you changed `NEXTCLOUD_PORT`, use that port instead.

## Enable HEIC/HEIF Previews

After the first install completes, enable the HEIC preview provider:

```bash
docker compose exec app php occ config:app:set preview jpeg_quality --value=60
docker compose exec app php occ config:system:set preview_max_x --type=integer --value=2048
docker compose exec app php occ config:system:set preview_max_y --type=integer --value=2048
docker compose exec app php occ config:system:set enabledPreviewProviders --type=json \
  --value='["OC\\Preview\\BMP","OC\\Preview\\GIF","OC\\Preview\\JPEG","OC\\Preview\\Krita","OC\\Preview\\MarkDown","OC\\Preview\\MP3","OC\\Preview\\OpenDocument","OC\\Preview\\PNG","OC\\Preview\\TXT","OC\\Preview\\XBitmap","OC\\Preview\\HEIC"]'
```

Then upload a `.heic` or `.heif` image and open the folder in Nextcloud. The
preview may take a moment to appear while the background job runner catches up.

## Configuration

The Compose file reads these environment variables:

| Variable | Default | Description |
| --- | --- | --- |
| `MYSQL_ROOT_PASSWORD` | required | Root password for MariaDB. |
| `MYSQL_DATABASE` | `nextcloud` | Database name used by Nextcloud. |
| `MYSQL_USER` | `nextcloud` | Database user used by Nextcloud. |
| `MYSQL_PASSWORD` | required | Password for `MYSQL_USER`. |
| `NEXTCLOUD_ADMIN_USER` | `admin` | Initial Nextcloud admin username. |
| `NEXTCLOUD_ADMIN_PASSWORD` | required | Initial Nextcloud admin password. |
| `NEXTCLOUD_TRUSTED_DOMAINS` | `localhost` | Hostnames allowed by Nextcloud. Add your domain or LAN IP here for non-local access. |
| `NEXTCLOUD_PORT` | `8080` | Host port mapped to the Nextcloud web container. |

## Common Commands

View running containers:

```bash
docker compose ps
```

Follow logs:

```bash
docker compose logs -f
```

Run an `occ` command:

```bash
docker compose exec app php occ status
```

Stop the stack:

```bash
docker compose down
```

Stop the stack and remove all stored Nextcloud and database data:

```bash
docker compose down -v
```

## Image

The Compose file uses the published image from GitHub Container Registry:

```yaml
image: ghcr.io/prinako/nextcloud-heic:main
```

The repository also contains a `Dockerfile` for the custom image build.

## Troubleshooting

If HEIC previews do not appear:

- Confirm the app container can see the HEIC preview provider:

  ```bash
  docker compose exec app php occ config:system:get enabledPreviewProviders
  ```

- Check the Nextcloud logs:

  ```bash
  docker compose logs app
  ```

- Make sure cron is running:

  ```bash
  docker compose ps cron
  ```

- Re-run the preview configuration commands after upgrades if preview settings
  are reset.

## License

MIT. See [LICENSE](LICENSE).
