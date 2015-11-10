# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'youtube_tonight'
set :repo_url, 'git@github.com:allhailskippy/youtube_tonight.git'

set :user, 'allhailskippy_vps1'  # Your dreamhost account's username
set :domain, 'youtube_tonight.thatsps.com'  # Dreamhost servername where your account is located 
set :tmp_dir, '/home/allhailskippy_vps1/tmp'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/allhailskippy_vps1/youtubetonight.thatsps.com"  # The standard Dreamhost setup

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/environments/credentials.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

after 'deploy:publishing', 'deploy:restart'

namespace :deploy do
  task :restart do
    on roles(fetch(:web)) do
      execute "touch #{ current_path }/tmp/restart.txt"
    end
  end

  desc "reload the database with seed data"
  task :seed do
    on primary :db do
      within current_path do
        with rails_env: fetch(:stage) do
          execute :rake, 'db:seed'
        end
      end
    end
  end
end

namespace :upload do
  desc "Copy database.yml file to server(s)"
  task :database_yml do
    on roles(fetch(:web)) do
      execute "mkdir -p #{shared_path}/config"
      file_name = File.join("config", "database.#{fetch(:rails_env)}.yml")
      file_name = File.join("config", "database.yml") unless File.exists?(file_name)
      upload! file_name, "#{shared_path}/config/database.yml"
    end
  end

  desc "Copy creadentials.yml file to server(s)"
  task :credentials_yml do
    on roles(fetch(:web)) do
      execute "mkdir -p #{shared_path}/config/environments"
      file_name = File.join("config", "environments", "credentials.#{fetch(:rails_env)}.yml")
      file_name = File.join("config", "environments", "credentials.yml") unless File.exists?(file_name)
      upload! file_name, "#{shared_path}/config/environments/credentials.yml"
    end
  end
end
