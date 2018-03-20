#
# Cookbook:: php_simple_app
# Recipe:: default
#
# Huy Hoang

# create php user
user 'php' do
  comment 'php user'
  uid '1001'
  home '/home/php/'
  shell '/bin/bash'
  password 'aSimplePassword'
end

# update & upgrade yum 
execute "update-upgrade" do
  command "sudo yum update -y && sudo yum upgrade -y"
  action :run
end


# install autoconf
execute 'install development tools' do
  command 'sudo yum groupinstall "Development tools" -y'
  action :run
end

# I did not see the node version requirement, let it be 8 then
execute 'nodejs' do
  command "curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash - && sudo yum install -y nodejs"
  action :run
end

# install php 7.2
execute "install Remi repository" do
  command "sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm"
  action :run
end

execute "yum install php" do
  command "sudo yum --enablerepo=remi-php72 install php php-mbstring php-pdo -y"
  action :run
end

# install composer 
execute "install composer"  do
  command "sudo cd /tmp && (curl -sS https://getcomposer.org/installer | sudo php) && sudo mv composer.phar /bin/composer"
  action :run
end 

# create project folder
directory '/var/app/simplephpapp' do
  owner 'php'
  mode '0755'
  action :create
end

# create project folder
directory '/var/log/php' do
  owner 'php'
  mode '0755'
  action :create
end

# pull the project
git "/var/app/simplephpapp" do
  repository "https://github.com/Saritasa/simplephpapp.git"
  reference "master"
  action :sync
  destination "/var/app/simplephpapp"
  user 'php'
end

# set up .env file
file '/var/app/simplephpapp/.env' do
  content 'APP_NAME="simple-project"
     APP_ENV=local
     APP_DEBUG=true
     APP_KEY=
     APP_URL=http://url
     APP_LOG_LEVEL=debug

     CACHE_DRIVER=file
     SESSION_DRIVER=file
     QUEUE_DRIVER=sync

     REDIS_HOST=null
     REDIS_PASSWORD=null
     REDIS_PORT=null'
  mode '0755'
  owner 'php'
end

# install composer.json
execute "composer install" do
  command "cd /var/app/simplephpapp && composer install"
  user 'php'
  action :run
end

execute "install depedencies" do
  command "cd /var/app/simplephpapp && php artisan key:generate"
  user 'php'
  action :run
end

execute "npm install" do
  command "cd /var/app/simplephpapp && npm install"
  user 'php'
  environment ({'HOME' => '/home/php'})
  action :run
end

# build static script
execute "build-static-script" do
  command "cd /var/app/simplephpapp && npm run production"
  user 'php'
  action :run
end

# run the website, port 8000
execute "run the web" do
  command "cd /var/app/simplephpapp/public && nohup php -S localhost:8000 > /var/log/php/run.log 2>&1"
  user 'php'
  action :run
end

