# PHP Extensions

All extensions required by TYPO3 are pre-installed in the base image.

## Core Extensions

| Extension | Purpose |
|-----------|---------|
| `gd` | Image processing |
| `intl` | Internationalization |
| `mbstring` | Multi-byte string handling |
| `mysqli` | MySQL/MariaDB driver |
| `opcache` | Bytecode caching |
| `pdo_mysql` | PDO MySQL driver |
| `pdo_pgsql` | PDO PostgreSQL driver |
| `pgsql` | PostgreSQL driver |
| `xml` | XML parsing |
| `zip` | ZIP archive handling |

## Caching Extensions

| Extension | Purpose |
|-----------|---------|
| `apcu` | In-memory key-value cache |
| `redis` | Redis client for cache backends |

## Bundled Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Composer | 2.x | PHP dependency management |
| GraphicsMagick | — | Image processing (GIF, JPEG, PNG, WebP) |
