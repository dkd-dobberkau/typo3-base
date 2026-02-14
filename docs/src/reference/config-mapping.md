# Config Mapping

The base image includes a declarative mechanism to configure TYPO3 entirely via environment variables. This is implemented in `base/config/typo3/additional.php`.

## How It Works

The `additional.php` file defines a `$configMappings` array that maps environment variable names to TYPO3 configuration paths. At runtime, each environment variable is checked — if set, its value is written into the corresponding TYPO3 configuration key.

This means you can configure database connections, mail transport, cache backends, and more without editing any PHP files.

## The Mapping Array

The mapping uses a nested structure that mirrors TYPO3's configuration hierarchy:

```php
$configMappings = [
    'DB' => [
        'Connections' => [
            'Default' => [
                'host'     => 'TYPO3_DB_HOST',
                'port'     => 'TYPO3_DB_PORT',
                'dbname'   => 'TYPO3_DB_NAME',
                'user'     => 'TYPO3_DB_USERNAME',
                'password' => 'TYPO3_DB_PASSWORD',
                'driver'   => 'TYPO3_DB_DRIVER',
                'charset'  => 'TYPO3_DB_CHARSET',
            ],
        ],
    ],
    'SYS' => [
        'sitename'           => 'TYPO3_PROJECT_NAME',
        'encryptionKey'      => 'TYPO3_ENCRYPTION_KEY',
        'trustedHostsPattern'=> 'TYPO3_TRUSTED_HOSTS_PATTERN',
        'displayErrors'      => 'TYPO3_DISPLAY_ERRORS',
    ],
    // ... more mappings for MAIL, GFX, EXTENSIONS
];
```

## Adding Custom Mappings

To map a new environment variable, extend the `$configMappings` array. For example, to configure an extension setting:

```php
$configMappings = [
    'EXTENSIONS' => [
        'my_extension' => [
            'apiKey'    => 'MY_EXTENSION_API_KEY',
            'debugMode' => 'MY_EXTENSION_DEBUG',
        ],
    ],
    // ... existing mappings
];
```

Then set the environment variable in your `docker-compose.yml` or `.env` file:

```yaml
environment:
  MY_EXTENSION_API_KEY: "your-api-key"
```

## Overriding Entirely

If you need full control, mount your own configuration file:

```yaml
volumes:
  - ./my-additional.php:/var/www/html/config/system/additional.php
```

This replaces the built-in mapping entirely.

## Redis Cache Backend

The Redis cache backend is configured automatically when `REDIS_HOST` is set. It maps TYPO3 cache backends to Redis databases:

| Cache | Redis DB |
|-------|----------|
| `hash` | 0 |
| `pages` | 1 |
| `rootline` | 2 |

See [Environment Variables](../guides/environment-vars.md) for the full list of supported variables.
