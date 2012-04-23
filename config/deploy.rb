# Settings

# set deployment stages
set :stages, %w(production staging dev)
set :default_stage, "staging"

# multisite uri's for symlinking and drush, leave at least default in place
# set :sites, %w(default, site1.example.com, site2.example.com)
set :sites, %w(default)

# themes based on SASS which require compilation
# set :sass_themes, %(zen)

# SSH settings
set :domain,  "example.com" 
set :user,    "example-user" 
 
# Application settings
set :application, "example" 
set :www_user, "www-data"

set :copy_exclude, ["Capfile", "config", ".git", ".gitignore", ".gitmodules", "sites/*/files/", "sites/*/settings.php", "sites/*/settings-dev.php"] 
set :repository, "git@github.com:example/example.git"
set :scm, :git
set :branch, "master"
set :scm_verbose, false
set :git_enable_submodules, 1

server "#{domain}", :app, :web, :db, :primary => true 
 
set :deploy_via, :remote_cache
set :use_sudo, false
set :keep_releases, 5
ssh_options[:paranoid] = false 
ssh_options[:forward_agent] = true

# Drush command, full path and php settings may have to go here (see drush README.txt)
set :drush, 'drush'

# Drupal specific methods
# after 'deploy:setup', 'drupal:setup'
after 'deploy:setup', 'drupal:setup', 'drupal:setup_ownership'
after 'deploy:symlink', 'drupal:symlink', 'drupal:clear_cache'
before 'deploy:cleanup', 'drupal:permission_fix'

namespace :drupal do
  desc <<-DESC
  symlinks shared files dirs and settings.php files
  DESC
  task :symlink, :except => { :no_release => true } do
    sites.each do |dir|
      run "#{try_sudo} ln -s #{shared_path}/#{dir}/files #{latest_release}/sites/#{dir}/files"
      run "#{try_sudo} ln -s #{latest_release}/sites/#{dir}/settings-#{stage}.php #{latest_release}/sites/#{dir}/settings.php"
    end
  end
  
  desc <<-DESC
  fixes permissions so old deploys can be deleted
  DESC
  task :permission_fix, :except => { :no_release => true } do
    count = fetch(:keep_releases, 5).to_i
    if count >= releases.length
      logger.info "no permissions to fix"
    else
      logger.info "fixing permissions"

      directories = (releases - releases.last(count)).map { |release|
        File.join(releases_path, release) }.join(" ")

      run "chmod -R +w #{directories}"
    end
  end
  
  desc <<-DESC
  clears caches with drupal
  DESC
  task :clear_cache, :except => { :no_release => true } do
    sites.each do |dir|
      logger.info "clearing drupal cache for #{dir}"
      run "#{try_sudo} #{drush} -r #{latest_release} -l http://#{dir} --quiet cc all"
    end
  end

  desc <<-DESC
  compiles sass/scss files with compass (we are assuming that all multisite sites use the same theme)
  DESC
  task :compass_compile, :except => { :no_release => true } do
    sass_themes.each do |theme|
      logger.info "compiling sass files for #{theme} theme"
      run "#{try_sudo} #{drush} -r #{latest_release} --quiet compass-compile #{theme}"
    end
  end
  
  desc <<-DESC
  creates shared drupal directories
  DESC
  task :setup do
    sites.each do |dir|
      run "mkdir -p #{shared_path}/#{dir}/files"
    end
  end
end

namespace :drupal_protected do
  task :symlink, :except => { :no_release => true } do
    # We keep a local copy of the .htaccess on the server because we have htpasswd to worry about 
    logger.info "linking .htaccess"
    run "rm -f #{latest_release}/.htaccess"
    run "ln -s #{shared_path}/htaccess #{latest_release}/.htaccess"
  end
end

# this tells capistrano what to do when you deploy
namespace :deploy do 
 
  desc <<-DESC
  A macro-task that updates the code and fixes the symlink. 
  DESC
  task :default do 
    transaction do 
      update_code
      symlink
    end
  end
 
  task :update_code, :except => { :no_release => true } do 
    on_rollback { run "rm -rf #{release_path}; true" } 
    strategy.deploy! 
  end
  
  after 'deploy' do
    cleanup
  end
end
