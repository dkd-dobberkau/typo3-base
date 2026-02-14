# Quick Start

Get a fully working TYPO3 demo running in minutes.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with Docker Compose

## Start the Demo

```bash
docker compose -f docker-compose.demo.yml up
```

This starts TYPO3 with MariaDB, Redis, and Mailpit.

| Service | URL |
|---------|-----|
| Frontend | [http://localhost:8080](http://localhost:8080) |
| Backend | [http://localhost:8080/typo3](http://localhost:8080/typo3) |
| Mailpit | [http://localhost:8025](http://localhost:8025) |

## Admin Credentials

Admin credentials are randomly generated on first run. Check the setup container logs:

```bash
docker compose -f docker-compose.demo.yml logs setup
```

Or set your own via environment variables:

```bash
TYPO3_SETUP_ADMIN_USERNAME=admin \
TYPO3_SETUP_ADMIN_PASSWORD=MySecurePass1! \
docker compose -f docker-compose.demo.yml up
```

## Stop the Demo

```bash
docker compose -f docker-compose.demo.yml down
```

Add `-v` to also remove the database volume and start fresh next time.

## Next Steps

- [Base Image](base-image.md) — Build your own project image for production
- [Demo Image](demo-image.md) — Learn about demo variants and tags
- [Environment Variables](../guides/environment-vars.md) — Configure TYPO3 via environment
