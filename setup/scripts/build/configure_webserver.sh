if [ ${WEB_SERVER} = "apache_prefork" ]
then
  #a2enmod rewrite
  # why fcgi?
  #a2enmod proxy_fcgi
  #a2enmod remoteip
  #a2enmod expires
  #a2enmod mpm_prefork

  #a2dismod mpm_event
  #a2dismod authn_file
  #a2dismod authz_user

  a2dismod -f authn_file authz_user access_compat autoindex deflate filter negotiation
  a2dismod -f mpm_event

  a2enmod mpm_prefork
  a2enmod expires headers mime_magic rewrite remoteip vhost_alias
  a2enmod proxy proxy_http

  # service apache2 reload
  service apache2 restart

elif [ ${WEB_SERVER} = "apache_fpm" ]
then
  #a2dismod -f authn_file
  #a2dismod -f authz_user
  a2dismod -f authn_file authz_user access_compat autoindex deflate filter negotiation
  a2dismod mpm_prefork

  a2enmod expires
  a2enmod proxy
  a2enmod proxy_fcgi
  a2enmod rewrite
  a2enmod remoteip

  a2enconf php-fpm
  a2enmod mpm_event
  
  # service apache2 reload
  service apache2 restart

else
  echo "Invalid web server type: ${WEB_SERVER}"
fi
