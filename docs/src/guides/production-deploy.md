# Production Deployment

Deploy your TYPO3 project with Traefik reverse proxy and automatic Let's Encrypt SSL certificates.

## Overview

The production stack includes:

- **Traefik** — Reverse proxy with automatic HTTPS via Let's Encrypt
- **TYPO3 Web** — Your project image based on the base image
- **MariaDB** — Database with health checks
- **Redis** — Cache backend for TYPO3

## Prerequisites

- A server with Docker and Docker Compose
- A domain name pointing to your server
- Ports 80 and 443 open

## Step 1: Build Your Project Image

Create a `Dockerfile` in your TYPO3 project:

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

## Step 2: Copy Configuration Files

Copy `docker-compose.prod.yml` and `.env.prod.example` from this repository into your project:

```bash
curl -O https://raw.githubusercontent.com/dkd-dobberkau/typo3-base/main/docker-compose.prod.yml
curl -O https://raw.githubusercontent.com/dkd-dobberkau/typo3-base/main/.env.prod.example
```

## Step 3: Configure Environment

```bash
cp .env.prod.example .env
```

Edit `.env` and set at minimum:

```ini
# Your domain (required)
DOMAIN=typo3.example.com

# Let's Encrypt email (required)
ACME_EMAIL=admin@example.com

# Database passwords (change these!)
TYPO3_DB_PASSWORD=your_secure_password
MARIADB_ROOT_PASSWORD=your_root_password

# TYPO3 encryption key (generate via Install Tool or openssl)
TYPO3_ENCRYPTION_KEY=your_encryption_key
```

Generate an encryption key:

```bash
openssl rand -hex 48
```

## Step 4: Uncomment the Build Section

In `docker-compose.prod.yml`, uncomment the `build` section for the `web` service to build from your local Dockerfile:

```yaml
web:
  # image: ghcr.io/dkd-dobberkau/base:${PHP_VERSION:-8.3}-nginx
  build:
    context: .
    dockerfile: Dockerfile
    args:
      PHP_VERSION: "${PHP_VERSION:-8.3}"
```

## Step 5: Start the Stack

```bash
docker compose -f docker-compose.prod.yml up -d
```

Your site will be available at `https://your-domain.com` with auto-renewed SSL.

## Stack Architecture

```
Internet
  │
  ├─ :80  ──→ Traefik ──→ HTTP→HTTPS redirect
  ├─ :443 ──→ Traefik ──→ TYPO3 web (:80 internal)
  │              │
  │              └─ Let's Encrypt TLS challenge
  │
  └─ Internal Docker network:
       ├─ web   → TYPO3 (Nginx + PHP-FPM)
       ├─ db    → MariaDB 11
       └─ redis → Redis 7
```

## Volumes

The production stack uses named volumes for persistent data:

| Volume | Mount Point | Purpose |
|--------|-------------|---------|
| `fileadmin` | `/var/www/html/public/fileadmin` | Editor uploads |
| `typo3var` | `/var/www/html/var` | Cache, logs, sessions |
| `typo3config` | `/var/www/html/config` | Site configuration |
| `db-data` | `/var/lib/mysql` | Database files |
| `redis-data` | `/data` | Redis persistence |
| `traefik-certs` | `/letsencrypt` | SSL certificates |

## Environment Variables

See the full [Environment Variables](environment-vars.md) reference for all available configuration options including mail, PHP tuning, and Redis.
