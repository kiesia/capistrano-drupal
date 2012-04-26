# Stage specific settings

set :branch, "dev"
set :deploy_to, "~/app/#{stage}.#{application}" 
after 'drupal:symlink', 'drupal_protected:symlink'
