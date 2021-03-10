#!/bin/bash

cd ${DRUPAL_SITE_DIR}

install_contrib_themes() {
  drush theme:enable bootstrap4 --yes
}


install_contrib_modules() {
  drush pm:enable token restui admin_toolbar admin_toolbar_tools structure_sync --yes
  drush pm:enable foldershare foldershare_rest --yes
  #drush pm:enable formatter_suit chart_suite --yes

  # Set foldershare settings
  drush config:set foldershare.settings file_scheme private --yes

   # Set foldershare permissions for roles
  drush role:perm:add 'authenticated' 'author foldershare' --yes
  drush role:perm:add 'authenticated' 'share foldershare' --yes
  drush role:perm:add 'authenticated' 'share public foldershare' --yes
  drush role:perm:add 'authenticated' 'view foldershare' --yes
  drush role:perm:add 'anonymous' 'view foldershare' --yes
}

install_core_modules() {
  drush pm:enable \
    automated_cron \
    ban \
    big_pipe \
    block \
    block_content \
    book \
    breakpoint \
    ckeditor \
    config \
    contact \
    datetime \
    dblog \
    dynamic_page_cache \
    editor \
    entity_reference \
    field \
    field_ui \
    file \
    filter \
    help \
    image \
    link \
    media \
    menu_link_content \
    menu_ui \
    node \
    options \
    page_cache \
    path \
    path_alias \
    telephone \
    text \
    toolbar \
    update \
    views \
    views_ui --yes
}

echo "---------------------------------------------------------------"
echo "Installing core modules..."
install_core_modules

echo "---------------------------------------------------------------"
echo "Installing contrib modules..."
install_contrib_modules

echo "---------------------------------------------------------------"
echo "Customizing SeedMeLab site..."
install_contrib_themes
# Set Bootstrap4 as default theme
drush config-set system.theme default bootstrap4 --yes
# Disable search and powered blocks for bootstrap4 theme
drush config:set block.block.bootstrap4_search_form status 0 --yes
drush config:set block.block.bootstrap4_powered_by_drupal status 0 --yes
# Set home page to /foldershare
drush config:set system.site page.front /foldershare --yes

# import custom menu and custom block content
cp /conf/structure_sync.data.yml /var/www/sync
cp /conf/block.block.poweredbyseedmelab.yml /var/www/sync
drush config:import --partial --source /var/www/sync --yes
drush ib --choice safe
drush im --choice safe
drush pm:uninstall structure_sync --yes
drush cache:rebuild
# Toss installed menu and block
rm /var/www/sync/structure_sync.data.yml

echo "---------------------------------------------------------------"
echo "Completed SeedMeLab installation"
cat "/tmp/site_credentials.txt"
echo "---------------------------------------------------------------"
rm "/tmp/site_credentials.txt"
