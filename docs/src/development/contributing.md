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

## Project Structure

```
.
├── Dockerfile.base              # Base image (Debian Bookworm + PHP-FPM)
├── Dockerfile.demo              # Demo image (TYPO3 pre-installed)
├── Dockerfile.contrib           # Contrib image (Core development)
├── Makefile                     # Build and test commands
├── docker-compose.demo.yml      # Demo stack (MariaDB + Redis + TYPO3)
├── docker-compose.prod.yml      # Production template (Traefik + SSL)
├── docker-compose.contrib.yml   # Core contribution stack
├── base/
│   ├── config/nginx/            # Nginx configuration
│   ├── config/php/              # PHP ini and FPM pool config
│   ├── config/supervisor/       # Supervisord config
│   ├── config/typo3/            # TYPO3 additional.php (env mapping)
│   └── docker-entrypoint.sh     # Entrypoint with env var substitution
├── demo/
│   ├── config/sites/main/       # TYPO3 site configuration
│   └── setup-demo.sh            # Demo setup script
├── docs/                        # MDBook documentation (this site)
└── .github/workflows/build.yml  # CI/CD pipeline
```

## Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-change`)
3. Make your changes
4. Run tests (`make test`)
5. Commit with a descriptive message
6. Push and open a Pull Request

## PR Guidelines

- Keep changes focused — one feature or fix per PR
- Update documentation if behavior changes
- Ensure `make test` passes
- Test with at least one PHP version locally

## Quick Verification

```bash
# Build and test everything
make build-all
make test
make test-fpm
```
