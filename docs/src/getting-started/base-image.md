# Base Image

`dkd-dobberkau/base` is a slim runtime image with PHP-FPM and all required PHP extensions for TYPO3. It does **not** contain TYPO3 itself — you build your project-specific image on top of it.

## Variants

Two variants are available:

| Variant | Ports | Processes | Use Case |
|---------|-------|-----------|----------|
| `-nginx` | 80 | Nginx + PHP-FPM (Supervisor) | Docker Compose, simple deploys |
| `-fpm` | 9000 | PHP-FPM only | Kubernetes, CI, external web server |

## Available Tags

| Tag | PHP | Variant | Description |
|-----|-----|---------|-------------|
| `8.2-nginx` | 8.2 | Nginx | Minimum for TYPO3 v13 |
| `8.2-fpm` | 8.2 | FPM | |
| `8.3-nginx` | 8.3 | Nginx | **Recommended** |
| `8.3-fpm` | 8.3 | FPM | |
| `8.4-nginx` | 8.4 | Nginx | Latest PHP |
| `8.4-fpm` | 8.4 | FPM | |
| `latest` | 8.3 | Nginx | Alias for `8.3-nginx` |

## Usage — Nginx Variant (all-in-one)

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

## Usage — FPM Variant (Kubernetes / external web server)

```dockerfile
FROM ghcr.io/dkd-dobberkau/base:8.3-fpm
COPY --from=build --chown=typo3:typo3 /app /var/www/html
```

Pair with an Nginx, Caddy, or Traefik container as a sidecar or reverse proxy.

## Relationship to DDEV

These images **complement** DDEV — they do not compete with it.

| Use Case | Recommended Tool |
|----------|-----------------|
| Local development | **DDEV** |
| Team development | **DDEV** |
| CI/CD pipelines | **dkd-dobberkau/base** (fpm variant) |
| Staging & production | **dkd-dobberkau/base** (with your project) |
| Kubernetes / Cloud | **dkd-dobberkau/base** (fpm variant) + Helm Charts |
| Demo & evaluation | **dkd-dobberkau/demo** |
| TYPO3 Core contribution | **dkd-dobberkau/contrib** |
