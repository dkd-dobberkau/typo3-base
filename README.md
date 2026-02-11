# TYPO3 Official Docker Images

Production-ready Docker images for TYPO3 CMS — Alpine Linux + Nginx + PHP-FPM.

## Images

### `typo3/base` — Production Base Image

A slim runtime image that provides PHP-FPM, Nginx, and all required PHP extensions for TYPO3. It does **not** contain TYPO3 itself — you build your project-specific image on top of it.

**Available tags:**

| Tag | PHP | Description |
|-----|-----|-------------|
| `8.2-nginx` | 8.2 | Minimum for TYPO3 v13 & v14 |
| `8.3-nginx` | 8.3 | **Recommended** |
| `8.4-nginx` | 8.4 | Latest PHP |
| `latest` | 8.3 | Alias for `8.3-nginx` |

**Usage for your project:**

```dockerfile
# syntax=docker/dockerfile:1
FROM ghcr.io/typo3/base:8.3-nginx AS base
FROM composer:2 AS build

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-scripts
COPY . .
RUN composer dump-autoload --optimize --no-dev

FROM base
COPY --from=build --chown=typo3:typo3 /app /var/www/html
```

### `typo3/demo` — Demo & Evaluation Image

Pre-installed TYPO3 for demos, evaluation, and onboarding. Includes a complete TYPO3 setup ready to start.

**Available tags:**

| Tag | TYPO3 | PHP | Description |
|-----|-------|-----|-------------|
| `13` | 13 LTS | 8.3 | **Stable LTS** |
| `13-php8.2` | 13 LTS | 8.2 | |
| `13-php8.4` | 13 LTS | 8.4 | |
| `14` | 14.x | 8.3 | Sprint releases |
| `14-php8.4` | 14.x | 8.4 | |
| `latest` | 13 LTS | 8.3 | Alias for `13` |

**Quick start:**

```bash
docker compose -f docker-compose.demo.yml up
```

Open http://localhost:8080 — Backend at http://localhost:8080/typo3 (admin / Password1!)

## Environment Variables

### Database

| Variable | Default | Description |
|----------|---------|-------------|
| `TYPO3_DB_DRIVER` | `mysqli` | Database driver (`mysqli`, `pdo_mysql`, `pdo_pgsql`) |
| `TYPO3_DB_HOST` | `db` | Database hostname |
| `TYPO3_DB_PORT` | `3306` | Database port |
| `TYPO3_DB_NAME` | `typo3` | Database name |
| `TYPO3_DB_USERNAME` | `typo3` | Database user |
| `TYPO3_DB_PASSWORD` | — | Database password |

### TYPO3

| Variable | Default | Description |
|----------|---------|-------------|
| `TYPO3_CONTEXT` | `Production` | Application context |
| `TYPO3_BASE_URL` | `http://localhost` | Base URL |
| `TYPO3_SETUP_ADMIN_USERNAME` | `admin` | Initial admin username |
| `TYPO3_SETUP_ADMIN_PASSWORD` | — | Initial admin password |
| `TYPO3_SETUP_ADMIN_EMAIL` | — | Initial admin email |

### PHP

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_MEMORY_LIMIT` | `512M` | Memory limit |
| `PHP_MAX_EXECUTION_TIME` | `240` | Max execution time |
| `PHP_UPLOAD_MAX_FILESIZE` | `32M` | Upload max size |
| `PHP_POST_MAX_SIZE` | `32M` | Post max size |
| `PHP_MAX_INPUT_VARS` | `1500` | Max input variables |

### Optional Services

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_HOST` | — | Redis host (enables Redis cache backend) |
| `REDIS_PORT` | `6379` | Redis port |
| `SMTP_HOST` | — | SMTP host (enables mail transport) |
| `SMTP_PORT` | `587` | SMTP port |
| `SMTP_USERNAME` | — | SMTP username |
| `SMTP_PASSWORD` | — | SMTP password |

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  typo3/base                       │
│  Alpine Linux + Nginx + PHP-FPM + Extensions     │
│  (no TYPO3 code — runtime environment only)      │
└──────────┬────────────────────┬──────────────────┘
           │                    │
    ┌──────▼──────┐     ┌──────▼──────┐
    │ typo3/demo  │     │ Your Image  │
    │ Pre-installed│     │ FROM base   │
    │ TYPO3 + Demo│     │ + your code │
    └─────────────┘     └─────────────┘
```

## Relationship to DDEV

These images **complement** DDEV — they do not compete with it.

| Use Case | Recommended Tool |
|----------|-----------------|
| Local development | **DDEV** |
| Team development | **DDEV** |
| CI/CD pipelines | **typo3/base** |
| Demo & evaluation | **typo3/demo** |
| Staging & production | **typo3/base** (with your project) |
| Kubernetes / Cloud | **typo3/base** + Helm Charts |

## Included PHP Extensions

Core: `gd`, `intl`, `mbstring`, `mysqli`, `opcache`, `pdo_mysql`, `pdo_pgsql`, `pgsql`, `xml`, `zip`

Caching: `apcu`, `redis`

## Volumes

For production deployments, mount these paths:

| Path | Purpose |
|------|---------|
| `/var/www/html/public/fileadmin` | Editor uploads |
| `/var/www/html/var` | Cache, logs, sessions |
| `/var/www/html/config` | Site configuration |

## Building Locally

```bash
# Build base image
docker build -f Dockerfile.base -t typo3/base:8.3-nginx --build-arg PHP_VERSION=8.3 .

# Build demo image (requires base image)
docker build -f Dockerfile.demo -t typo3/demo:13 \
    --build-arg PHP_VERSION=8.3 \
    --build-arg TYPO3_VERSION=13 .

# Run demo
docker compose -f docker-compose.demo.yml up
```

## Contributing

This project is maintained by the TYPO3 Association. Contributions are welcome.

Based on prior work by Martin Helmich (`docker-typo3`, `docker-typo3-cloud`).

## License

GPL-3.0-or-later
