# Environment Variables

The base image includes a declarative environment-to-config mapping. Set any of the variables below and they are automatically applied to TYPO3 at runtime — no file editing needed.

## Database

| Variable | Default | Description |
|----------|---------|-------------|
| `TYPO3_DB_DRIVER` | `mysqli` | Database driver (`mysqli`, `pdo_mysql`, `pdo_pgsql`) |
| `TYPO3_DB_HOST` | — | Database hostname |
| `TYPO3_DB_PORT` | `3306` | Database port |
| `TYPO3_DB_NAME` | — | Database name |
| `TYPO3_DB_USERNAME` | — | Database user |
| `TYPO3_DB_PASSWORD` | — | Database password |
| `TYPO3_DB_CHARSET` | `utf8mb4` | Database charset |
| `TYPO3_DB_COLLATION` | `utf8mb4_unicode_ci` | Database collation |

## TYPO3

| Variable | Default | Description |
|----------|---------|-------------|
| `TYPO3_CONTEXT` | `Production` | Application context |
| `TYPO3_PROJECT_NAME` | — | Site name (`SYS.sitename`) |
| `TYPO3_ENCRYPTION_KEY` | — | Encryption key (`SYS.encryptionKey`) |
| `TYPO3_TRUSTED_HOSTS_PATTERN` | `.*` | Trusted hosts pattern |
| `TYPO3_DISPLAY_ERRORS` | — | Display errors (`SYS.displayErrors`) |
| `TYPO3_EXCEPTIONAL_ERRORS` | — | Exceptional errors bitmask |
| `TYPO3_INSTALLTOOL_PASSWORD` | — | Install tool password hash |
| `TYPO3_BE_DEBUG` | — | Backend debug mode |
| `TYPO3_FE_DEBUG` | — | Frontend debug mode |
| `TYPO3_SETUP_ADMIN_USERNAME` | `admin` | Initial admin username (demo setup) |
| `TYPO3_SETUP_ADMIN_PASSWORD` | — | Initial admin password (demo setup) |
| `TYPO3_SETUP_ADMIN_EMAIL` | — | Initial admin email (demo setup) |

## Mail

| Variable | Default | Description |
|----------|---------|-------------|
| `TYPO3_MAIL_TRANSPORT` | — | Mail transport (`smtp`, `sendmail`, etc.) |
| `TYPO3_MAIL_SMTP_SERVER` | — | SMTP server (`host:port`) |
| `TYPO3_MAIL_SMTP_USERNAME` | — | SMTP username |
| `TYPO3_MAIL_SMTP_PASSWORD` | — | SMTP password |
| `TYPO3_MAIL_FROM_ADDRESS` | — | Default sender address |
| `TYPO3_MAIL_FROM_NAME` | — | Default sender name |
| `TYPO3_MAIL_REPLY_ADDRESS` | — | Default reply-to address |
| `TYPO3_MAIL_REPLY_NAME` | — | Default reply-to name |

Legacy variables `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` are still supported for backwards compatibility.

## Graphics

| Variable | Default | Description |
|----------|---------|-------------|
| `TYPO3_GFX_PROCESSOR` | — | Image processor (e.g. `GraphicsMagick`) |
| `TYPO3_GFX_PROCESSOR_PATH` | — | Path to processor binary |
| `TYPO3_GFX_PROCESSOR_PATH_LZW` | — | Path to LZW processor binary |

## PHP

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_MEMORY_LIMIT` | `512M` | Memory limit |
| `PHP_MAX_EXECUTION_TIME` | `240` | Max execution time |
| `PHP_UPLOAD_MAX_FILESIZE` | `32M` | Upload max size |
| `PHP_POST_MAX_SIZE` | `32M` | Post max size |
| `PHP_MAX_INPUT_VARS` | `1500` | Max input variables |

## Redis Cache Backend

| Variable | Default | Description |
|----------|---------|-------------|
| `REDIS_HOST` | — | Redis host (enables Redis cache backend) |
| `REDIS_PORT` | `6379` | Redis port |

When `REDIS_HOST` is set, TYPO3 cache backends (hash, pages, rootline) are automatically configured to use Redis databases 0-2.

## Extending the Config Mapping

The environment mapping is defined in `base/config/typo3/additional.php` using a declarative `$configMappings` array. To add a new env var, extend the array:

```php
$configMappings = [
    'EXTENSIONS' => [
        'my_extension' => [
            'apiKey' => 'MY_EXTENSION_API_KEY',
        ],
    ],
    // ... existing mappings
];
```

Or mount your own `config/system/additional.php` to override entirely.

See [Config Mapping](../reference/config-mapping.md) for a detailed explanation of the mapping mechanism.
