# TODO — TYPO3 Docker Images

## Done

- [x] Base image (Debian Bookworm + Sury PHP + FPM/Nginx Varianten)
- [x] FPM-only Variante — PHP-FPM ohne Nginx (Kubernetes, eigener Webserver)
- [x] Alpine → Debian Bookworm Migration — Sury PHP Pakete statt docker-php-ext-install
- [x] Deklaratives Env-to-Config Mapping (additional.php)
- [x] Demo image (TYPO3 13 LTS + TYPO3 14)
- [x] Redis cache backend (hash, pages, rootline)
- [x] Random admin password generation + credentials file
- [x] Healthcheck via /healthz endpoint
- [x] Credentials aus Dockerfiles entfernt
- [x] Smoke tests (PHP extensions, Composer, Nginx, GraphicsMagick)
- [x] Composer via multi-stage COPY (COPY --from=composer:2.9)

## Testing & Quality

- [x] `make test` + `make test-fpm` nach allen Refactorings laufen lassen
- [x] GitHub Actions CI/CD — automatische Builds + Tests bei Push/PR
- [x] Integration-Tests — Demo hochfahren, Login prüfen, Health-Endpoint testen
- [x] Trivy Security-Scan — Vulnerability Scan der gebauten Images
- [x] Hadolint — Dockerfile Linting in die Pipeline einbauen
- [x] GHA-Cache optimieren — Registry-Cache für Multi-Arch Builds
- [x] Build-Zeit < 10 Min — Base Images in ~40s pro Variante

## Features

- [x] Multi-Arch Builds (linux/amd64 + linux/arm64) — Apple Silicon + Linux Server
- [ ] PostgreSQL Compose-Variante — Base Image hat bereits pdo_pgsql
- [ ] Production Compose — ohne Demo-Setup, fuer echte Projekte mit eigenem Code
- [x] Mailpit — Mail-Testing im Demo-Setup (SMTP + Web-UI)
- [ ] TYPO3 Introduction Package als Demo-Content Option
- [ ] PHP 8.5 Support — sobald Sury-Pakete verfuegbar

## Deployment

- [ ] Traefik Reverse-Proxy mit SSL (docker-compose.prod.yml)
- [ ] Kubernetes Helm Chart
- [x] GHCR Publishing — Images in die GitHub Container Registry pushen
- [ ] Docker Hub Mirror — offizielle typo3/ Images

## Dokumentation

- [x] README aktualisieren — Debian, FPM-Variante, Env Mapping, Build-Anleitung
- [x] SECURITY.md — Hinweise zu Credentials, Volumes, Netzwerk
- [x] CONTRIBUTING.md — Build-Anleitung, Entwickler-Setup
