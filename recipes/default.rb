#
# Cookbook:: php_simple_app - Version 2, fix 4 main bugs
# Recipe:: default
#
# Huy Hoang


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

# install yarn
execute 'install yarn' do
  command 'sudo npm install yarn -g'
  action :run
end

# install php 7.2
remote_file "/tmp/webtatic_repo_latest.rpm" do
    source "http://rpms.famillecollet.com/enterprise/remi-release-7.rpm"
    action :create
end

# install remi rpm
rpm_package 'remi-release-7' do
  source "/tmp/webtatic_repo_latest.rpm"
  action :install
end

# install php 7.2
execute "yum install php" do
  command "sudo yum --enablerepo=remi-php72 install php php-xml php-mbstring php-pdo php72-php-fpm -y"
  action :run
end

# install composer 
execute "install composer"  do
  command "sudo cd /tmp && (curl -sS https://getcomposer.org/installer | sudo php) && sudo mv composer.phar /bin/composer"
  action :run
end 

# create project folder run
directory '/var/app' do
  mode '0755'
  action :create
end

directory '/var/app/simplephpapp' do
  mode '0755'
  action :create
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

# install composer.json
bash 'install composer.json' do
  cwd '/var/app/simplephpapp'
  code <<-EOH
  composer update
  composer install
  EOH
end

execute "install depedencies" do
  command "php artisan key:generate"
  action :run
  cwd "/var/app/simplephpapp"
end

execute "yarn install" do
  command "yarn"
  action :run
  cwd "/var/app/simplephpapp"
end

# build static script
execute "build-static-script" do
  command "yarn run production"
  action :run
  cwd "/var/app/simplephpapp"
end

# copy the source code to apache root document folder
execute "copy source to httpd folder" do
  command "cp -rf /var/app/simplephpapp/* /var/www/html/"
  action :run
end

# give apache the access to the folder
execute "give access to apache" do
  command "chown -R apache:apache /var/www/html/"
  action :run
end

# change file security context for storage folder (in order to let the app write the log)
execute "give some more permission for storage logs folder" do 
  command "sudo chcon -t httpd_sys_rw_content_t /var/www/html/storage -R"
  action :run
end

# php.conf file for apache
file '/etc/httpd/conf.d/php.conf' do
  content '<FilesMatch \.php$>
    SetHandler "proxy:fcgi://127.0.0.1:9000" 
    </FilesMatch>'
  mode '0755'
end

# reassigned the root document for apache
execute "edit httpd config file" do
  command 'sed -i -e \'s/DocumentRoot \"\/var\/www\/html\"/DocumentRoot \"\/var\/www\/html\/public"/g\' /etc/httpd/conf/httpd.conf'
  action :run
end

# set default landpage for apache
execute "set default landpage for httpd" do  
  command 'sed -i -e \'s/DirectoryIndex\ index.html/DirectoryIndex\ index.php/g\' /etc/httpd/conf/httpd.conf'
  action :run
end

# adding extention to php.init file
execute "add extention to php.ini file" do
  command 'echo "extension=pdo.so \n extension=pdo_mysql.so" >> /etc/php.ini'
  action :run
end

# start php72-php-fpm service
execute "start php72-php-fpm service" do
  command "service php72-php-fpm start"
  action :run
end

# start the server, address: 127.0.0.1 or localhost
execute "start httpd service" do
  command 'service httpd start'
  action :run
end


