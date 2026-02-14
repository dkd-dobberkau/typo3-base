# Demo Image

`dkd-dobberkau/demo` is a pre-installed TYPO3 for demos, evaluation, and onboarding. Includes a complete TYPO3 setup ready to start.

## Available Tags

| Tag | TYPO3 | PHP | Description |
|-----|-------|-----|-------------|
| `13` | 13 LTS | 8.3 | **Stable LTS** |
| `13-php8.2` | 13 LTS | 8.2 | |
| `13-php8.4` | 13 LTS | 8.4 | |
| `14` | 14.x | 8.3 | Sprint releases |
| `14-php8.4` | 14.x | 8.4 | |
| `latest` | 13 LTS | 8.3 | Alias for `13` |

## Introduction Package Variant

Tags with `-intro` include the [TYPO3 Introduction Package](https://extensions.typo3.org/extension/introduction) — a full demo site with sample content, pages, and templates.

| Tag | TYPO3 | PHP |
|-----|-------|-----|
| `13-intro` | 13 LTS | 8.3 |
| `13-intro-php8.2` | 13 LTS | 8.2 |
| `13-intro-php8.4` | 13 LTS | 8.4 |
| `14-intro` | 14.x | 8.3 |
| `14-intro-php8.4` | 14.x | 8.4 |

## Quick Start

```bash
docker compose -f docker-compose.demo.yml up
```

| Service | URL |
|---------|-----|
| Frontend | [http://localhost:8080](http://localhost:8080) |
| Backend | [http://localhost:8080/typo3](http://localhost:8080/typo3) |
| Mailpit | [http://localhost:8025](http://localhost:8025) |

## Credentials

Admin credentials are randomly generated on first run. Check the setup container logs:

```bash
docker compose -f docker-compose.demo.yml logs setup
```

Or set your own:

```bash
TYPO3_SETUP_ADMIN_USERNAME=admin \
TYPO3_SETUP_ADMIN_PASSWORD=MySecurePass1! \
docker compose -f docker-compose.demo.yml up
```

## Building Locally

```bash
# Standard demo
make build-demo

# With Introduction Package
make build-demo-intro

# Specific versions
make build-demo PHP_VERSION=8.4 TYPO3_VERSION=14
make build-demo-intro PHP_VERSION=8.4 TYPO3_VERSION=13
```
