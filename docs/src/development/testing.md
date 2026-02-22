# Testing

## Smoke Tests

Run smoke tests to verify the base image is correctly built:

```bash
# Test nginx variant
make test

# Test fpm variant
make test-fpm

# Test specific PHP version
make test PHP_VERSION=8.4
make test-fpm PHP_VERSION=8.4
```

Smoke tests verify:
- All required PHP extensions are loaded
- Composer is installed and working
- Nginx configuration is valid (nginx variant)
- GraphicsMagick is available

## Integration Tests

Integration tests start the full demo stack and verify end-to-end functionality:

```bash
make demo
# Then manually verify:
# - Frontend responds at http://localhost:8080
# - Backend login works at http://localhost:8080/typo3
# - Health endpoint at http://localhost:8080/healthz
```

## CI/CD Pipeline

Every push and PR triggers the GitHub Actions pipeline:

1. **lint** — Hadolint checks on all Dockerfiles
2. **build-base** — Builds base images for PHP 8.2, 8.3, 8.4 (linux/amd64 + linux/arm64)
3. **test** — Smoke tests for nginx and fpm variants
4. **integration-test** — Full stack test (MariaDB + Redis + TYPO3 setup + HTTP checks)
5. **build-demo** — Builds demo images for TYPO3 13 + 14 with multiple PHP versions
6. **build-demo-intro** — Builds demo images with Introduction Package
7. **build-contrib** — Builds contrib images for PHP 8.2, 8.3, 8.4
8. **security-scan** — Trivy vulnerability scan (on push to main only)

The pipeline builds multi-architecture images (amd64 + arm64) and pushes to GHCR on main branch. Pull requests build and test but do not push.

### Weekly Rebuilds

Images are automatically rebuilt every Monday at 04:00 UTC to include the latest security patches from Debian and PHP.
