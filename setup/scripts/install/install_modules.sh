#!/bin/bash

cd ${DRUPAL_SITE_DIR}

install_contrib_modules() {
  drush pm:enable token restui admin_toolbar --yes
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

echo "---------------------------------"
echo "Installing core modules..."
install_core_modules

echo "---------------------------------"
echo "Installing contrib modules..."
install_contrib_modules

echo "---------------------------------"
echo "Completed SeedMeLab installation"

echo "---------------------------------"
cat "/tmp/site_credentials.txt"
