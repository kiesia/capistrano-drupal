# Stage specific settings

set :deploy_to, "~/app/#{stage}.#{application}" 
after 'drupal:symlink', 'drupal_protected:symlink'
