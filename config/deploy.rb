require 'bundler/capistrano'

set :user, "deploy"
set :application, "alaveteli"

set :scm, :git   # Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :repository,  "https://github.com/datauy/alaveteli.git"
set :git_enable_submodules, 1
set :branch, "master"
set :git_shallow_clone, 1
set :scm_verbose, true

role :web, "quesabes.org"                          # Your HTTP server, Apache/etc
role :app, "quesabes.org"                          # This may be the same as your `Web` server
role :db,  "quesabes.org", :primary => true # This is where Rails migrations will run

ssh_options[:user] = "deploy"
ssh_options[:forward_agent] = true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")]
set :use_sudo, true

set :deploy_to, "/home/gaba/quesabes"
set :deploy_via, :export
set :keep_releases, 3

# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  task :config_links do
    run "sudo ln -nfs #{shared_path}/system/config/database.yml #{release_path}/config/database.yml"
    run "sudo ln -nfs #{shared_path}/system/config/general.yml #{release_path}/config/general.yml"
    run "sudo ln -nfs #{shared_path}/system/config/i18n-routes.yml #{release_path}/config/i18n-routes.yml"
    run "sudo ln -nfs #{shared_path}/system/config/rails_env.rb #{release_path}/config/rails_env.rb"

    run "sudo rm -f -R #{release_path}/vendor/plugins/acts_as_xapian/xapiandbs"
    run "sudo ln -nfs #{shared_path}/system/xapiandbs/ #{release_path}/vendor/plugins/acts_as_xapian/xapiandbs"
    run "sudo ln -nfs #{shared_path}/system/files #{release_path}/files"
  end

  task :update_permissions do
      run "sudo chown -R www-data:deploy #{shared_path}"
      run "sudo chown -R www-data:deploy #{release_path}"
      run "sudo chmod -R ug+rw #{release_path}"
  end

  task :update_theme do
      run "cd #{release_path} && sudo #{release_path}/script/plugin install 'git://github.com/sebbacon/adminbootstraptheme.git'"
      run "cd #{release_path} && sudo #{release_path}/script/plugin install 'git://github.com/datauy/quesabes-theme.git'"
  end

  task :site_links do
    run "sudo ln -nfs #{release_path} /var/www/quesabes"
  end
end

# task to clean out all deployments (it keeps the last :keep_releases).
after "deploy:update", "deploy:cleanup"
after "deploy:update_code", "deploy:config_links"
after "deploy:config_links", "deploy:migrate"
after "deploy:migrate", "deploy:update_theme"
after "deploy:update_theme", "deploy:update_permissions"
after "deploy:create_symlink", "deploy:site_links"


# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
