# SeedMeLab Quickstart
[SeedMeLab](https://seedmelab.org) is a data management system built on top of [Drupal](https://drupal.org) content management system. This repository provides a Docker based setup to get started with SeedMeLab. It will build, install and run the following services as containers 
1. seedmelab service: Includes Apache webserver with mod_php and mounts persistent volume that includes 

    a. Code: Drupal core + SeedMeLab modules (foldershare, formatter suite) + other contributed Drupal modules
    
    b. All site data including that uploaded by users
2. db service: Provides the database required for Drupal.
3. nginx-proxy service (optional): Provides a reserve proxy to terminate SSL connections to the server and redirect the request to SeedMeLab container. This container is only needed when setting up a public site.
4. nginx-letsencrypt service (optional): If public domain is specificed, it manages minting, installation and renewal  of SSL certificates for the specified domain that will be assigned to the site.


## Setup
1. Create persistent folders that will be mounted as Docker volumes
```
    ./create-folders.sh
```
If needed, start afresh by running ./clean-up.sh

2. Build the containers
```
    docker-compose build
```

3.  Create SeedmeLab site
This setup allows the seedmelab service to be run on localhost or on a public domain name.

    a. Start a local server at <a href="http://localhost:8080">http://localhost:8080</a>.
```
    docker-compose up -d seedmelab
```
    b. Start a public site with a domain name e.g. example.com
    
    Set VIRTUAL_HOST environment variable to bring all four services(containers) up, this will also fetch the SSL certificate for the domain (this can take upto 3 mins).
```
    VIRTUAL_HOST=example.com docker-compose up -d
```
4. On first run only, install the SeedMeLab site.

```
    docker-compose exec seedmelab bash /scripts/install/setup.sh
```
5. Shut down all services while saving state
```
    docker-compose down
```

### Database notes
If you already have a  MySQL/MariaDB database server, use the following steps to create a database and a user with following privileges (refer to official [documentation](https://www.drupal.org/docs/installing-drupal/step-3-create-a-database)). Remove the db image as a dependency for seedmelab container in the docker-compose.yaml file .


## Using SeedMeLab
1. Login to your site

2. Visit the Data page at localhost:8080/foldershare or example.com/foldershare

3. Watch SeedMeLab tutorials for getting started

    a. [Managing data](https://seedmelab.org/managing-data-on-seedmelab) on SeedMeLab for users(3mins)

    b. [Customizing SeedMeLab](https://seedmelab.org/customizing-seedmelab) for data manager (4 mins)

    c. [Managing data via REST client](https://seedmelab.org/managing-data-via-rest-client-on-seedmelab) for automation and power users (5 mins)


## Things for you todo 
1. Change admin password via the website or following command
```
    docker-compose exec seedmelab bash -c "cd $DRUPAL_SITE_DIR && drush user:password admin NEW_SECURE_PASSWORD"
```

2. Enable SMTP module and use it for sending emails, rather than sending emails from server that will likely be marked as spam. Sites often use a new gmail address for this. 

3. Secure your site by

    a. Monthly updates to the containers

    b. Daily backups for code, database and site data
   
    c. First wednesday of each month, review and install Drupal's maintenance + feature updates 
    
    d. Third Wednesday of each month (except December, when its a week earlier) update security releases for Drupal core and contributed modules. 

4. Find all this too tedious, consider our [managed hosting](https://seedmelab.org).


## Getting started with Drupal
1. Read: [Drupal](https://www.drupal.org/docs/user_guide/en/index.html) provides extensive documentation for site administrators and web developers. 

2. Watch: [Short video tutorials](https://www.youtube.com/playlist?list=PLtaXuX0nEZk9MKY_ClWcPkGtOEGyLTyCO
) provide a solid understanding of Drupal.   
