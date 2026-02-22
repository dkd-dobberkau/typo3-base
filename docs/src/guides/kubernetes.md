# Kubernetes

> **Coming Soon** — A Helm chart is planned. See the [project roadmap](https://github.com/dkd-dobberkau/typo3-base/blob/main/TODO.md) for progress.

## Recommended Setup

For Kubernetes deployments, use the **FPM variant** of the base image:

```dockerfile
FROM ghcr.io/dkd-dobberkau/base:8.3-fpm
COPY --from=build --chown=typo3:typo3 /app /var/www/html
```

The FPM variant exposes port 9000 and runs PHP-FPM only — pair it with an Nginx or Caddy sidecar container for serving static files and proxying PHP requests.

## Key Considerations

- Use the `-fpm` variant (no bundled web server)
- Run Nginx as a sidecar container in the same pod
- Mount `fileadmin` and `var` as persistent volumes (PVC)
- Use Kubernetes Secrets for database credentials and encryption keys
- Set all [environment variables](environment-vars.md) via ConfigMaps or Secrets
- The image runs as non-root user `typo3` (UID 1000) — configure `securityContext` accordingly

## Health Checks

The FPM variant checks for a running `php-fpm` process. For Kubernetes liveness/readiness probes, configure a TCP check on port 9000 or use the Nginx sidecar's health endpoint.
