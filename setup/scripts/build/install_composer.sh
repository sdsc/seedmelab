echo "Installing composer..."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php ./composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php