# Contributing

Contributions are welcome! This guide explains how to set up the development environment and submit changes.

## Prerequisites

- Docker (with Buildx)
- GNU Make
- Git

## Getting Started

```bash
git clone https://github.com/dkd-dobberkau/typo3-base.git
cd typo3-base
```

## Building

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

# Build full matrix (all PHP x TYPO3 combinations)
make matrix
```

## Testing

```bash
# Run smoke tests (PHP extensions, Composer, Nginx, GraphicsMagick)
make test

# Test with specific PHP version
make test PHP_VERSION=8.4

# Start demo and verify manually
make demo
# Open http://localhost:8080
# Check setup logs for admin credentials
```

## Project Structure

```
.
├── Dockerfile.base              # Base image (Alpine + Nginx + PHP-FPM)
├── Dockerfile.demo              # Demo image (TYPO3 pre-installed)
├── Makefile                     # Build and test commands
├── docker-compose.demo.yml      # Demo stack (MariaDB + Redis + TYPO3)
├── docker-compose.yml           # Example for agency projects
├── base/
│   ├── config/nginx/            # Nginx configuration
│   ├── config/php/              # PHP ini and FPM pool config
│   ├── config/supervisor/       # Supervisord config
│   └── docker-entrypoint.sh     # Entrypoint with env var substitution
├── demo/
│   ├── config/sites/main/       # TYPO3 site configuration
│   └── setup-demo.sh            # Demo setup script
└── .github/workflows/build.yml  # CI/CD pipeline
```

## Build Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_VERSION` | `8.3` | PHP version for base image |
| `TYPO3_VERSION` | `13` | TYPO3 version for demo image |
| `REGISTRY` | `ghcr.io/dkd-dobberkau` | Container registry |
| `HTTP_PORT` | `8080` | Host port for demo |

## Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-change`)
3. Make your changes
4. Run tests (`make test`)
5. Commit with a descriptive message
6. Push and open a Pull Request

### PR Guidelines

- Keep changes focused — one feature or fix per PR
- Update documentation if behavior changes
- Ensure `make test` passes
- Test with at least one PHP version locally

## CI/CD Pipeline

Every push and PR triggers the CI pipeline:

1. **build-base** — Builds base images for PHP 8.2, 8.3, 8.4 (linux/amd64 + linux/arm64)
2. **test** — Smoke tests (PHP extensions, Composer, Nginx, GraphicsMagick)
3. **build-demo** — Builds demo images for TYPO3 13 + 14 with multiple PHP versions
4. **integration-test** — Full stack test (MariaDB + Redis + TYPO3 setup + HTTP checks)
5. **security-scan** — Trivy vulnerability scan on pushed images

## License

GPL-3.0-or-later
