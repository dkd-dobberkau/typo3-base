# Security

## Supported Versions

| Image | Tag | Supported |
|-------|-----|-----------|
| dkd-dobberkau/base | 8.3-nginx | Yes |
| dkd-dobberkau/base | 8.4-nginx | Yes |
| dkd-dobberkau/base | 8.2-nginx | Yes |
| dkd-dobberkau/demo | 13 | Yes |
| dkd-dobberkau/demo | 14 | Yes |

## Reporting a Vulnerability

If you discover a security vulnerability in these Docker images, please report it responsibly:

1. **Do not** open a public GitHub issue
2. Email the maintainers with details of the vulnerability
3. Include steps to reproduce and potential impact

## Security Practices

### Credentials

- The demo image generates **random admin passwords** on first run
- Credentials are stored in `/var/www/html/var/credentials.txt` (mode 600, owned by `typo3` user)
- **Never** use the demo image in production without changing credentials
- Set `TYPO3_SETUP_ADMIN_PASSWORD` via environment variable for deterministic passwords

### Container Security

- Images run as non-root user `typo3` (UID/GID 1000)
- Supervisor manages Nginx and PHP-FPM as child processes
- No SSH or remote shell access included
- Debian Bookworm slim base reduces attack surface

### Network

- Only port 80 is exposed by the nginx base image (port 9000 for fpm)
- Use a reverse proxy (Traefik, Nginx) with TLS termination in production
- Database and Redis connections should stay on internal Docker networks
- `docker-compose.demo.yml` uses an isolated network by default

### Volumes

- Mount `/var/www/html/var` to persist logs and sessions
- Mount `/var/www/html/public/fileadmin` for editor uploads
- Avoid exposing volume mounts directly to the host in production

### Updates

- Images are rebuilt weekly (Monday 04:00 UTC) to include security patches
- Trivy vulnerability scans run on every push to main
- Pin specific image tags in production (`8.3-nginx`, not `latest`)

### Database

- Use strong passwords for `TYPO3_DB_PASSWORD` and `MARIADB_ROOT_PASSWORD`
- Do not expose database ports to the host in production
- Use dedicated database users with minimal privileges
