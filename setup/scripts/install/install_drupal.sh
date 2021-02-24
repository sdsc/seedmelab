#!/bin/bash

# Abort if a site already exists
if [[ -f "${DRUPAL_SITE_DIR}/web/sites/default/settings.php" ]] ; then
    echo "Found: settings.php"
    echo "Aborting fresh drupal install! Site already exists"
    echo "You may run clean-up.sh to start afresh"
    exit 1
fi

SITE_NAME="SeedmeLab Quickstart"
DRUPAL_ADMIN_PASS=`pwgen`
DRUPAL_DEMO_USER="demo"
DRUPAL_DEMO_PASS=`pwgen`
SITE_CREDENTIALS="/tmp/site_credentials.txt"

# When using stock MySQL docker image, change MYSQL_PASSWORD if specified with "GENERATE_RANDOM_PASSWORD"  
if [ "$MYSQL_PASSWORD" == "GENERATE_RANDOM_PASSWORD" ]; then
    NEW_MYSQL_PASSWORD=`pwgen 24`
    change_pass="SET PASSWORD = '${NEW_MYSQL_PASSWORD}';"
    mysql --host db -u ${MYSQL_USER} --password='${MYSQL_PASSWORD}' -e "${change_pass}"
    MYSQL_PASSWORD=${NEW_MYSQL_PASSWORD}
fi

echo "Database credentials for the site are configured and stored in /var/www/web/sites/default/setting.php"

if [ -z ${VIRTUAL_HOST+x} ]; then
    echo "Visit your site at ${VIRTUAL_HOST}" >> ${SITE_CREDENTIALS}
else
    echo "Visit your site at http://localhost:8080 " >> ${SITE_CREDENTIALS}
fi
echo "Logon to your site as one of the following user" >> ${SITE_CREDENTIALS}
echo "Username: admin  Password: ${DRUPAL_ADMIN_PASS}" >> ${SITE_CREDENTIALS}
echo "Username: demo  Password: ${DRUPAL_DEMO_PASS}" >> ${SITE_CREDENTIALS}


# Grant web server write access to required files and directories
chown -R www-data ${DRUPAL_SITE_DIR}/web/sites/default
chown -R www-data /var/www/backups /var/www/private_files /var/www/sync
chown www-data /var/www/composer.json /var/www/composer.lock

echo "Installing drupal site..."
cd ${DRUPAL_SITE_DIR}

if [ -z ${MYSQL_HOST+x} ] && [ -z ${MYSQL_PORT+x}   ]; then 
    echo "Install using default database host"; 
    drush site:install -vvv --db-url=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@db/${MYSQL_DATABASE} --site-name "${SITE_NAME}" --yes
else 
    echo "Install using provided database host"; 
    drush site:install -vvv --db-url=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE} --site-name "${SITE_NAME}" --yes
fi

# Add locations for sync and private_files directories
chmod u+w /var/www/web/sites/default/settings.php
echo '$settings["config_sync_directory"] = "/var/www/sync";' >> ${DRUPAL_SITE_DIR}/web/sites/default/settings.php
echo '$settings["file_private_path"] = "/var/www/private_files";' >> ${DRUPAL_SITE_DIR}/web/sites/default/settings.php
chmod u-w /var/www/web/sites/default/settings.php

# Disable powered, search and tool blocks for bartik theme
drush config:set block.block.bartik_search status 0 -y
drush config:set block.block.bartik_tools status 0 -y
drush config:set block.block.bartik_powered status 0 -y

# Set passwords for admin and demo accounts
echo "Set new admin password to: ${DRUPAL_ADMIN_PASS}"
drush user:password admin "${DRUPAL_ADMIN_PASS}"

echo "Create ${DRUPAL_DEMO_USER} user with password: ${DRUPAL_DEMO_PASS}"
drush user:create ${DRUPAL_DEMO_USER} --password="${DRUPAL_DEMO_PASS}"

drush cache:rebuild
