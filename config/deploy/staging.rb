# Stage specific settings

set :deploy_to, "/var/www/app/#{stage}.#{application}" 
after 'drupal:symlink', 'drupal_protected:symlink'
