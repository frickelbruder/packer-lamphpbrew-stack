#!/bin/bash

ECHOWRAPPER="==============================================\n\n%s\n\n==============================================\n"

#GIT
printf $ECHOWRAPPER "Installing GIT"
apt-get install -y git 

#MySQL-Database - percona flavor
printf $ECHOWRAPPER "Installing Percona Mysql"
wget https://repo.percona.com/apt/percona-release_0.1-3.$(lsb_release -sc)_all.deb
dpkg -i percona-release_0.1-3.$(lsb_release -sc)_all.deb
apt-get update
apt-get install -y percona-server-server

#Apache2
printf $ECHOWRAPPER "Installing Apache"
apt-get install -y apache2 apache2-utils libapache2-mod-fastcgi
a2enmod actions fastcgi alias rewrite ssl
a2ensite default-ssl
echo 'umask 002' >> /etc/apache2/envvars
usermod -g www-data vagrant
service apache2 restart


#PHP
printf $ECHOWRAPPER "Installing PHPBrew"
apt-get build-dep php5
apt-get install -y php5 php5-dev php-pear autoconf automake curl libcurl3-openssl-dev build-essential libxslt1-dev re2c libxml2 libxml2-dev php5-cli bison libbz2-dev libreadline-dev \
            libfreetype6 libfreetype6-dev libpng12-0 libpng12-dev libjpeg-dev libjpeg8-dev libjpeg8  libgd-dev libgd3 libxpm4 libltdl7 libltdl-dev \
             libssl-dev openssl \
             gettext libgettextpo-dev libgettextpo0 \
             libicu-dev \
             libmhash-dev libmhash2 \
             libmcrypt-dev libmcrypt4 \
             libmysqlclient-dev libmysqld-dev
a2dismod php5


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
   
##PHPDEVELOPMENT
### PHP konfigurieren
printf $ECHOWRAPPER "Configuring PHP"
cd ~
wget https://github.com/frickelbruder/php-ini-setter/releases/download/1.1.2/php-ini-setter.phar
chmod a+x php-ini-setter.phar
./php-ini-setter.phar --name short_open_tag --value On --file /etc/php5/apache2/php.ini
./php-ini-setter.phar --name memory_limit --value 512M --file /etc/php5/apache2/php.ini
./php-ini-setter.phar --name log_errors --value On --file /etc/php5/apache2/php.ini
./php-ini-setter.phar --name error_log --value /var/log/php_errors.log --file /etc/php5/apache2/php.ini
./php-ini-setter.phar --name max_execution_time --value 120 --file /etc/php5/apache2/php.ini
./php-ini-setter.phar --name date.timezone --value Europe/Berlin --file /etc/php5/apache2/php.ini

./php-ini-setter.phar --name short_open_tag --value On --file /etc/php5/cli/php.ini
./php-ini-setter.phar --name memory_limit --value 512M --file /etc/php5/cli/php.ini
./php-ini-setter.phar --name log_errors --value On --file /etc/php5/cli/php.ini
./php-ini-setter.phar --name error_log --value /var/log/php_errors.log --file /etc/php5/cli/php.ini
./php-ini-setter.phar --name max_execution_time --value 120 --file /etc/php5/cli/php.ini
./php-ini-setter.phar --name date.timezone --value Europe/Berlin --file /etc/php5/cli/php.ini

./php-ini-setter.phar --name short_open_tag --value On --file /opt/phpbrew/php/php-5.6.19/etc/php.ini
./php-ini-setter.phar --name memory_limit --value 512M --file /opt/phpbrew/php/php-5.6.19/etc/php.ini
./php-ini-setter.phar --name log_errors --value On --file /opt/phpbrew/php/php-5.6.19/etc/php.ini
./php-ini-setter.phar --name error_log --value /var/log/php_errors.log --file /opt/phpbrew/php/php-5.6.19/etc/php.ini
./php-ini-setter.phar --name max_execution_time --value 120 --file /opt/phpbrew/php/php-5.6.19/etc/php.ini
./php-ini-setter.phar --name date.timezone --value Europe/Berlin --file /opt/phpbrew/php/php-5.6.19/etc/php.ini

touch /var/log/php_errors.log
chmod 0777 /var/log/php_errors.log


###PHPUNIT
printf $ECHOWRAPPER "Installing Phpunit"
wget https://phar.phpunit.de/phpunit.phar
mv phpunit.phar /usr/local/bin/phpunit.phar
chmod a+x /usr/local/bin/phpunit.phar
ln -s /usr/local/bin/phpunit.phar /usr/local/bin/phpunit

###COMPOSER
printf $ECHOWRAPPER "Installing Composer"
php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php
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
sed -i 's~ //\(.*AllowNoPassword.*\)~\1~1' /etc/phpmyadmin/config.inc.php
sed -i "s~'cookie';~'config';~1" /etc/phpmyadmin/config.inc.php
sed -i "s~= \$dbuser;~= 'root';~1" /etc/phpmyadmin/config.inc.php
sed -i "s~= \$dbpass;~= '';~1" /etc/phpmyadmin/config.inc.php
sed -i "s~= \$dbserver;~= '127.0.0.1';~1" /etc/phpmyadmin/config.inc.php


#Ruby (required for compass)
printf $ECHOWRAPPER "Installing Ruby"
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm requirements
rvm install ruby-head
rvm use ruby-head --default 

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

exit 0