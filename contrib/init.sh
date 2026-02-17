#!/bin/sh

set -e

WORKDIR="/var/www/html"
CORE_DIR="${WORKDIR}/typo3core"

# Check if the directory exists
if [ ! -d "${CORE_DIR}" ]; then
  echo "[i] No GIT repository found yet."
  echo "[+] Cloning (anonymously, using GitHub) ..."
  git clone --branch=main git@github.com:TYPO3/typo3.git typo3core
else
  echo "[i] GIT repository found."
fi

# Check if .git directory exists
if [ ! -d "${CORE_DIR}/.git" ]; then
  echo "[!] ERR-02"
  echo "[!] Failed to clone repository. Check for errors above."
  exit 1
fi

# Check if .git/config file exists
if [ ! -f "${CORE_DIR}/.git/config" ]; then
  echo "[!] ERR-03"
  echo "[!] Failed to properly clone repository. Check for errors above."
  exit 1
fi

# All checks passed
echo "[i] Performing composer steps"

if [ ! -f "${WORKDIR}/config/composer.json" ] ; then
  echo "[+] Initialising composer.json"
  echo "[i] Placing internal dist.composer.json into typo3config/composer.json"
  echo "    and symlinking to ${WORKDIR}/composer.json"

  cp "${WORKDIR}/dist.composer.json" "${WORKDIR}/config/composer.json"
  # @todo - Helper script to check if all CMS Core packages are listed in composer.json?
fi

if [ -f "${WORKDIR}/composer.json" ] ; then
  echo "[i] Using existing composer.json"
else
  echo "[+] Symlinking persisted config/composer.json to base composer.json"
  ln -s "${WORKDIR}/config/composer.json" "${WORKDIR}/composer.json"
fi

if [ -f "${WORKDIR}/composer.lock" ] ; then
  echo "[i] Using existing composer.lock"
else
  if [ -f "${WORKDIR}/config/composer.lock" ] ; then
    echo "[+] Symlinking persisted composer.lock to base composer.lock"
    ln -s "${WORKDIR}/config/composer.lock" "${WORKDIR}/composer.lock"
  fi
fi

# Whenever our container starts we'll start the composer
# installer to ensure our container is up to date, when GIT pulls
# occurred.
echo "[i] Ensuring composer matches composer.lock"
composer install --no-interaction

if [ ! -f "${WORKDIR}/config/composer.lock" ] ; then
  echo "[+] Persisting composer.lock for next run to config/composer.lock"
  cp "${WORKDIR}/composer.lock" "${WORKDIR}/config/composer.lock"
  echo "[+] Replacing existing composer.lock with a symlink to persisted location"
  rm "${WORKDIR}/composer.lock"
  ln -s "${WORKDIR}/config/composer.lock" "${WORKDIR}/composer.lock"
fi

# That was the "outer" composer framework, now let's do the "inner"
# one, which is just based on GIT monorepo (and completely persisted)
cd "${CORE_DIR}"
echo "[i] Ensuring TYPO3 core composer matches composer.lock"
composer install --no-interaction

# Set Gerrit push URL if GERRIT_USERNAME is provided (via docker-compose yaml)
if [ -n "${GERRIT_USERNAME}" ]; then
  echo "[i] Setting Gerrit push URL for user: ${GERRIT_USERNAME}"
  cd "${CORE_DIR}"
  git remote set-url --push origin "ssh://${GERRIT_USERNAME}@review.typo3.org:29418/Packages/TYPO3.CMS.git"
  git config user.name "${GERRIT_USERNAME}"
  cd "${WORKDIR}"
  echo "Gerrit push URL configured."
else
  echo "GERRIT_USERNAME not set — skipping Gerrit push URL configuration."
  echo "You can set it later via: docker compose exec web composer tdk:set-push-url"
fi

echo "[i] Adapting git config (URL, commit message, hooks) ..."
git config branch.autosetuprebase remote
git config remote.origin.push "+refs/heads/main:refs/for/main"
if [ ! -f "${CORE_DIR}/.git/gitmessage.txt" ]; then
  echo "[+] Persisted .git/gitmessage.txt"
  cp "${WORKDIR}/dist.gitmessage.txt" "${CORE_DIR}/.git/gitmessage.txt"
  git config commit.template ".git/gitmessage.txt"
fi
if [ -d "${CORE_DIR}/Build/git-hooks" ]; then
  echo "[i] Installing Git hooks ..."
  if [ -f "${CORE_DIR}/Build/git-hooks/commit-msg" ]; then
    cp "${CORE_DIR}/Build/git-hooks/commit-msg" "${CORE_DIR}/.git/hooks/commit-msg"
    chmod 755 "${CORE_DIR}/.git/hooks/commit-msg"
    echo "[+] commit-msg hook installed"
  fi
  if [ -f "${CORE_DIR}/Build/git-hooks/unix+mac/pre-commit" ]; then
    cp "${CORE_DIR}/Build/git-hooks/unix+mac/pre-commit" "${CORE_DIR}/.git/hooks/pre-commit"
    chmod 755 "${CORE_DIR}/.git/hooks/pre-commit"
    echo "[+] pre-commit hook installed"
  fi
fi

cd "${WORKDIR}"
if [ ! -f "${WORKDIR}/config/system/settings.php" ]; then
  echo "[i] Running TYPO3 initial setup ..."
  vendor/bin/typo3 setup \
    --driver="${TYPO3_DB_DRIVER:-mysqli}" \
    --host="${TYPO3_DB_HOST:-db}" \
    --port="${TYPO3_DB_PORT:-3306}" \
    --dbname="${TYPO3_DB_NAME:-typo3}" \
    --username="${TYPO3_DB_USERNAME:-typo3}" \
    --password="${TYPO3_DB_PASSWORD:-typo3}" \
    --admin-username="${TYPO3_ADMIN_USERNAME:-contrib}" \
    --admin-user-password="${TYPO3_ADMIN_PASSWORD:-Th4nx-4H3lp1ng}" \
    --admin-email="${TYPO3_ADMIN_EMAIL:-contrib@example.com}" \
    --project-name="TYPO3 Core Contribution" \
    --create-site="${TYPO3_BASE_URL:-http://localhost:28080}" \
    --server-type=other \
    --no-interaction \
    --force
  echo "[+] TYPO3 setup complete."
else
  echo "[i] TYPO3 already configured (settings.php exists)."
fi

echo "[i] TYPO3 maintenance tasks ..."
vendor/bin/typo3 extension:setup || true
vendor/bin/typo3 cache:flush || true
vendor/bin/typo3 cache:warmup || true

echo "[i] Executing webserver setup containment ..."
/docker-entrypoint.sh

echo "================================================"
echo " TYPO3 Contribution is ready for YOU!"
echo ""
echo " Frontend:  ${TYPO3_BASE_URL:-http://localhost:28080}"
echo " Backend:   ${TYPO3_BASE_URL:-http://localhost:28080}/typo3"
echo " Username:  ${ADMIN_USERNAME:-contrib}"
echo " Password:  ${ADMIN_PASSWORD:-Th4nx-4H3lp1ng}"
echo " Mailpit:   http://localhost:28025"
echo "================================================"

# Keep the container running
sleep infinity
