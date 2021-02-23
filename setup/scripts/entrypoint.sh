#!/bin/bash

perm_file='/tmp/permran.txt'

# Set permissions for the webserver to various folders and files
set_perm() {
echo "Set permissions to www-data:www-data for /var/www/web/sites/default/files /var/www/sync /var/www/private_files "
echo "This can take some time, the process runs in background"
echo "Permission status is noted at $perm_file"
chown -R www-data:www-data /var/www/web/sites/default/files \
                  	   /var/www/sync \
                  	   /var/www/private_files
date >> $perm_file 
echo "Done permission changes" >> $perm_file 
}

start_php_fpm() {
  if [ $PHP_VERSION = "7.2" ]
  then
    service php7.2-fpm start
  elif [ $PHP_VERSION = "7.3" ]
  then
    service php7.3-fpm start
  elif [ $PHP_VERSION = "7.4" ]
  then
    service php7.4-fpm start
  fi
}

start_web_server() {
  if [ $WEB_SERVER = "nginx" ]
  then
    start_php_fpm && nginx -g 'daemon off;'
  elif [ $WEB_SERVER = "apache_prefork" ]
  then
    apachectl -e info -DFOREGROUND
  elif [ $WEB_SERVER = "apache_fpm" ]
  then
    start_php_fpm && apachectl -e info -DFOREGROUND
  fi
}

start_cron() {
  service cron start
}

start_postfix() {
  if [ -f /usr/sbin/postfix ]; then
    service postfix start
  fi
}

# Set permissions in background only once
if [ ! -f $perm_file ]; then
	set_perm &
	date >> $perm_file
	echo "Permission change background process pid = $!" >> $perm_file
fi

start_postfix
start_cron && start_web_server
