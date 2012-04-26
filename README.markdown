Capistrano-Drupal
=================

This is a basic recipe for Drupal deployment with Capistrano. Currently this 
handles Drupal multisite installs and compiles SASS.

This recipe assumes that we are running the webserver with the same rights
as the deployment user.

Requirements
------------

The standard environment for capistrano deployment, plus:

+ Drush on the deployment server
+ The folowing extra rubygems:
  + capsitrano-ext
  + railsless-deploy

Setup process
-------------

Setup is largely automated, just open a terminal in your project root and 
enter `cap stage deploy:setup`

Where 'stage' is your target stage, such as _staging_ or _production_. This will:

+ create an app directory, prefixed with the stage name
+ created directories for shared files, such as files and .htaccess (on _staging_)

Database deployment must be made by hand.

*TODO* add check for htaccess file in shared files dir. 

*TODO* upload a .htaccess file with password protection when setting up _staging_.

Deploy process
--------------

To deploy, just open a terminal in the project root directory and enter
`cap stage deploy`

This will deploy new code, compile SASS and clear the drupal cache with drush.

*TODO* add `drush updb` with rollback
