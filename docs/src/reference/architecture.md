# Architecture

## Build Stages

The build uses a multi-stage Dockerfile with selectable targets:

```
debian:bookworm-slim + Sury PHP
         |
    [php-base]  <- shared stage (PHP + extensions + Composer + GraphicsMagick)
     /        \
  [fpm]      [nginx]
:8.3-fpm   :8.3-nginx  <- build targets (--target fpm / --target nginx)
    |         |
    |   Dockerfile.demo    -> dkd-dobberkau/demo:{TYPO3_VERSION}
    |
Dockerfile.contrib -> dkd-dobberkau/contrib:{PHP_VERSION}
```

## Variants

| Variant | Ports | Processes | Use Case |
|---------|-------|-----------|----------|
| `-nginx` | 80 | Nginx + PHP-FPM (Supervisor) | Docker Compose, simple deploys |
| `-fpm` | 9000 | PHP-FPM only | Kubernetes, CI, external web server |

## Key Directories

| Path | Purpose |
|------|---------|
| `base/config/php/` | PHP ini files (`typo3.ini`, `opcache.ini`) and FPM pool config |
| `base/config/nginx/` | Nginx config (`nginx.conf` main, `typo3.conf` TYPO3 vhost) — nginx variant only |
| `base/config/supervisor/` | Supervisord config (Nginx + PHP-FPM) — nginx variant only |
| `base/config/typo3/` | TYPO3 `additional.php` with environment mapping |
| `base/docker-entrypoint.sh` | Entrypoint script — variant-aware, handles env var substitution |
| `demo/setup-demo.sh` | Demo setup script (TYPO3 install/setup) |
| `demo/config/sites/main/` | TYPO3 site configuration for demo |

## Base Image Internals

- **OS**: Debian Bookworm (slim) with Sury PHP repository
- **PHP installation**: Pre-built packages via `apt install` (no compilation)
- Runs as non-root user `typo3` (UID/GID 1000)
- **Nginx variant**: Supervisor manages Nginx + PHP-FPM, exposes port 80, healthcheck at `/healthz`
- **FPM variant**: PHP-FPM only, exposes port 9000, healthcheck via process check
- PHP config paths: `/etc/php/${PHP_VERSION}/fpm/conf.d/` and `/etc/php/${PHP_VERSION}/cli/conf.d/`
- FPM socket: `/run/php/php-fpm.sock`
- FPM binary symlink: `/usr/local/bin/php-fpm` -> `/usr/sbin/php-fpm${PHP_VERSION}`

## Demo Image Build

The demo image uses a two-stage build:

1. **Build stage**: Uses the nginx base image to run `composer create-project typo3/cms-base-distribution`
2. **Final stage**: Copies the built project into a clean base image layer

The optional `TYPO3_DEMO_CONTENT=introduction` build arg adds the Introduction Package during the build stage.

## Build Variables

| Variable | Default | Used in |
|----------|---------|---------|
| `PHP_VERSION` | `8.3` | Both Dockerfiles, Makefile |
| `TYPO3_VERSION` | `13` | Dockerfile.demo, Makefile |
| `TYPO3_DEMO_CONTENT` | `""` | Dockerfile.demo (set to `introduction` for intro variant) |
| `REGISTRY` | `ghcr.io/dkd-dobberkau` | Makefile |
| `HTTP_PORT` | `8080` | Makefile (demo) |
