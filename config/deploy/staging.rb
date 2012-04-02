# Stage specific settings

set :deploy_to, "/www/352381_10997/app/#{stage}.#{application}" 
after 'drupal:symlink', 'drupal_protected:symlink'
