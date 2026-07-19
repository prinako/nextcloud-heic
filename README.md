# nextcloud-heic

Docker image and Compose stack for running Nextcloud with HEIC/HEIF preview
support.

The custom image extends `nextcloud:34.0.1-fpm` and adds the packages Nextcloud
needs to read common HEIC photos, including ImageMagick, FFmpeg, `libheif1`, and
`libheif-dev`.

## Included Services

- Nextcloud application container using `ghcr.io/prinako/nextcloud-heic:main`
- MariaDB 11 database
- Redis cache for locking and performance
- Dedicated Nextcloud cron container
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

Open Nextcloud:

```text
http://localhost:8080
```

If you changed `NEXTCLOUD_PORT`, use that port instead.

## Enable HEIC Previews

After the first install finishes, enable the HEIC preview provider:

```bash
docker compose exec app php occ config:app:set preview jpeg_quality --value=60
docker compose exec app php occ config:system:set preview_max_x --type=integer --value=2048
docker compose exec app php occ config:system:set preview_max_y --type=integer --value=2048
docker compose exec app php occ config:system:set enabledPreviewProviders --type=json \
  --value='["OC\\Preview\\BMP","OC\\Preview\\GIF","OC\\Preview\\JPEG","OC\\Preview\\Krita","OC\\Preview\\MarkDown","OC\\Preview\\MP3","OC\\Preview\\OpenDocument","OC\\Preview\\PNG","OC\\Preview\\TXT","OC\\Preview\\XBitmap","OC\\Preview\\HEIC"]'
```

Upload a `.heic` or `.heif` file and open its folder in Nextcloud. Preview
generation can take a moment while cron processes background jobs.

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
| `NEXTCLOUD_TRUSTED_DOMAINS` | `localhost` | Hostnames allowed by Nextcloud. Add your domain or LAN IP for non-local access. |
| `NEXTCLOUD_PORT` | `8080` | Host port mapped to the Nextcloud app container. |

## Build Locally

The Compose file uses the published image by default:

```yaml
image: ghcr.io/prinako/nextcloud-heic:main
```

To build the image locally:

```bash
docker build -t nextcloud-heic:local .
```

Then update `docker-compose.yml` to use the local tag for both `app` and `cron`:

```yaml
image: nextcloud-heic:local
```

## Common Commands

View containers:

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

Stop the stack and remove stored data:

```bash
docker compose down -v
```

## Troubleshooting

If HEIC previews do not appear:

- Confirm the HEIC provider is configured:

  ```bash
  docker compose exec app php occ config:system:get enabledPreviewProviders
  ```

- Check the app logs:

  ```bash
  docker compose logs app
  ```

- Make sure cron is running:

  ```bash
  docker compose ps cron
  ```

- Re-run the preview configuration commands after upgrades if preview settings
  were reset.

## License

MIT. See [LICENSE](LICENSE).
