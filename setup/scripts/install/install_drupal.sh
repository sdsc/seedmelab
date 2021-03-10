#!/bin/bash
# todo: Move mysql credentials to defaults_file

# Abort if a site already exists
if [[ -f "${DRUPAL_SITE_DIR}/web/sites/default/settings.php" ]] ; then
    echo "Found: settings.php"
    echo "Aborting fresh drupal install! Site already exists"
    echo "You may run clean-up.sh to start afresh"
    exit 1
fi

SITE_NAME="My SeedmeLab Instance"
DRUPAL_ADMIN_PASS=$(pwgen 16)
DRUPAL_DEMO_USER="demo"
DRUPAL_DEMO_PASS=$(pwgen 16)

# Temp files that store credentials, will be deleted later
MYSQL_CURRENT_ROOT_FILE=$(mktemp)
MYSQL_NEW_ROOT_FILE=$(mktemp)
SITE_CREDENTIALS="/tmp/site_credentials.txt"

# Function to write mysql defaults file
write_defaults_file () {
    outfile=${1}
    mysql_user=${2}
    mysql_password=${3}

    # Write database credentials
    echo "[client]" >> $outfile
    echo "host = db" >> $outfile
    echo "user = ${mysql_user}" >> $outfile
    echo "password = ${mysql_password}" >> $outfile
}

# When using stock MySQL docker image, change MYSQL_ROOT_PASSWORD if specified with "GENERATE_RANDOM_PASSWORD"  
if [ "${MYSQL_ROOT_PASSWORD}" == "GENERATE_RANDOM_PASSWORD" ]; then
    NEW_MYSQL_ROOT_PASSWORD=$(pwgen 24)
    sql_change_pass="SET PASSWORD = '${NEW_MYSQL_ROOT_PASSWORD}';"

    write_defaults_file ${MYSQL_CURRENT_ROOT_FILE} 'root' ${MYSQL_ROOT_PASSWORD}
    write_defaults_file ${MYSQL_NEW_ROOT_FILE} 'root' ${NEW_MYSQL_ROOT_PASSWORD}

    mysql --defaults-file=${MYSQL_CURRENT_ROOT_FILE} --execute "${sql_change_pass}"
    mysql --defaults-file=${MYSQL_NEW_ROOT_FILE} --execute "FLUSH PRIVILEGES;"

    MYSQL_ROOT_PASSWORD=${NEW_MYSQL_ROOT_PASSWORD}
fi

# Grant web server write access to required files and directories
chown -R www-data ${DRUPAL_SITE_DIR}/web/sites/default
chown -R www-data /var/www/backups /var/www/private_files /var/www/sync
chown www-data /var/www/composer.json /var/www/composer.lock

echo "Installing drupal site..."
cd ${DRUPAL_SITE_DIR}

if [ -z ${MYSQL_HOST+x} ] && [ -z ${MYSQL_PORT+x} ]; then 
    SALT=$(pwgen 16)
    MYSQL_USER="seedmelab_${SALT}" # vary username with salt
    MYSQL_PASSWORD="$(pwgen 24)"
    MYSQL_DATABASE="${MYSQL_USER}" # use same as the username

    echo "Creating required database";
    sql_create_database="CREATE DATABASE \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql --defaults-file=${MYSQL_NEW_ROOT_FILE} --execute "${sql_create_database}"
    
    echo "Creating a database user with password";
    sql_create_user="CREATE USER ${MYSQL_USER}@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql --defaults-file=${MYSQL_NEW_ROOT_FILE} --execute "${sql_create_user}"
    
    echo "Granting required privileges to the database user";
    sql_grant_privileges="GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql --defaults-file=${MYSQL_NEW_ROOT_FILE} --execute "${sql_grant_privileges}"

    # Install Drupal with newly generated database, database user and password
    drush site:install -vvv --db-url=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@db/${MYSQL_DATABASE} --account-pass "${DRUPAL_ADMIN_PASS}" --site-name "${SITE_NAME}" --yes

else 
    echo "Install using the specified database host & port"; 
    drush site:install -vvv --db-url=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE} --account-pass "${DRUPAL_ADMIN_PASS}" --site-name "${SITE_NAME}" --yes
fi

# Add locations for sync and private_files directories
chmod u+w ${DRUPAL_SITE_DIR}/web/sites/default/settings.php
echo '$settings["config_sync_directory"] = "/var/www/sync";' >> ${DRUPAL_SITE_DIR}/web/sites/default/settings.php
echo '$settings["file_private_path"] = "/var/www/private_files";' >> ${DRUPAL_SITE_DIR}/web/sites/default/settings.php
chmod u-w ${DRUPAL_SITE_DIR}/web/sites/default/settings.php

# Disable powered, search and tool blocks for bartik theme
drush config:set block.block.bartik_search status 0 --yes
drush config:set block.block.bartik_tools status 0 --yes
drush config:set block.block.bartik_powered status 0 --yes

# Create a demo user account
echo "Create ${DRUPAL_DEMO_USER} user with password: ${DRUPAL_DEMO_PASS}"
drush user:create ${DRUPAL_DEMO_USER} --password="${DRUPAL_DEMO_PASS}"
drush cache:rebuild

# Write credentials to a file so it can be printed at the end.
echo "Save the following information about your SeedMeLab site" >> ${SITE_CREDENTIALS}
echo "---------------------------------------------------------------" >> ${SITE_CREDENTIALS}
if [ -z ${MYSQL_HOST+x} ] && [ -z ${MYSQL_PORT+x} ]; then 
  echo "MySQL root password: ${MYSQL_ROOT_PASSWORD}" >> ${SITE_CREDENTIALS}
fi
echo "MySQL database: ${MYSQL_DATABASE}" >> ${SITE_CREDENTIALS}
echo "MySQL user: ${MYSQL_USER}" >> ${SITE_CREDENTIALS}
echo "MySQL user password: ${MYSQL_PASSWORD}" >> ${SITE_CREDENTIALS}
echo "---------------------------------------------------------------" >> ${SITE_CREDENTIALS}
if [ -z ${VIRTUAL_HOST+x} ]; then
    echo "Visit your site at ${VIRTUAL_HOST}" >> ${SITE_CREDENTIALS}
else
    echo "Visit your site at http://localhost:8080 " >> ${SITE_CREDENTIALS}
fi
echo "Logon to your site as one of the following user" >> ${SITE_CREDENTIALS}
echo "Username: admin  Password: ${DRUPAL_ADMIN_PASS}" >> ${SITE_CREDENTIALS}
echo "Username: demo  Password: ${DRUPAL_DEMO_PASS}" >> ${SITE_CREDENTIALS}

# Clean up
rm ${MYSQL_CURRENT_ROOT_FILE} ${MYSQL_NEW_ROOT_FILE}
