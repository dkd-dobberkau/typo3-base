#!/bin/sh

set -e

WORKDIR="/var/www/html"
CORE_DIR="${WORKDIR}/typo3core"

MISSING_CORE="The typo3core directory is missing. Please first do a git clone:

  git clone --branch=main ssh://YOUR_USERNAME@review.typo3.org:29418/Packages/TYPO3.CMS.git typo3core

(replace YOUR_USERNAME with your my.typo3.org username!)"

# =============================================================================
# Step 1: Validate TYPO3 Core Git repository
# =============================================================================

if [ ! -d "${CORE_DIR}" ]; then
  echo "ERR-01: ${MISSING_CORE}"
  exit 1
fi

if [ ! -d "${CORE_DIR}/.git" ]; then
  echo "ERR-02: ${MISSING_CORE}"
  exit 1
fi

if [ ! -f "${CORE_DIR}/.git/config" ]; then
  echo "ERR-03: ${MISSING_CORE}"
  exit 1
fi

if ! grep -q "url = .*review.typo3.org.*Packages/TYPO3.CMS" "${CORE_DIR}/.git/config" && \
   ! grep -q "url = .*github.com/TYPO3/typo3" "${CORE_DIR}/.git/config"; then
  echo "ERR-04: ${MISSING_CORE}"
  exit 1
fi

echo "=== TYPO3 Core git repository found ==="

# =============================================================================
# Step 2: Initialize composer project (first run only)
# =============================================================================

if [ ! -f "${WORKDIR}/config/composer.json" ]; then
  echo "First run — initializing composer project..."
  cp "${WORKDIR}/dist.composer.json" "${WORKDIR}/config/composer.json"
fi

if [ ! -f "${WORKDIR}/composer.json" ]; then
  ln -s "${WORKDIR}/config/composer.json" "${WORKDIR}/composer.json"
fi

# =============================================================================
# Step 3: Composer install (outer project + inner mono repo)
# =============================================================================

echo "=== Running composer install ==="
composer install --no-interaction

cd "${CORE_DIR}"
composer install --no-interaction
cd "${WORKDIR}"

# =============================================================================
# Step 4: TDK setup (Gerrit integration)
# =============================================================================

echo "=== Configuring TDK (TYPO3 Development Kit) ==="

# Set Gerrit push URL if GERRIT_USERNAME is provided
if [ -n "${GERRIT_USERNAME}" ]; then
  echo "Setting Gerrit push URL for user: ${GERRIT_USERNAME}"
  cd "${CORE_DIR}"
  git remote set-url --push origin "ssh://${GERRIT_USERNAME}@review.typo3.org:29418/Packages/TYPO3.CMS.git"
  git config user.name "${GERRIT_USERNAME}"
  cd "${WORKDIR}"
  echo "Gerrit push URL configured."
else
  echo "GERRIT_USERNAME not set — skipping Gerrit push URL configuration."
  echo "You can set it later via: docker compose exec web composer tdk:set-push-url"
fi

# Install Git hooks (commit-msg + pre-commit) from TYPO3 Core
if [ -d "${CORE_DIR}/Build/git-hooks" ]; then
  echo "Installing Git hooks..."
  if [ -f "${CORE_DIR}/Build/git-hooks/commit-msg" ]; then
    cp "${CORE_DIR}/Build/git-hooks/commit-msg" "${CORE_DIR}/.git/hooks/commit-msg"
    chmod 755 "${CORE_DIR}/.git/hooks/commit-msg"
    echo "  commit-msg hook installed."
  fi
  if [ -f "${CORE_DIR}/Build/git-hooks/unix+mac/pre-commit" ]; then
    cp "${CORE_DIR}/Build/git-hooks/unix+mac/pre-commit" "${CORE_DIR}/.git/hooks/pre-commit"
    chmod 755 "${CORE_DIR}/.git/hooks/pre-commit"
    echo "  pre-commit hook installed."
  fi
else
  echo "Git hooks directory not found — skipping hook installation."
fi

# Set commit message template
if [ -f "${WORKDIR}/.gitmessage.txt" ]; then
  cd "${CORE_DIR}"
  git config commit.template "${WORKDIR}/.gitmessage.txt"
  cd "${WORKDIR}"
  echo "Commit message template configured."
fi

# =============================================================================
# Step 5: TYPO3 setup (first run only)
# =============================================================================

if [ ! -f "${WORKDIR}/config/system/settings.php" ]; then
  echo "=== Running TYPO3 initial setup ==="
  vendor/bin/typo3 setup \
    --driver="${TYPO3_DB_DRIVER:-mysqli}" \
    --host="${TYPO3_DB_HOST:-db}" \
    --port="${TYPO3_DB_PORT:-3306}" \
    --dbname="${TYPO3_DB_NAME:-typo3}" \
    --username="${TYPO3_DB_USERNAME:-typo3}" \
    --password="${TYPO3_DB_PASSWORD:-typo3}" \
    --admin-username="${TYPO3_ADMIN_USERNAME:-contrib}" \
    --admin-user-password="${TYPO3_ADMIN_PASSWORD:-Th4nx4H3lp1ng}" \
    --admin-email="${TYPO3_ADMIN_EMAIL:-}" \
    --project-name="TYPO3 Core Contribution" \
    --server-type=other \
    --no-interaction \
    --force
  echo "TYPO3 setup complete."
else
  echo "TYPO3 already configured (settings.php exists)."
fi

# =============================================================================
# Step 6: TYPO3 maintenance
# =============================================================================

echo "=== Running TYPO3 maintenance ==="
vendor/bin/typo3 cache:flush || true
vendor/bin/typo3 extension:setup || true
vendor/bin/typo3 cache:warmup || true

# =============================================================================
# Done
# =============================================================================

echo ""
echo "============================================="
echo "  TYPO3 Core Contribution environment ready!"
echo "============================================="
echo ""
echo "  Available TDK commands:"
echo "    composer tdk:doctor         — Run diagnostics"
echo "    composer tdk:apply-patch    — Apply a Gerrit patch"
echo "    composer tdk:checkout       — Checkout a branch"
echo "    composer tdk:enable-hooks   — Re-install Git hooks"
echo "    composer tdk:help           — Show contribution guide"
echo ""
if [ -z "${GERRIT_USERNAME}" ]; then
  echo "  NOTE: Set GERRIT_USERNAME in your .env to enable push access."
  echo ""
fi

# Keep the container running
sleep infinity
