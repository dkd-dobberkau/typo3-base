<?php

// =============================================================================
// TYPO3 Docker — Environment-based Configuration
//
// This file maps environment variables to TYPO3 configuration at runtime.
// It is baked into the Docker image and loaded automatically.
//
// To extend: add entries to $configMappings or mount your own additional.php.
//
// Inspired by André Spindler's TYPO3 distribution template:
// https://gitlab.com/gitlab-org/project-templates/typo3-distribution
// =============================================================================

// -----------------------------------------------------------------------------
// Database Connection
// -----------------------------------------------------------------------------
if (getenv('TYPO3_DB_HOST')) {
    $GLOBALS['TYPO3_CONF_VARS'] = array_replace_recursive(
        $GLOBALS['TYPO3_CONF_VARS'] ?? [],
        [
            'DB' => [
                'Connections' => [
                    'Default' => [
                        'charset' => getenv('TYPO3_DB_CHARSET') ?: 'utf8mb4',
                        'dbname' => getenv('TYPO3_DB_NAME') ?: getenv('TYPO3_DB_DBNAME'),
                        'defaultTableOptions' => [
                            'charset' => getenv('TYPO3_DB_CHARSET') ?: 'utf8mb4',
                            'collation' => getenv('TYPO3_DB_COLLATION') ?: 'utf8mb4_unicode_ci',
                        ],
                        'driver' => getenv('TYPO3_DB_DRIVER') ?: 'mysqli',
                        'host' => getenv('TYPO3_DB_HOST'),
                        'password' => getenv('TYPO3_DB_PASSWORD'),
                        'port' => (int)(getenv('TYPO3_DB_PORT') ?: 3306),
                        'user' => getenv('TYPO3_DB_USERNAME'),
                    ],
                ],
            ],
        ]
    );
}

// -----------------------------------------------------------------------------
// Container defaults (reverse proxy, logging)
// -----------------------------------------------------------------------------
$GLOBALS['TYPO3_CONF_VARS']['SYS']['reverseProxyIP'] = '*';
$GLOBALS['TYPO3_CONF_VARS']['SYS']['reverseProxyHeaderMultiValue'] = 'first';
$GLOBALS['TYPO3_CONF_VARS']['SYS']['trustedHostsPattern'] = getenv('TYPO3_TRUSTED_HOSTS_PATTERN') ?: '.*';

// Log warnings and above to stderr (container best practice)
$GLOBALS['TYPO3_CONF_VARS']['LOG']['writerConfiguration'] = [
    \TYPO3\CMS\Core\Log\LogLevel::WARNING => [
        \TYPO3\CMS\Core\Log\Writer\PhpErrorLogWriter::class => [],
    ],
];

// -----------------------------------------------------------------------------
// Declarative env-to-config mapping
//
// Add new environment variables here — one line per setting.
// Values are only applied if the environment variable is set and non-empty.
// -----------------------------------------------------------------------------
$configMappings = [
    'MAIL' => [
        'defaultMailFromAddress' => 'TYPO3_MAIL_FROM_ADDRESS',
        'defaultMailFromName' => 'TYPO3_MAIL_FROM_NAME',
        'defaultMailReplyToAddress' => 'TYPO3_MAIL_REPLY_ADDRESS',
        'defaultMailReplyToName' => 'TYPO3_MAIL_REPLY_NAME',
        'transport' => 'TYPO3_MAIL_TRANSPORT',
        'transport_smtp_server' => 'TYPO3_MAIL_SMTP_SERVER',
        'transport_smtp_username' => 'TYPO3_MAIL_SMTP_USERNAME',
        'transport_smtp_password' => 'TYPO3_MAIL_SMTP_PASSWORD',
    ],
    'SYS' => [
        'displayErrors' => 'TYPO3_DISPLAY_ERRORS',
        'encryptionKey' => 'TYPO3_ENCRYPTION_KEY',
        'exceptionalErrors' => 'TYPO3_EXCEPTIONAL_ERRORS',
        'sitename' => 'TYPO3_PROJECT_NAME',
    ],
    'BE' => [
        'installToolPassword' => 'TYPO3_INSTALLTOOL_PASSWORD',
        'debug' => 'TYPO3_BE_DEBUG',
    ],
    'FE' => [
        'debug' => 'TYPO3_FE_DEBUG',
    ],
    'GFX' => [
        'processor' => 'TYPO3_GFX_PROCESSOR',
        'processor_path' => 'TYPO3_GFX_PROCESSOR_PATH',
        'processor_path_lzw' => 'TYPO3_GFX_PROCESSOR_PATH_LZW',
    ],
];

/**
 * Recursively map environment variables to TYPO3 configuration.
 * Only sets values where the environment variable exists and is non-empty.
 */
function mapEnvToConfig(array $mapping, array &$config): void
{
    foreach ($mapping as $key => $value) {
        if (is_array($value)) {
            $config[$key] ??= [];
            mapEnvToConfig($value, $config[$key]);
            continue;
        }

        $envValue = getenv($value);
        if ($envValue !== false && $envValue !== '') {
            $config[$key] = $envValue;
        }
    }
}

mapEnvToConfig($configMappings, $GLOBALS['TYPO3_CONF_VARS']);

// -----------------------------------------------------------------------------
// Legacy SMTP env vars (SMTP_HOST/SMTP_PORT) — backwards compatible
// Maps to the new TYPO3_MAIL_* format if those aren't set
// -----------------------------------------------------------------------------
if (getenv('SMTP_HOST') && !getenv('TYPO3_MAIL_TRANSPORT')) {
    $GLOBALS['TYPO3_CONF_VARS']['MAIL']['transport'] = 'smtp';
    $GLOBALS['TYPO3_CONF_VARS']['MAIL']['transport_smtp_server'] = getenv('SMTP_HOST') . ':' . (getenv('SMTP_PORT') ?: '587');
    if (getenv('SMTP_USERNAME')) {
        $GLOBALS['TYPO3_CONF_VARS']['MAIL']['transport_smtp_username'] = getenv('SMTP_USERNAME');
        $GLOBALS['TYPO3_CONF_VARS']['MAIL']['transport_smtp_password'] = getenv('SMTP_PASSWORD');
    }
}

// -----------------------------------------------------------------------------
// Redis cache backend (if REDIS_HOST is set)
// -----------------------------------------------------------------------------
if (getenv('REDIS_HOST')) {
    $redisHost = getenv('REDIS_HOST');
    $redisPort = (int)(getenv('REDIS_PORT') ?: 6379);

    $GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations']['hash'] = [
        'backend' => \TYPO3\CMS\Core\Cache\Backend\RedisBackend::class,
        'options' => ['hostname' => $redisHost, 'port' => $redisPort, 'database' => 0],
    ];
    $GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations']['pages'] = [
        'backend' => \TYPO3\CMS\Core\Cache\Backend\RedisBackend::class,
        'options' => ['hostname' => $redisHost, 'port' => $redisPort, 'database' => 1],
    ];
    $GLOBALS['TYPO3_CONF_VARS']['SYS']['caching']['cacheConfigurations']['rootline'] = [
        'backend' => \TYPO3\CMS\Core\Cache\Backend\RedisBackend::class,
        'options' => ['hostname' => $redisHost, 'port' => $redisPort, 'database' => 2],
    ];
}
