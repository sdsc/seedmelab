#!/bin/bash

# Abort if site already exists
if [[ -f "$DRUPAL_SITE_DIR/composer.json" || \
      -f "$DRUPAL_SITE_DIR/composer.lock" ]] ; then
    echo "Found composer.json or composer.lock"
    echo "Aborting fresh drupal download! Site already exists"
    echo "You may run clean-up.sh to start afresh"
    exit 1
fi

if [[ -f "$DRUPAL_SITE_DIR/web/sites/default/settings.php"
   ]] ; then
    echo "Found settings.php"
    echo "Aborting fresh drupal download! Site already exists"
    exit 1
fi

/scripts/install/download_drupal.sh
/scripts/install/install_drupal.sh
/scripts/install/install_modules.sh
