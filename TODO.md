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
- [x] Production Compose — docker-compose.prod.yml mit Traefik SSL als Template
- [x] Mailpit — Mail-Testing im Demo-Setup (SMTP + Web-UI)
- [x] TYPO3 Introduction Package als Demo-Content Option (demo:13-intro Tags)
- [ ] S3/Garage Storage — FAL-Driver fuer S3-kompatiblen Object Storage (fileadmin auf S3/Garage statt lokalem Volume)
- [ ] PHP 8.5 Support — sobald Sury-Pakete verfuegbar

## Deployment

- [x] Traefik Reverse-Proxy mit SSL (integriert in docker-compose.prod.yml)
- [ ] Kubernetes Helm Chart
- [x] GHCR Publishing — Images in die GitHub Container Registry pushen
- [ ] Docker Hub Mirror — offizielle typo3/ Images

## "Contrib"
- [x] Basis-Framework mit docker-compose und Dockerfile
- [x] Basis-Init Script mit GIT repo und composer install
- [ ] Basis-Setup für nutzbaren "Core"
- [ ] basis .htaccess rüberkopieren aus GIT
- [ ] bei neustarten des images alle tasks (cache clear, extension setup, cache warmup ordentlich ausführen)
- [ ] Xdebug mit einbauen, standardmäßig deaktiviert. Via ENV args in docker compose nutzbar machen:
       XDEBUG_MODE: debug
       XDEBUG_CONFIG: client_host=host client_port=9003
       XDEBUG_SESSION: 1
- [ ] Git my.typo3.org push replacement für typo3core/.git/config einbauen (git config --get remote.origin.pushurl)
- [ ] Git commit template einbauen (typo3core/Build/git-hooks/commit-msg) 
- [ ] Git commit hooks einbauen (typo3core/Build/git-hooks/unix+mac/pre-commit)
- [ ] Ausprobieren ob runTests.sh ordentlich lauffähig ist ("docker compose exec web typo3core/Build/Scripts/runTests.sh -s ...")
- [ ] Build erstellen und "community" docker-compose.contribution.yml (mit image statt dockerfile!) erzeugen
- [ ] Makefile abgleichen
- [ ] GuitHub actions abgleichen
- [ ] Doku ergänzen:
  - Mission statement: Einfache Usage, zero dependencies ausser Docker compose (und ggf. GIT wenn man pushen will). Kein TDK, kein host-side PHP, kein DDEV.
  - einfache usage, erklärung docker-compose file, mounts
  - wie dinge wirklich in gerrit committen können (git setup)
  - wie git reset / commit / push durchführen
  - wie container / state resetten
  - wie andere ports nutzen
  - wie auf DB zugreifen mit adminer, sequelace, heidisql
  - wie ports exposen für netzwerk usage
  - wie eigene composer packages requiren (docker compose exec)

## Dokumentation

- [x] README aktualisieren — Debian, FPM-Variante, Env Mapping, Build-Anleitung
- [x] SECURITY.md — Hinweise zu Credentials, Volumes, Netzwerk
- [x] CONTRIBUTING.md — Build-Anleitung, Entwickler-Setup
