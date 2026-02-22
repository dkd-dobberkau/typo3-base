# Building

All build commands are available via `make`. Run `make help` to see all available targets.

## Prerequisites

- Docker (with Buildx)
- GNU Make
- Git

## Build Targets

```bash
# Build base image — nginx variant (default PHP 8.3)
make build-base

# Build base image — fpm-only variant
make build-base-fpm

# Build demo image (requires base nginx variant)
make build-demo

# Build demo image with Introduction Package
make build-demo-intro

# Build contrib image (requires base fpm variant)
make build-contrib

# Build all (nginx + fpm + demo + contrib)
make build-all
```

## Specific Versions

```bash
# Build with specific PHP version
make build-base PHP_VERSION=8.4
make build-base-fpm PHP_VERSION=8.4

# Build with specific TYPO3 version
make build-demo PHP_VERSION=8.4 TYPO3_VERSION=14
make build-demo-intro PHP_VERSION=8.4 TYPO3_VERSION=13
```

## Full Matrix Build

Build all PHP x TYPO3 x variant combinations:

```bash
make matrix
```

This builds base images (nginx + fpm) for PHP 8.2/8.3/8.4, demo images for TYPO3 13/14, introduction package variants, and contrib images.

## Build Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_VERSION` | `8.3` | PHP version for base image |
| `TYPO3_VERSION` | `13` | TYPO3 version for demo image |
| `REGISTRY` | `ghcr.io/dkd-dobberkau` | Container registry |
| `HTTP_PORT` | `8080` | Host port for demo |

## Running the Demo

```bash
# Build and start demo
make demo

# Start demo without rebuild
make up

# Stop demo
make down
```

Demo runs at `http://localhost:8080`, backend at `/typo3`.

## Running the Contrib Environment

```bash
make contrib
```

Opens at `http://localhost:28080`.

## Cleanup

```bash
make clean
```

Removes all built images and volumes.
