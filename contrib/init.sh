#!/bin/sh

set -e

# Check if the directory exists
if [ ! -d "/var/www/html/typo3core" ]; then
  echo "[i] No GIT repository found yet."
  echo "[+] Cloning (anonymously, using GitHub) ..."
  git clone --branch=main git@github.com:TYPO3/typo3.git typo3core
else
  echo "[i] GIT repository found."
fi

# Check if .git directory exists
if [ ! -d "/var/www/html/typo3core/.git" ]; then
  echo "[!] ERR-02"
  echo "[!] Failed to clone repository. Check for errors above."
  exit 1
fi

# Check if .git/config file exists
if [ ! -f "/var/www/html/typo3core/.git/config" ]; then
  echo "[!] ERR-03"
  echo "[!] Failed to properly clone repository. Check for errors above."
  exit 1
fi

# All checks passed
echo "[i] Performing composer steps"

if [ ! -f "/var/www/html/config/composer.json" ] ; then
  echo "[+] Initialising composer.json"
  echo "[i] Placing internal dist.composer.json into typo3config/composer.json"
  echo "    and symlinking to /var/www/html/composer.json"

  cp /var/www/html/dist.composer.json /var/www/html/config/composer.json
  # @todo - Helper script to check if all CMS Core packages are listed in composer.json?
fi

if [ -f /var/www/html/composer.json ] ; then
  echo "[i] Using existing composer.json"
else
  echo "[+] Symlinking persisted config/composer.json to base composer.json"
  ln -s /var/www/html/config/composer.json /var/www/html/composer.json
fi

if [ -f /var/www/html/composer.lock ] ; then
  echo "[i] Using existing composer.lock"
else
  if [ -f /var/www/html/config/composer.lock ] ; then
    echo "[+] Symlinking persisted composer.lock to base composer.lock"
    ln -s /var/www/html/config/composer.lock /var/www/html/composer.lock
  fi
fi

# Whenever our container starts we'll start the composer
# installer to ensure our container is up to date, when GIT pulls
# occurred.
echo "[i] Ensuring composer matches composer.lock"
composer install

if [ ! -f "/var/www/html/config/composer.lock" ] ; then
  echo "[+] Persisting composer.lock for next run to config/composer.lock"
  cp /var/www/html/composer.lock /var/www/html/config/composer.lock
  echo "[+] Replacing existing composer.lock with a symlink to persisted location"
  rm /var/www/html/composer.lock
  ln -s /var/www/html/config/composer.lock /var/www/html/composer.lock
fi

# That was the "outer" composer framework, now let's do the "inner"
# one, which is just based on GIT monorepo (and completely persisted)
cd typo3core
echo "[i] Ensuring TYPO3 core composer matches composer.lock"
composer install

echo "@todo - setup.demo.sh!"

# @todo: Check if config/system/settings.php exist
# - if yes: container is probably set up. Don't touch.
# - if no: Run TYPO3 setup with default username + password (setup-demo.sh reusable probably)

# @todo: Execute maintenance:
# vendor/bin/typo3 cache:flush
# vendor/bin/typo3 extension:setup
# vendor/bin/typo3 cache:warmup

# Keep the container running
sleep infinity
