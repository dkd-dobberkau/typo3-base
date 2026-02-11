#!/bin/sh
set -e

# =============================================================================
# TYPO3 Demo Setup Script
# Runs initial setup, creates admin user, imports demo content
# =============================================================================

echo "[demo-setup] Waiting for database..."
until php -r "new PDO('mysql:host=${TYPO3_DB_HOST};port=${TYPO3_DB_PORT}', '${TYPO3_DB_USERNAME}', '${TYPO3_DB_PASSWORD}');" 2>/dev/null; do
    echo "[demo-setup] Database not ready, retrying in 3s..."
    sleep 3
done
echo "[demo-setup] Database is ready"

cd /var/www/html

# Ensure var directory is writable by typo3
chown -R typo3:typo3 /var/www/html/var /var/www/html/public/fileadmin

# Run all TYPO3 commands as typo3 user
echo "[demo-setup] Running TYPO3 setup..."
su -s /bin/sh typo3 -c "
    vendor/bin/typo3 setup \
        --driver='${TYPO3_DB_DRIVER:-mysqli}' \
        --host='${TYPO3_DB_HOST}' \
        --port='${TYPO3_DB_PORT:-3306}' \
        --dbname='${TYPO3_DB_NAME}' \
        --username='${TYPO3_DB_USERNAME}' \
        --password='${TYPO3_DB_PASSWORD}' \
        --admin-username='${TYPO3_SETUP_ADMIN_USERNAME:-admin}' \
        --admin-password='${TYPO3_SETUP_ADMIN_PASSWORD:-Password1!}' \
        --admin-email='${TYPO3_SETUP_ADMIN_EMAIL:-admin@example.com}' \
        --no-interaction \
        --force || true

    echo '[demo-setup] Running database schema update...'
    vendor/bin/typo3 database:updateschema || true

    echo '[demo-setup] Setting up extensions...'
    vendor/bin/typo3 extension:setup || true

    echo '[demo-setup] Flushing caches...'
    vendor/bin/typo3 cache:flush || true
"

echo "================================================"
echo " TYPO3 Demo is ready!"
echo ""
echo " Frontend:  ${TYPO3_BASE_URL:-http://localhost:8080}"
echo " Backend:   ${TYPO3_BASE_URL:-http://localhost:8080}/typo3"
echo " Username:  ${TYPO3_SETUP_ADMIN_USERNAME:-admin}"
echo " Password:  ${TYPO3_SETUP_ADMIN_PASSWORD:-Password1!}"
echo "================================================"
