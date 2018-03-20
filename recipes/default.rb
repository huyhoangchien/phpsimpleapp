#
# Cookbook:: php_simple_app
# Recipe:: default
#
# Huy Hoang

# update & upgrade yum first
execute "update-upgrade" do
  command "sudo yum update -y && sudo yum upgrade -y"
  action :run
end


# install autoconf
execute 'intall autoconf' do
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
  returns 1
end

execute "yum install php" do
  command "sudo yum --enablerepo=remi-php72 install php php-mbstring php-pdo -y"
  action :run
end

# install composer 
execute "install composer"  do
  command "sudo cd /tmp && (curl -sS https://getcomposer.org/installer | sudo php) && sudo mv composer.phar /usr/local/bin/composer"
  action :run
end 

# pull the project
git "/var/app/simplephpapp" do
  repository "https://github.com/Saritasa/simplephpapp.git"
  reference "develop"
  action :sync
  destination "/var/app/simplephpapp"
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
end

# composer install
execute "composer install" do
  command "cd /var/app/simplephpapp && composer install"
  action :run
end

execute "install depedencies" do
  command "cd /var/app/simplephpapp && php artisan key:generate"
  action :run
end

execute "npm install" do
  command "cd /var/app/simplephpapp && npm install"
  action :run
end

# build static script
execute "build-static-script" do
  command "cd /var/app/simplephpapp && npm run production"
  action :run
end

