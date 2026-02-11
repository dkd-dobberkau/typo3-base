# TYPO3 Official Docker Images

[![Build and Push Docker Images](https://github.com/dkd-dobberkau/typo3-base/actions/workflows/build.yml/badge.svg)](https://github.com/dkd-dobberkau/typo3-base/actions/workflows/build.yml)

Production-ready Docker images for TYPO3 CMS — Debian Bookworm + PHP (Sury packages).

Multi-architecture support: `linux/amd64` + `linux/arm64` (Apple Silicon).

## Images

### `dkd-dobberkau/base` — Production Base Image

A slim runtime image with PHP-FPM and all required PHP extensions for TYPO3. It does **not** contain TYPO3 itself — you build your project-specific image on top of it.

Two variants are available:

- **`-nginx`** — PHP-FPM + Nginx + Supervisor (all-in-one, recommended for simple setups)
- **`-fpm`** — PHP-FPM only (bring your own web server, recommended for Kubernetes)

**Available tags:**

| Tag | PHP | Variant | Description |
|-----|-----|---------|-------------|
| `8.2-nginx` | 8.2 | Nginx | Minimum for TYPO3 v13 |
| `8.2-fpm` | 8.2 | FPM | |
| `8.3-nginx` | 8.3 | Nginx | **Recommended** |
| `8.3-fpm` | 8.3 | FPM | |
| `8.4-nginx` | 8.4 | Nginx | Latest PHP |
| `8.4-fpm` | 8.4 | FPM | |
| `latest` | 8.3 | Nginx | Alias for `8.3-nginx` |

**Usage — Nginx variant (all-in-one):**

```dockerfile
# syntax=docker/dockerfile:1
FROM ghcr.io/dkd-dobberkau/base:8.3-nginx AS base
FROM composer:2 AS build

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --optimize-autoloader --no-scripts
COPY . .
RUN composer dump-autoload --optimize --no-dev

FROM base
COPY --from=build --chown=typo3:typo3 /app /var/www/html
```

**Usage — FPM variant (Kubernetes / external web server):**

```dockerfile
FROM ghcr.io/dkd-dobberkau/base:8.3-fpm
COPY --from=build --chown=typo3:typo3 /app /var/www/html
```

Pair with an Nginx, Caddy, or Traefik container as a sidecar or reverse proxy.

### `dkd-dobberkau/demo` — Demo & Evaluation Image

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

Open http://localhost:8080 — Backend at http://localhost:8080/typo3 — Mailpit at http://localhost:8025

Admin credentials are randomly generated on first run. Check the setup container logs:

```bash
docker compose -f docker-compose.demo.yml logs setup
```

Or set your own via environment variables:

```bash
TYPO3_SETUP_ADMIN_USERNAME=admin \
TYPO3_SETUP_ADMIN_PASSWORD=MySecurePass1! \
docker compose -f docker-compose.demo.yml up
```

## Environment Variables

The base image includes a declarative environment-to-config mapping. Set any of the variables below and they are automatically applied to TYPO3 at runtime — no file editing needed.

### Database

| Variable | Default | Description |
|----------|---------|-------------|
| `TYPO3_DB_DRIVER` | `mysqli` | Database driver (`mysqli`, `pdo_mysql`, `pdo_pgsql`) |
| `TYPO3_DB_HOST` | — | Database hostname |
| `TYPO3_DB_PORT` | `3306` | Database port |
| `TYPO3_DB_NAME` | — | Database name |
| `TYPO3_DB_USERNAME` | — | Database user |
| `TYPO3_DB_PASSWORD` | — | Database password |
| `TYPO3_DB_CHARSET` | `utf8mb4` | Database charset |
| `TYPO3_DB_COLLATION` | `utf8mb4_unicode_ci` | Database collation |

### TYPO3

| Variable | Default | Description |
|----------|---------|-------------|
| `TYPO3_CONTEXT` | `Production` | Application context |
| `TYPO3_PROJECT_NAME` | — | Site name (`SYS.sitename`) |
| `TYPO3_ENCRYPTION_KEY` | — | Encryption key (`SYS.encryptionKey`) |
| `TYPO3_TRUSTED_HOSTS_PATTERN` | `.*` | Trusted hosts pattern |
| `TYPO3_DISPLAY_ERRORS` | — | Display errors (`SYS.displayErrors`) |
| `TYPO3_EXCEPTIONAL_ERRORS` | — | Exceptional errors bitmask |
| `TYPO3_INSTALLTOOL_PASSWORD` | — | Install tool password hash |
| `TYPO3_BE_DEBUG` | — | Backend debug mode |
| `TYPO3_FE_DEBUG` | — | Frontend debug mode |
| `TYPO3_SETUP_ADMIN_USERNAME` | `admin` | Initial admin username (demo setup) |
| `TYPO3_SETUP_ADMIN_PASSWORD` | — | Initial admin password (demo setup) |
| `TYPO3_SETUP_ADMIN_EMAIL` | — | Initial admin email (demo setup) |

### Mail

| Variable | Default | Description |
|----------|---------|-------------|
| `TYPO3_MAIL_TRANSPORT` | — | Mail transport (`smtp`, `sendmail`, etc.) |
| `TYPO3_MAIL_SMTP_SERVER` | — | SMTP server (`host:port`) |
| `TYPO3_MAIL_SMTP_USERNAME` | — | SMTP username |
| `TYPO3_MAIL_SMTP_PASSWORD` | — | SMTP password |
| `TYPO3_MAIL_FROM_ADDRESS` | — | Default sender address |
| `TYPO3_MAIL_FROM_NAME` | — | Default sender name |
| `TYPO3_MAIL_REPLY_ADDRESS` | — | Default reply-to address |
| `TYPO3_MAIL_REPLY_NAME` | — | Default reply-to name |

Legacy variables `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` are still supported for backwards compatibility.

### Graphics

| Variable | Default | Description |
|----------|---------|-------------|
| `TYPO3_GFX_PROCESSOR` | — | Image processor (e.g. `GraphicsMagick`) |
| `TYPO3_GFX_PROCESSOR_PATH` | — | Path to processor binary |
| `TYPO3_GFX_PROCESSOR_PATH_LZW` | — | Path to LZW processor binary |

### PHP

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_MEMORY_LIMIT` | `512M` | Memory limit |
| `PHP_MAX_EXECUTION_TIME` | `240` | Max execution time |
| `PHP_UPLOAD_MAX_FILESIZE` | `32M` | Upload max size |
| `PHP_POST_MAX_SIZE` | `32M` | Post max size |
| `PHP_MAX_INPUT_VARS` | `1500` | Max input variables |

### Redis Cache Backend

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_HOST` | — | Redis host (enables Redis cache backend) |
| `REDIS_PORT` | `6379` | Redis port |

When `REDIS_HOST` is set, TYPO3 cache backends (hash, pages, rootline) are automatically configured to use Redis databases 0–2.

### Extending the Config Mapping

The environment mapping is defined in `base/config/typo3/additional.php` using a declarative `$configMappings` array. To add a new env var, simply extend the array:

```php
$configMappings = [
    'EXTENSIONS' => [
        'my_extension' => [
            'apiKey' => 'MY_EXTENSION_API_KEY',
        ],
    ],
    // ... existing mappings
];
```

Or mount your own `config/system/additional.php` to override entirely.

## Architecture

```
debian:bookworm-slim + Sury PHP
         │
    [php-base]  ← shared stage (PHP + extensions + Composer + GraphicsMagick)
     /        \
  [fpm]      [nginx]
:8.3-fpm   :8.3-nginx  ← build targets (--target fpm / --target nginx)
              │
        Dockerfile.demo → dkd-dobberkau/demo:{TYPO3_VERSION}
```

| Variant | Ports | Processes | Use case |
|---------|-------|-----------|----------|
| `-nginx` | 80 | Nginx + PHP-FPM (Supervisor) | Docker Compose, simple deploys |
| `-fpm` | 9000 | PHP-FPM only | Kubernetes, CI, external web server |

## Relationship to DDEV

These images **complement** DDEV — they do not compete with it.

| Use Case | Recommended Tool |
|----------|-----------------|
| Local development | **DDEV** |
| Team development | **DDEV** |
| CI/CD pipelines | **dkd-dobberkau/base** (fpm variant) |
| Demo & evaluation | **dkd-dobberkau/demo** |
| Staging & production | **dkd-dobberkau/base** (with your project) |
| Kubernetes / Cloud | **dkd-dobberkau/base** (fpm variant) + Helm Charts |

## Included PHP Extensions

Core: `gd`, `intl`, `mbstring`, `mysqli`, `opcache`, `pdo_mysql`, `pdo_pgsql`, `pgsql`, `xml`, `zip`

Caching: `apcu`, `redis`

Also included: Composer 2.9, GraphicsMagick

## Volumes

For production deployments, mount these paths:

| Path | Purpose |
|------|---------|
| `/var/www/html/public/fileadmin` | Editor uploads |
| `/var/www/html/var` | Cache, logs, sessions |
| `/var/www/html/config` | Site configuration |

## Building Locally

```bash
# Build base image (nginx variant)
make build-base

# Build base image (fpm variant)
make build-base-fpm

# Build demo image (requires base)
make build-demo

# Build everything
make build-all

# Run smoke tests
make test        # nginx variant
make test-fpm    # fpm variant

# Build with specific versions
make build-base PHP_VERSION=8.4

# Run demo
make demo
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for build instructions and development setup.

Based on prior work by Martin Helmich (`docker-typo3`, `docker-typo3-cloud`).

Environment mapping pattern inspired by [André Spindler's TYPO3 distribution template](https://gitlab.com/gitlab-org/project-templates/typo3-distribution).

## License

GPL-3.0-or-later
