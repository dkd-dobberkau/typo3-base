# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Official TYPO3 Docker images repository. Produces two images:

- **`typo3/base`** — Slim runtime image (Alpine + Nginx + PHP-FPM + extensions). Contains no TYPO3 code — users build their project image on top of it.
- **`typo3/demo`** — Pre-installed TYPO3 for demos/evaluation, built on top of `typo3/base`.

Registry: `ghcr.io/typo3`

## Build Commands

```bash
# Build base image (default PHP 8.3)
make build-base

# Build demo image (requires base)
make build-demo

# Build both
make build-all

# Build with specific versions
make build-base PHP_VERSION=8.4
make build-demo PHP_VERSION=8.4 TYPO3_VERSION=14

# Build full matrix (all PHP × TYPO3 combinations)
make matrix
```

## Run & Test

```bash
# Build and start demo
make demo

# Start demo without rebuild
make up

# Stop demo
make down

# Run smoke tests (verifies PHP extensions, Composer, Nginx, GraphicsMagick)
make test

# Test specific PHP version
make test PHP_VERSION=8.4

# Cleanup images and volumes
make clean
```

Demo runs at `http://localhost:8080`, backend at `/typo3` (admin / Password1!).

## Architecture

The build has a two-layer dependency:

```
Dockerfile.base  →  typo3/base:{PHP_VERSION}-nginx
                         ↓
Dockerfile.demo  →  typo3/demo:{TYPO3_VERSION}  (FROM base, installs TYPO3 via Composer)
```

### Key directories (need to be extracted from `typo3-docker.tar.gz`)

| Path | Purpose |
|------|---------|
| `base/config/php/` | PHP ini files (`typo3.ini`, `opcache.ini`) and FPM pool config |
| `base/config/nginx/` | Nginx config (`nginx.conf` main config, `typo3.conf` TYPO3 vhost) |
| `base/config/supervisor/` | Supervisord config (runs Nginx + PHP-FPM together) |
| `base/docker-entrypoint.sh` | Entrypoint script — handles env var substitution at runtime |
| `demo/setup-demo.sh` | Demo setup script (TYPO3 install/setup) |
| `demo/config/sites/main/` | TYPO3 site configuration for demo |
| `docker-compose.demo.yml` | Compose file for running demo with MariaDB |
| `.github/workflows/build.yml` | CI/CD build pipeline |

### Build variables

| Variable | Default | Used in |
|----------|---------|---------|
| `PHP_VERSION` | `8.3` | Both Dockerfiles, Makefile |
| `TYPO3_VERSION` | `13` | Dockerfile.demo, Makefile |
| `REGISTRY` | `ghcr.io/typo3` | Makefile |
| `HTTP_PORT` | `8080` | Makefile (demo) |

### Base image internals

- Runs as non-root user `typo3` (UID/GID 1000)
- Supervisor manages both Nginx and PHP-FPM processes
- Exposes port 80
- Healthcheck hits `/typo3/install.php` or `/`
- PHP extensions: gd, intl, mbstring, mysqli, opcache, pdo_mysql, pdo_pgsql, pgsql, xml, zip, apcu, redis
- Includes Composer and GraphicsMagick

### Demo image build

Multi-stage: uses the base image to run `composer create-project typo3/cms-base-distribution`, then copies the result into a clean base image layer.

## Important Notes

- The project files referenced by the Dockerfiles (`base/`, `demo/`, `docker-compose*.yml`) currently only exist inside `typo3-docker.tar.gz` — extract it before building.
- `Dockerfile.demo` depends on a pre-built base image (`ghcr.io/typo3/base`). Build base first, or the demo build will pull from the registry.
- The `latest` tag for base maps to `8.3-nginx`; for demo maps to `13`.
