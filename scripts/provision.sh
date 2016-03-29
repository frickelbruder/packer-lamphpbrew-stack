#!/bin/bash

ECHOWRAPPER="==============================================\n\n%s\n\n==============================================\n"

#MySQL-Database - percona flavor
printf $ECHOWRAPPER "Installing Percona Mysql"
wget https://repo.percona.com/apt/percona-release_0.1-3.$(lsb_release -sc)_all.deb
dpkg -i percona-release_0.1-3.$(lsb_release -sc)_all.deb
apt-get update
apt-get install -y percona-server-server

#Apache2
printf $ECHOWRAPPER "Installing Apache"
apt-get install -y apache2-utils libapache2-mod-fastcgi
a2enmod actions fastcgi alias rewrite
a2dismod php5
service apache2 restart

#PHP
printf $ECHOWRAPPER "Installing PHPBrew"
apt-get build-dep php5
apt-get install -y php5 php5-dev php-pear autoconf automake curl libcurl3-openssl-dev build-essential libxslt1-dev re2c libxml2 libxml2-dev php5-cli bison libbz2-dev libreadline-dev
apt-get install -y libfreetype6 libfreetype6-dev libpng12-0 libpng12-dev libjpeg-dev libjpeg8-dev libjpeg8  libgd-dev libgd3 libxpm4 libltdl7 libltdl-dev
apt-get install -y libssl-dev openssl
apt-get install -y gettext libgettextpo-dev libgettextpo0
apt-get install -y libicu-dev
apt-get install -y libmhash-dev libmhash2
apt-get install -y libmcrypt-dev libmcrypt4
apt-get install -y mysql-server mysql-client libmysqlclient-dev libmysqld-dev


printf $ECHOWRAPPER Installing PHPBrew
curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew
chmod +x phpbrew
mv phpbrew /usr/local/bin/phpbrew

printf $ECHOWRAPPER "Installing default PHP-Version (PHP 5.6)"
sudo -i
export PHPBREW_ROOT=/opt/phpbrew
export PHPBREW_HOME=/opt/phpbrew

phpbrew init
echo "export PHPBREW_ROOT=/opt/phpbrew" >> ~/.phpbrew/init
echo "export PHPBREW_HOME=/opt/phpbrew" >> ~/.phpbrew/init
source /opt/phpbrew/bashrc

phpbrew install 5.6.19 +cli +mysql +mcrypt +gd +fpm +opcache +default

echo "export PHPBREW_ROOT=/opt/phpbrew" >> /etc/bash.bashrc
echo "export PHPBREW_HOME=/opt/phpbrew" >> /etc/bash.bashrc
echo "source /opt/phpbrew/bashrc" >> /etc/bash.bashrc

chown -R root: /opt/phpbrew    
sed -i 's/ = nobody/ = www-data/' /opt/phpbrew/php/php-5.6.19/etc/php-fpm.conf                               

phpbrew switch 5.6.19 
phpbrew ext install xdebug stable
phpbrew fpm start

echo "phpbrew fpm start" >> /etc/rc.local
   
##PHPDEVELOPMENT
###PHPUNIT
printf $ECHOWRAPPER "Installing Phpunit"
wget https://phar.phpunit.de/phpunit.phar
mv phpunit.phar /usr/local/bin/phpunit.phar
chmod a+x /usr/local/bin/phpunit.phar
ln -s /usr/local/bin/phpunit.phar /usr/local/bin/phpunit

###COMPOSER
printf $ECHOWRAPPER "Installing Composer"
php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php
php -r "if (hash('SHA384', file_get_contents('composer-setup.php')) === '41e71d86b40f28e771d4bb662b997f79625196afcca95a5abf44391188c695c6c1456e16154c75a211d238cc3bc5cb47') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer.phar
ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

###PHPAB
printf $ECHOWRAPPER "Installing phpab"
wget https://github.com/theseer/Autoload/releases/download/1.21.0/phpab-1.21.0.phar
mv phpab-1.21.0.phar /usr/local/bin/phpab.phar
chmod a+x /usr/local/bin/phpab.phar
ln -s /usr/local/bin/phpab.phar /usr/local/bin/phpab

#phpmyadmin
printf $ECHOWRAPPER "Installing PHPMyAdmin"
printf $ECHOWRAPPER "Setting PHPMyAdmin debconf settings"
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean false '
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-reinstall boolean false '
debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/internal/skip-preseed boolean true '
printf $ECHOWRAPPER "Doing the install"
apt-get install -y phpmyadmin

#Ruby (required for compass)
printf $ECHOWRAPPER "Installing Ruby"
apt-get -y install ruby

#Compass
printf $ECHOWRAPPER "Installing Compass"
gem install compass

#NodeJS/NPM
printf $ECHOWRAPPER "Installing Node/NPM"
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
apt-get install -y nodejs

#Bower
printf $ECHOWRAPPER "Installing Bower"
npm install -g bower