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

# Generate admin password if not provided
ADMIN_USERNAME="${TYPO3_SETUP_ADMIN_USERNAME:-admin}"
ADMIN_EMAIL="${TYPO3_SETUP_ADMIN_EMAIL:-admin@example.com}"
if [ -n "$TYPO3_SETUP_ADMIN_PASSWORD" ]; then
    ADMIN_PASSWORD="$TYPO3_SETUP_ADMIN_PASSWORD"
else
    ADMIN_PASSWORD="$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 12)#T3!"
    echo "[demo-setup] Generated random admin password"
fi

# Ensure directories are writable by typo3
chown -R typo3:typo3 /var/www/html/var /var/www/html/public/fileadmin /var/www/html/config

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
        --admin-username='${ADMIN_USERNAME}' \
        --admin-user-password='${ADMIN_PASSWORD}' \
        --admin-email='${ADMIN_EMAIL}' \
        --no-interaction \
        --force || true

    echo '[demo-setup] Setting up extensions...'
    vendor/bin/typo3 extension:setup || true

    echo '[demo-setup] Flushing caches...'
    vendor/bin/typo3 cache:flush || true
"

# Configure SMTP mail transport if SMTP_HOST is set
if [ -n "$SMTP_HOST" ]; then
    echo "[demo-setup] Configuring SMTP mail transport (${SMTP_HOST}:${SMTP_PORT:-1025})..."
    su -s /bin/sh typo3 -c "
        vendor/bin/typo3 configuration:set MAIL/transport smtp || true
        vendor/bin/typo3 configuration:set MAIL/transport_smtp_server '${SMTP_HOST}:${SMTP_PORT:-1025}' || true
    "
    echo "[demo-setup] SMTP configured"
fi

# Write credentials file
CREDENTIALS_FILE="/var/www/html/var/credentials.txt"
cat > "$CREDENTIALS_FILE" <<EOF
TYPO3 Demo Credentials
======================
Backend URL:  ${TYPO3_BASE_URL:-http://localhost:8080}/typo3
Username:     ${ADMIN_USERNAME}
Password:     ${ADMIN_PASSWORD}
Generated:    $(date -u +"%Y-%m-%d %H:%M:%S UTC")
EOF
chown typo3:typo3 "$CREDENTIALS_FILE"
chmod 600 "$CREDENTIALS_FILE"

echo "================================================"
echo " TYPO3 Demo is ready!"
echo ""
echo " Frontend:  ${TYPO3_BASE_URL:-http://localhost:8080}"
echo " Backend:   ${TYPO3_BASE_URL:-http://localhost:8080}/typo3"
echo " Username:  ${ADMIN_USERNAME}"
echo " Password:  ${ADMIN_PASSWORD}"
echo ""
echo " Credentials saved to: ${CREDENTIALS_FILE}"
if [ -n "$SMTP_HOST" ]; then
echo " Mailpit:   http://localhost:8025"
fi
echo "================================================"
