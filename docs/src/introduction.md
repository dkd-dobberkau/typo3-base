# TYPO3 Docker Images

[![Build and Push Docker Images](https://github.com/dkd-dobberkau/typo3-base/actions/workflows/build.yml/badge.svg)](https://github.com/dkd-dobberkau/typo3-base/actions/workflows/build.yml)

Production-ready Docker images for TYPO3 CMS — Debian Bookworm + PHP (Sury packages).

Multi-architecture support: `linux/amd64` + `linux/arm64` (Apple Silicon).

## Images Overview

| Image | Purpose |
|-------|---------|
| [`dkd-dobberkau/base`](getting-started/base-image.md) | Slim runtime image with PHP-FPM — build your project on top |
| [`dkd-dobberkau/demo`](getting-started/demo-image.md) | Pre-installed TYPO3 for demos and evaluation |
| [`dkd-dobberkau/contrib`](guides/core-contribution.md) | Ready-to-run TYPO3 Core contribution environment |

## Where to Start

- **New to these images?** Start with the [Quick Start](getting-started/quick-start.md) to have a running TYPO3 in minutes.
- **Building a project?** See [Base Image](getting-started/base-image.md) for the production base and [Production Deployment](guides/production-deploy.md) for a full stack with SSL.
- **Contributing to TYPO3 Core?** See [Core Contribution](guides/core-contribution.md).
