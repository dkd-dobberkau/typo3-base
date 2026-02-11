# TODO — TYPO3 Docker Images

## Done

- [x] Base image (Alpine + Nginx + PHP-FPM + Extensions)
- [x] Demo image (TYPO3 13 LTS + TYPO3 14)
- [x] Redis cache backend (hash, pages, rootline)
- [x] Random admin password generation + credentials file
- [x] Healthcheck via /healthz endpoint
- [x] Credentials aus Dockerfiles entfernt
- [x] Smoke tests (PHP extensions, Composer, Nginx, GraphicsMagick)

## Testing & Quality

- [ ] `make test` nach allen Refactorings laufen lassen
- [ ] GitHub Actions CI/CD — automatische Builds + Tests bei Push/PR
- [ ] Integration-Tests — Demo hochfahren, Login prüfen, Health-Endpoint testen
- [ ] Hadolint / Docker Scout — Dockerfile Linting + Vulnerability Scan

## Features

- [ ] Multi-Arch Builds (linux/amd64 + linux/arm64) — Apple Silicon + Linux Server
- [ ] PostgreSQL Compose-Variante — Base Image hat bereits pdo_pgsql
- [ ] Production Compose — ohne Demo-Setup, fuer echte Projekte mit eigenem Code
- [ ] SMTP/Mailhog Service — Mail-Testing im Demo-Setup
- [ ] TYPO3 Introduction Package als Demo-Content Option

## Deployment

- [ ] Traefik Reverse-Proxy mit SSL (docker-compose.prod.yml)
- [ ] Kubernetes Helm Chart
- [ ] GHCR Publishing — Images in die GitHub Container Registry pushen
- [ ] Docker Hub Mirror — offizielle typo3/ Images

## Dokumentation

- [ ] README aktualisieren — Redis, Zufallspasswort, v14 Support
- [ ] SECURITY.md — Hinweise zu Credentials, Volumes, Netzwerk
- [ ] CONTRIBUTING.md — Build-Anleitung, Entwickler-Setup
