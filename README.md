# SeedMeLab Quickstart
[SeedMeLab](https://seedmelab.org) is a scientific data management system for teams struggling with intractable data organization and data access that often disrupts productivity, obscures discovery due to fragmented information and  perpetuates poor knowledge. Unlike other file sharing services; SeedMeLab transforms data management with a native ability to add description, discussion and visualizations for any data items and establish distinction of your data with your branding. 

SeedMeLab is built on top of [Drupal](https://drupal.org) content management system. This repository provides a Docker based setup to get started with SeedMeLab. It will build, install and run the following services as containers 

1. seedmelab service: Includes Apache webserver with mod_php and mounts persistent volume that includes 

    a. Code: Drupal core + SeedMeLab modules (foldershare, formatter suite) + other contributed Drupal modules
    
    b. All site data including that uploaded by users

2. db service: Provides the database required for Drupal.

3. nginx-proxy service (optional): Provides a reserve proxy to terminate SSL connections to the server and redirect the request to SeedMeLab container. This container is only needed when setting up a public site.

4. nginx-letsencrypt service (optional): If public domain is specificed, it manages minting, installation and renewal  of SSL certificates for the specified domain that will be assigned to the site.


## Setup
1. Create persistent folders that will be mounted as Docker volumes.
```
    ./create-folders.sh
```
If needed, start afresh by running ./clean-up.sh

2. Build all services. 
On Linux and Windows - Remove ":delegated" from Volume mounts in docker-compose.yml file. These are useful on Mac OS where the docker bind mounts are dead slow.
```
    docker-compose build
```

3.  Create SeedmeLab site
This setup allows the seedmelab service to be run on localhost or on a public domain name.

    a. Create a site on your localhost at <a href="http://localhost:8080">http://localhost:8080</a>.
```
    docker-compose up -d seedmelab
```

    b. Create a public site on a host with your domain name e.g. example.com, this host must be accessible on your domain address. Set VIRTUAL_HOST environment variable to bring all four services(containers) up, this will also fetch the SSL certificate for the domain (this can take upto 3 mins).   
```
    VIRTUAL_HOST=example.com docker-compose up -d
```
4. On first run only, install the SeedMeLab site.

```
    docker-compose exec seedmelab bash /scripts/install/setup.sh
```
5. Shut down all services while saving state.
```
    docker-compose down
```
6. Start afresh
```
    docker-compose stop seedmelab; docker-compose rm -f seedmelab; docker-compose stop db; docker-compose rm -f db
    ./clean-up.sh
    docker-compose build
    docker-compose up -d seedmelab
    docker-compose exec seedmelab bash /scripts/install/setup.sh
```

#### Database notes
If you already have a  MySQL/MariaDB database server, use the following steps to create a database and a user with following privileges (refer to official [documentation](https://www.drupal.org/docs/installing-drupal/step-3-create-a-database)). Remove the db image as a dependency for seedmelab container in the docker-compose.yaml file and configure the docker environement file with variables noted in the seedmelab service.


## Using SeedMeLab
1. Visit your site at localhost:8080 or VIRTUAL_HOST address you provided (e.g. example.com).

2. Login to your site with username and password printed after the setup. Alternatively, fetch them using
```
    docker-compose exec seedmelab bash -c "cat /tmp/site_credentials.txt"
```
Note: This file will get deleted when container restarts.

3. Visit the Data page at http://localhost:8080/foldershare  or your_domain/foldershare

4. Watch SeedMeLab tutorials for getting started

    a. [Managing data](https://seedmelab.org/managing-data-on-seedmelab) on SeedMeLab for users(3mins)

    b. [Customizing SeedMeLab](https://seedmelab.org/customizing-seedmelab) for data manager (4 mins)

    c. [Managing data via REST client](https://seedmelab.org/managing-data-via-rest-client-on-seedmelab) for automation and power users (5 mins)


## Things for you todo 
1. Enable configure SMTP module for sending emails (e.g. for reset password). Current setup uses the server to send emails, however these will likely marked as spam. Typically, sites will set an independent email for the site, or get a free one from a provider like GMail.

2. Customize and configure your site as needed

3. Maintain and secure your site with

    a. Configuring logging access of the webserver

    b. Monthly updates to the containers

    c. Daily backups for code, database and site data
   
    d. First wednesday of each month, review and install Drupal's maintenance + feature updates 
    
    e. Third Wednesday of each month (except December, when its a week earlier) update security releases for Drupal core and contributed modules. 

4. Find all this too tedious, consider our [managed hosting](https://seedmelab.org) or choose from thousands of [vendors](https://www.drupal.org/drupal-services). But really you should choose us :), after all we created SeedMeLab.


## Getting started with Drupal
1. Read: [Drupal](https://www.drupal.org/docs/user_guide/en/index.html) provides extensive documentation for site administrators and web developers. 

2. Watch: [Short video tutorials](https://www.youtube.com/playlist?list=PLtaXuX0nEZk9MKY_ClWcPkGtOEGyLTyCO
) provide a solid understanding of Drupal.   
