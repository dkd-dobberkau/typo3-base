#!/bin/sh

set -e

export MISSING_CORE="The typo3core directory is missing. Please first do a git clone:\n
git clone --branch=main ssh://XXX@review.typo3.org:29418/Packages/TYPO3.CMS.git typo3core\n
(replace XXX with your my.typo3.org username!)"

# Check if the directory exists
if [ ! -d "/var/www/html/typo3core" ]; then
  echo "ERR-01"
  echo $MISSING_CORE
  exit 1
fi

# Check if .git directory exists
if [ ! -d "/var/www/html/typo3core/.git" ]; then
  echo "ERR-02"
  echo $MISSING_CORE
  exit 1
fi

# Check if .git/config file exists
if [ ! -f "/var/www/html/typo3core/.git/config" ]; then
  echo "ERR-03"
  echo $MISSING_CORE
  exit 1
fi

# Check if the config file contains the required URL pattern
if ! grep -q "url = ssh://.*@review.typo3.org:29418/Packages/TYPO3.CMS.git" "/var/www/html/typo3core/.git/config"; then
  echo "ERR-04"
  echo $MISSING_CORE
  exit 1
fi

# All checks passed
echo "TYPO3 git repository was found."
echo "Checking if project is set up already."

if [ ! -f "/var/www/html/config/composer.json" ] ; then
  echo "Initialising composer."
  echo "Place internal dist.composer.json into typo3config/composer.json"
  echo "and symlinking to /var/www/html/composer.json"

  cp /var/www/html/dist.composer.json /var/www/html/config/composer.json
  # @todo - Helper script to check if all CMS Core packages are listed in composer.json?
fi

ln -s /var/www/html/config/composer.json /var/www/html/composer.json

if [ -f "/var/www/html/config/composer.lock" ] ; then
  echo "Symlinking persisted composer.lock"
  ln -s /var/www/html/config/composer.lock /var/www/html/composer.lock
fi

echo "Ensuring composer is up to date"
composer install

if [ ! -f "/var/www/html/config/composer.lock" ] ; then
  echo "Persisting composer.lock for next run"
  cp /var/www/html/composer.lock /var/www/html/config/composer.lock
  rm /var/www/html/composer.lock
  ln -s /var/www/html/config/composer.lock /var/www/html/composer.lock
fi


# Whenever our container starts we'll start the composer
# installer to ensure our container is up to date, when GIT pulls
# occurred.

# The "outer" composer framework
#composer install

# The "inner" TYPO3 mono repo
#cd typo3core
#composer install

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
