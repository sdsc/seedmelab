FROM php:7.4-apache-buster

# Set PHP version and apache server type
ARG PHP_VERSION=7.4
ARG WEB_SERVER=apache_prefork
ENV PHP_VERSION=$PHP_VERSION
ENV WEB_SERVER=$WEB_SERVER
# Set environment for Drupal setup
ARG DRUPAL_SITE_DIR=/var/www
ENV DRUPAL_SITE_DIR=$DRUPAL_SITE_DIR
ENV PATH=$DRUPAL_SITE_DIR/vendor/bin/:$PATH
ENV BACKUP_DIR=/var/www/backups
# Set environment for Drupal setup
ENV PATH=$DRUPAL_SITE_DIR/vendor/bin/:$PATH
ENV DEBIAN_FRONTEND=noninteractive

# Update the container and install commonly needed tools
RUN apt update -y && apt upgrade -y && apt-get install -y curl vim zip unzip git wget cron pwgen patch default-mysql-client postfix

# php:7.4-apache-buster image is missing a few required PHP extensions, untill its fixed  
# Install the missing PHP extensions 
RUN set -eux; \
        \
        if command -v a2enmod; then \
                a2enmod rewrite; \
        fi; \
        \
        savedAptMark="$(apt-mark showmanual)"; \
        \
        apt-get update; \
        apt-get install -y --no-install-recommends \
                libfreetype6-dev \
                libjpeg-dev \
                libpng-dev \
                libpq-dev \
                libzip-dev \
        ; \
        \
        docker-php-ext-configure gd \
                --with-freetype \
                --with-jpeg=/usr \
        ; \
        \
        docker-php-ext-install -j "$(nproc)" \
                gd \
                opcache \
                pdo_mysql \
                pdo_pgsql \
                zip \
        ; \
        \
        # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
        apt-mark auto '.*' > /dev/null; \
        apt-mark manual $savedAptMark; \
        ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
                | awk '/=>/ { print $3 }' \
                | sort -u \
                | xargs -r dpkg-query -S \
                | cut -d: -f1 \
                | sort -u \
                | xargs -rt apt-mark manual; \
        \
        apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
        rm -rf /var/lib/apt/lists/*

# Copy build & install scripts from host to image
COPY scripts /scripts
RUN chmod +x /scripts/build/*.sh
RUN chmod +x /scripts/install/*.sh

# Copy all conf to /
COPY conf /conf

# Move php.ini customizations for seedmelab
RUN mv /conf/99-seedmelab-php.ini /usr/local/etc/php/conf.d

# Configure web server
RUN mv /conf/seedmelab_vhost.conf /etc/apache2/sites-available/000-default.conf
# Todo: Strip out extraneous modules that increase security footprint
#RUN /scripts/build/configure_webserver.sh

# Set site cron to run every 5 minutes to build search index and perform background tasks
RUN crontab /conf/site-cron.crontab

# Install Composer
RUN /scripts/build/install_composer.sh

# Copy entrypoint.sh that starts cron, postfix and webserver
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR $DRUPAL_SITE_DIR
ENTRYPOINT /entrypoint.sh
