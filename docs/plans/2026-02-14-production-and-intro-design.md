# Design: Production Compose, Traefik SSL, Introduction Package

Date: 2026-02-14

## 1. Production Compose Template

A `docker-compose.prod.yml` + `.env.prod.example` that users copy into their own TYPO3 project.

### Services

- **traefik** — Traefik v3 reverse proxy with automatic Let's Encrypt SSL (TLS challenge), HTTP-to-HTTPS redirect, dashboard disabled
- **web** — Base image (nginx variant), user mounts their own TYPO3 code, Traefik labels for routing
- **db** — MariaDB 11 with production charset/collation
- **redis** — Cache backend

### Configuration via `.env.prod.example`

- `DOMAIN` — production domain (e.g. `typo3.example.com`)
- `ACME_EMAIL` — email for Let's Encrypt certificate registration
- `PHP_VERSION` — PHP version for base image
- `TYPO3_DB_*` — database credentials
- `TYPO3_CONTEXT`, `TYPO3_ENCRYPTION_KEY`, `TYPO3_TRUSTED_HOSTS_PATTERN`
- `PHP_MEMORY_LIMIT`, `PHP_MAX_EXECUTION_TIME`, etc.

### Volumes

Named volumes: `db-data`, `redis-data`, `traefik-certs` (Let's Encrypt certificates)
Bind mounts: user's TYPO3 project code

### Files

- `docker-compose.prod.yml` — complete stack with Traefik integrated
- `.env.prod.example` — all configurable values with sensible defaults and comments

## 2. Introduction Package (Demo Variant)

Add the TYPO3 Introduction Package as an optional demo content variant.

### Approach

Add `TYPO3_DEMO_CONTENT` build argument to `Dockerfile.demo`:
- Empty (default): standard empty TYPO3 installation (existing behavior)
- `introduction`: runs `composer require typo3/cms-introduction` during build

### Tags

New tags alongside existing demo tags:
- `demo:13-intro`, `demo:13-intro-php8.2`, `demo:13-intro-php8.3`, etc.
- `demo:14-intro`, `demo:14-intro-php8.3`, `demo:14-intro-php8.4`

### Build changes

- `Dockerfile.demo`: conditional `composer require` based on `TYPO3_DEMO_CONTENT` ARG
- `setup-demo.sh`: no changes needed — `extension:setup` already handles installed extensions
- `Makefile`: new `build-demo-intro` target
- CI pipeline: extend demo matrix with `demo-content` dimension

## Implementation Order

1. Production Compose + Traefik (independent, no code changes to existing images)
2. Introduction Package (changes Dockerfile.demo, Makefile, CI pipeline)
