#!/bin/bash

echo "Creating required empty folders"
mkdir -p persistent_data/site_data/web # drupal code and site data
mkdir -p persistent_data/site_data/sync # site configuration files
mkdir -p persistent_data/site_data/vendor # drupal libraries and ancillary tools like drush
mkdir -p persistent_data/site_data/private_files # uploaded seedmelab data
mkdir -p persistent_data/site_data/backups # backup of database and site file, but not private_files
mkdir -p persistent_data/db_data # mysql server data

echo "This folder contains all persistent data for the website." >> persistent_data/README.md
echo "db_data: Contains mysql server database contents." >> persistent_data/README.md
echo "site_data/web: Contains Drupal code and website data" >> persistent_data/README.md
echo "site_data/web/sites/default: Contains website settings and data" >> persistent_data/README.md
echo "site_data/web/vendor: Contains code for libraries needed by Drupal and Drush" >> persistent_data/README.md
echo "site_data/sync: Contains website configuration" >> persistent_data/README.md
echo "site_data/private_files: Contains data uploaded by foldershare module (SeedMeLab)." >> persistent_data/README.md
echo "site_data/backups: Contains backups of database and site_data/web/sites/default." >> persistent_data/README.md
echo "site_data/private_files are not backed up" >> persistent_data/README.md
echo "Done creating required folders"
