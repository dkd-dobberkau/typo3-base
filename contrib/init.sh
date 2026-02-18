#!/bin/sh
set -e

# =============================================================================
# TYPO3 Contribution — Init & Service Startup
#
# Runs as root (via docker-entrypoint.sh), handles:
#   1. Validate typo3core git checkout
#   2. Composer install (as typo3 user)
#   3. Start PHP-FPM + Apache
# =============================================================================

MISSING_CORE="ERROR: The typo3core directory is missing or not a valid TYPO3 Core git clone.

Please clone the TYPO3 Core repository first:

  git clone --branch=main ssh://XXX@review.typo3.org:29418/Packages/TYPO3.CMS.git typo3core

(replace XXX with your my.typo3.org username)"

# -----------------------------------------------------------------------------
# 1. Validate TYPO3 Core git checkout
# -----------------------------------------------------------------------------

if [ ! -d "/var/www/html/typo3core/.git" ]; then
    echo "$MISSING_CORE"
    exit 1
fi

if ! grep -q "url = ssh://.*@review.typo3.org:29418/Packages/TYPO3.CMS.git" "/var/www/html/typo3core/.git/config"; then
    echo "$MISSING_CORE"
    exit 1
fi

echo "TYPO3 Core git repository found."

# -----------------------------------------------------------------------------
# 2. Set up composer.json on first run
# -----------------------------------------------------------------------------

if [ ! -f "/var/www/html/config/composer.json" ]; then
    echo "First run — initialising composer project..."
    mkdir -p /var/www/html/config
    cp /var/www/html/dist.composer.json /var/www/html/config/composer.json
    chown typo3:typo3 /var/www/html/config/composer.json
fi

# Symlink config/composer.json to project root (if not already present)
if [ ! -f "/var/www/html/composer.json" ]; then
    ln -s /var/www/html/config/composer.json /var/www/html/composer.json
fi

# -----------------------------------------------------------------------------
# 3. Composer install
# -----------------------------------------------------------------------------

echo "Running composer install (outer project)..."
su -s /bin/sh typo3 -c "cd /var/www/html && composer install --no-interaction"

echo "Running composer install (TYPO3 Core mono repo)..."
su -s /bin/sh typo3 -c "cd /var/www/html/typo3core && composer install --no-interaction"

# @todo: Check if config/system/settings.php exists
# - if no: Run TYPO3 setup with default username + password

# @todo: Execute maintenance:
# vendor/bin/typo3 cache:flush
# vendor/bin/typo3 extension:setup
# vendor/bin/typo3 cache:warmup

echo "Composer setup complete."

# -----------------------------------------------------------------------------
# 4. Start services
# -----------------------------------------------------------------------------

echo "Starting PHP-FPM..."
php-fpm &

echo "Starting Apache..."
exec apache2ctl -D FOREGROUND
