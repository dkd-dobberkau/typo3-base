#!/bin/sh
set -e

# =============================================================================
# TYPO3 Docker Entrypoint
# Handles environment variable substitution, permissions, and initial setup
# =============================================================================

if command -v nginx > /dev/null 2>&1; then
    VARIANT="Nginx"
else
    VARIANT="FPM-only"
fi

echo "================================================"
echo " TYPO3 Official Docker Image"
echo " PHP $(php -r 'echo PHP_VERSION;') | ${VARIANT} | Debian"
echo "================================================"

# -----------------------------------------------------------------------------
# Startup validation (only when TYPO3 is installed)
# -----------------------------------------------------------------------------
if [ -f /var/www/html/vendor/bin/typo3 ]; then
    TYPO3_CONTEXT="${TYPO3_CONTEXT:-Production}"
    SETTINGS_FILE="/var/www/html/config/system/settings.php"

    # Production context requires an encryption key (via env var or settings.php)
    if [ "$TYPO3_CONTEXT" = "Production" ]; then
        if [ -z "$TYPO3_ENCRYPTION_KEY" ] && [ ! -f "$SETTINGS_FILE" ]; then
            echo "[entrypoint] ERROR: Production context requires either:"
            echo "[entrypoint]   - TYPO3_ENCRYPTION_KEY environment variable, or"
            echo "[entrypoint]   - config/system/settings.php with encryptionKey configured"
            echo "[entrypoint] Set TYPO3_CONTEXT=Development to bypass this check."
            exit 1
        fi
    fi

    # Warn about ephemeral storage for critical directories
    for dir in /var/www/html/public/fileadmin /var/www/html/var; do
        if [ -d "$dir" ] && ! mountpoint -q "$dir" 2>/dev/null; then
            echo "[entrypoint] WARNING: $dir is not on a persistent volume."
            echo "[entrypoint]          Data will be lost when the container is removed."
        fi
    done
fi

# -----------------------------------------------------------------------------
# Substitute environment variables in PHP config
# -----------------------------------------------------------------------------
envsubst_php() {
    local file="$1"
    if [ -f "$file" ]; then
        sed -i \
            -e "s|\${PHP_MEMORY_LIMIT}|${PHP_MEMORY_LIMIT:-512M}|g" \
            -e "s|\${PHP_MAX_EXECUTION_TIME}|${PHP_MAX_EXECUTION_TIME:-240}|g" \
            -e "s|\${PHP_UPLOAD_MAX_FILESIZE}|${PHP_UPLOAD_MAX_FILESIZE:-32M}|g" \
            -e "s|\${PHP_POST_MAX_SIZE}|${PHP_POST_MAX_SIZE:-32M}|g" \
            -e "s|\${PHP_MAX_INPUT_VARS}|${PHP_MAX_INPUT_VARS:-1500}|g" \
            "$file"
    fi
}

envsubst_php "/etc/php/${PHP_VERSION}/fpm/conf.d/99-typo3.ini"
envsubst_php "/etc/php/${PHP_VERSION}/cli/conf.d/99-typo3.ini"

# -----------------------------------------------------------------------------
# Set TYPO3_CONTEXT in Nginx (only for nginx variant)
# -----------------------------------------------------------------------------
if [ -f /etc/nginx/conf.d/default.conf ]; then
    sed -i "s|\$TYPO3_CONTEXT|${TYPO3_CONTEXT:-Production}|g" /etc/nginx/conf.d/default.conf
fi

# -----------------------------------------------------------------------------
# Ensure directory permissions
# -----------------------------------------------------------------------------
for dir in /var/www/html/public /var/www/html/var /var/www/html/config; do
    if [ -d "$dir" ]; then
        chown -R typo3:typo3 "$dir"
    fi
done

# Ensure TYPO3 writable directories exist
for dir in var/cache var/log var/lock var/session public/fileadmin public/_assets; do
    mkdir -p "/var/www/html/$dir"
    chown -R typo3:typo3 "/var/www/html/$dir"
done

# -----------------------------------------------------------------------------
# Install additional.php for environment-based TYPO3 configuration
# (only if it does not already exist — users can mount their own)
# -----------------------------------------------------------------------------
ADDITIONAL_CONFIG="/var/www/html/config/system/additional.php"
if [ ! -f "$ADDITIONAL_CONFIG" ]; then
    mkdir -p "$(dirname "$ADDITIONAL_CONFIG")"
    cp /usr/local/share/typo3/additional.php "$ADDITIONAL_CONFIG"
    chown -R typo3:typo3 "$(dirname "$ADDITIONAL_CONFIG")"
    echo "[entrypoint] Installed additional.php (env-based configuration)"
fi

# -----------------------------------------------------------------------------
# Run TYPO3 setup if requested
# -----------------------------------------------------------------------------
if [ "$1" = "typo3-setup" ]; then
    echo "[entrypoint] Running TYPO3 setup..."
    su -s /bin/sh typo3 -c "cd /var/www/html && vendor/bin/typo3 setup \
        --driver=${TYPO3_DB_DRIVER} \
        --host=${TYPO3_DB_HOST} \
        --port=${TYPO3_DB_PORT:-3306} \
        --dbname=${TYPO3_DB_NAME} \
        --username=${TYPO3_DB_USERNAME} \
        --password=${TYPO3_DB_PASSWORD} \
        --admin-username=${TYPO3_SETUP_ADMIN_USERNAME:-admin} \
        --admin-user-password=${TYPO3_SETUP_ADMIN_PASSWORD} \
        --admin-email=${TYPO3_SETUP_ADMIN_EMAIL:-admin@example.com} \
        --no-interaction"
    echo "[entrypoint] TYPO3 setup complete"
    shift
fi

# -----------------------------------------------------------------------------
# Execute command
# -----------------------------------------------------------------------------
exec "$@"
