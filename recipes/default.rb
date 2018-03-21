#
# Cookbook:: php_simple_app
# Recipe:: default
#
# Huy Hoang

# create php user
user 'php' do
  comment 'php user'
  uid '1001'
  shell '/bin/bash'
end

directory '/home/php' do
  mode '0755'
  action :create
  user 'php'
end

# update & upgrade yum 
execute "update-upgrade" do
  command "sudo yum update -y && sudo yum upgrade -y && sudo yum install epel-release -y"
  action :run
end


# install autoconf
execute 'install development tools' do
  command 'sudo yum groupinstall "Development tools" -y && sudo yum install nasm libpng-devel -y'
  action :run
end

# I did not see the node version requirement, let it be 8 then
execute 'nodejs' do
  command "curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash - && sudo yum install -y nodejs"
  action :run
end

# install php 7.2
#execute "install Remi repository" do
#  command "sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm"
#  action :run
#end

execute "yum install php" do
  command "sudo yum --enablerepo=remi-php72 install php php-xml php-mbstring -y"
  action :run
end

# install composer 
execute "install composer"  do
  command "sudo cd /tmp && (curl -sS https://getcomposer.org/installer | sudo php) && sudo mv composer.phar /bin/composer"
  action :run
end 

# create project folder run
directory '/var/app' do
  user 'php'
  mode '0755'
  action :create
end

directory '/var/app/simplephpapp' do
  mode '0755'
  action :create
  user 'php'
end



# pull the project
git "/var/app/simplephpapp" do
  repository "https://github.com/Saritasa/simplephpapp.git"
  reference "develop"
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
  user 'php'
end

# set up service file to start php server
file '/etc/systemd/system/php.service' do
  content '
  [Unit]
  Description=php
  After=network.target

  [Service]
  PIDFile=/run/php.pid
  User=php
  ExecStartPre=/usr/bin/rm -f /run/php.pid
  ExecStart=/usr/bin/nohup /usr/bin/php -S localhost:8000  /var/app/simplephpapp/public/index.php > /var/log/php.log 2>&1 &
  KillSignal=SIGQUIT
  TimeoutStopSec=5
  KillMode=process
  PrivateTmp=true

  [Install]
  WantedBy=multi-user.target
  '
  mode '0755'
end

# install composer.json

bash 'install composer.json' do
  user 'php'
  cwd '/var/app/simplephpapp'
  environment 'HOME' => '/home/php/' 
  code <<-EOH
  composer update
  composer install
  EOH
end

execute "install depedencies" do
  command "php artisan key:generate"
  action :run
  user 'php'
  cwd "/var/app/simplephpapp"
  not_if 'grep adam /etc/passwd', :user => 'php'
end

execute "npm install" do
  command "npm install"
  not_if 'grep adam /etc/passwd', :user => 'php' 
  environment ({'HOME' => '/home/php'})
  action :run
  user 'php'
  cwd "/var/app/simplephpapp"
end

# build static script
execute "build-static-script" do
  command "npm run production"
  action :run
  user 'php'
  cwd "/var/app/simplephpapp"
end

# run the website, port 8000
service "php" do
  action :start
end
