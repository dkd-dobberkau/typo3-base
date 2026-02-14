# TYPO3 Official Docker Images

[![Build and Push Docker Images](https://github.com/dkd-dobberkau/typo3-base/actions/workflows/build.yml/badge.svg)](https://github.com/dkd-dobberkau/typo3-base/actions/workflows/build.yml)

Production-ready Docker images for TYPO3 CMS — Debian Bookworm + PHP (Sury packages). Multi-architecture support: `linux/amd64` + `linux/arm64` (Apple Silicon).

**[Full Documentation](https://dkd-dobberkau.github.io/typo3-base/)**

## Images

| Image | Purpose | Quick Start |
|-------|---------|-------------|
| `dkd-dobberkau/base` | Slim runtime — build your project on top | [Base Image Docs](https://dkd-dobberkau.github.io/typo3-base/getting-started/base-image.html) |
| `dkd-dobberkau/demo` | Pre-installed TYPO3 for demos | `docker compose -f docker-compose.demo.yml up` |
| `dkd-dobberkau/contrib` | TYPO3 Core contribution environment | [Contrib Docs](https://dkd-dobberkau.github.io/typo3-base/guides/core-contribution.html) |

## Quick Start

```bash
docker compose -f docker-compose.demo.yml up
```

| Service | URL |
|---------|-----|
| Frontend | http://localhost:8080 |
| Backend | http://localhost:8080/typo3 |
| Mailpit | http://localhost:8025 |

Admin credentials are randomly generated on first run — check `docker compose -f docker-compose.demo.yml logs setup`.

## Architecture

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

## Building Locally

```bash
make build-all    # Build everything (base + demo + contrib)
make test         # Run smoke tests (nginx variant)
make test-fpm     # Run smoke tests (fpm variant)
make demo         # Build and start demo
```

See the [full documentation](https://dkd-dobberkau.github.io/typo3-base/) for environment variables, production deployment with Traefik SSL, Kubernetes guides, and more.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for build instructions and development setup.

Based on prior work by Martin Helmich (`docker-typo3`, `docker-typo3-cloud`). Environment mapping pattern inspired by [Andre Spindler's TYPO3 distribution template](https://gitlab.com/gitlab-org/project-templates/typo3-distribution).

## License

GPL-3.0-or-later
