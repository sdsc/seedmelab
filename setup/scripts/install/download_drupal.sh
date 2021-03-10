#!/bin/bash

# Abort if a site already exists
if [[ -f "${DRUPAL_SITE_DIR}/web/sites/default/settings.php" || \
     -f "${DRUPAL_SITE_DIR}/composer.json" || \
     -f "${DRUPAL_SITE_DIR}/composer.lock" ]]; then
    echo "Aborting fresh drupal download! Site already exists"
    echo "You may run clean-up.sh to start afresh"
    exit 1
fi

# Download drupal in temp dir, as composer complains that /var/www is not empty
# After download move the contents from temp dir to /var/www
TMP_DIR=`mktemp -d`
echo "Fetching drupal/recommended-project with composer... at ${TMP_DIR}"
composer create-project drupal/recommended-project:^9 ${TMP_DIR} --no-interaction

echo "Copying drupal project from ${TMP_DIR} to ${DRUPAL_SITE_DIR}"
cp "${TMP_DIR}/composer.json" ${DRUPAL_SITE_DIR}
cp "${TMP_DIR}/composer.lock" ${DRUPAL_SITE_DIR}
cp "${TMP_DIR}/vendor" ${DRUPAL_SITE_DIR}
cp "${TMP_DIR}/web/*.*" "${DRUPAL_SITE_DIR}/web/"
rm -rf ${TMP_DIR}

echo "Fetching SeedMeLab dependencies with composer..."
cd ${DRUPAL_SITE_DIR}
# Drupal shell for command line administration
composer require drush/drush    
# SeedMeLab ecosystem modules
composer require drupal/foldershare drupal/foldershare_rest drupal/formatter_suite 
# Drupal contributed modules
composer require drupal/admin_toolbar drupal/restui drupal/smtp drupal/structure_sync drupal/token 
# Drupal contributed themes
composer require drupal/bootstrap4
