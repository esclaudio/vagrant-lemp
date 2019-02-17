#!/bin/bash

MYSQL_USER=$1

if [ ! -d /home/vagrant/.provisioned ]; then
    mkdir /home/vagrant/.provisioned
fi

apt-get update

# Elimino Apache

if [ -d /etc/apache2 ] ; then
    apt-get purge -y apache2
    rm -rf /etc/apache2
fi

if [ ! -f /home/vagrant/.provisioned/.ohmyzsh ] ; then
    apt-get install -y zsh
    sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    touch /home/vagrant/.provisioned/.ohmyzsh
fi

# Nginx

if [ ! -f /home/vagrant/.provisioned/.nginx ] ; then
    apt-get install -y nginx
    touch /home/vagrant/.provisioned/.nginx
fi

# MySQL

if [ ! -f /home/vagrant/.provisioned/.mariadb ] ; then
    apt-get install -y mariadb-server mariadb-client
    
    echo "
        [mysqld] 
        bind-address = ::
    " >> /etc/mysql/mariadb.cnf

    touch /home/vagrant/.provisioned/.mariadb
fi

# PHP

if [ ! -f /home/vagrant/.provisioned/.php7 ] ; then
    apt-get install -y php php-fpm php-bcmath php-bz2 php-cli php-curl php-intl php-json php-mbstring php-opcache php-soap php-sqlite3 php-xml php-xsl php-zip php-mysql php-imagick php-gd
    touch /home/vagrant/.provisioned/.php7
fi

# Python 3 (pip)

if [ ! -f /home/vagrant/.provisioned/.python3 ] ; then
    apt-get install -y python3-pip
    touch /home/vagrant/.provisioned/.python3
fi

# WKHtml

if [ ! -f /home/vagrant/.provisioned/.wkhtml ] ; then
    apt-get install libxrender1 fontconfig xvfb xfonts-75dpi
    wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
    sudo dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb
    sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
	sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin
    touch /home/vagrant/.provisioned/.wkhtml
fi

# LibreOffice
if [ ! -f /home/vagrant/.provisioned/.libreoffice ] ; then
    apt-get install -y libreoffice-writer libreoffice-calc unoconv
    touch /home/vagrant/.provisioned/.libreoffice
fi

# ImageMagick

if [ ! -f /home/vagrant/.provisioned/.imagemagick ] ; then
    apt-get install -y imagemagick
    touch /home/vagrant/.provisioned/.imagemagick
fi

# Composer

if [ ! -f /home/vagrant/.provisioned/.composer ] ; then
    apt-get install -y curl unzip
    curl -sS https://getcomposer.org/installer -o composer-setup.php
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    touch /home/vagrant/.provisioned/.composer
fi

# Node

if [ ! -f /home/vagrant/.provisioned/.nodejs ] ; then
    curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
    bash nodesource_setup.sh
    apt-get install -y nodejs build-essential
    touch /home/vagrant/.provisioned/.nodejs
fi

# NPM / Yarn
if [ ! -f /home/vagrant/.provisioned/.nodejs ] ; then
    apt-get install -y npm
    apt-get install -y yarn
    touch /home/vagrant/.provisioned/.npm
fi

# Gulp

if [ ! -f /home/vagrant/.provisioned/.gulp ] ; then
    npm install gulp-cli -g
    touch /home/vagrant/.provisioned/.gulp
fi

# Redis

if [ ! -f /home/vagrant/.provisioned/.redis ] ; then
    apt-get install -y redis-server
    touch /home/vagrant/.provisioned/.redis
fi

# XDebug

if [ ! -f /home/vagrant/.provisioned/.xdebug ] ; then
    apt-get install -y xdebug

    if [ -f /etc/php/7.2/fpm/conf.d/20-xdebug.ini ] ; then
        echo "
            xdebug.remote_enable = 1
            xdebug.remote_connect_back = 1
            xdebug.remote_port = 9000
            xdebug.max_nesting_level = 512
        " >> /etc/php/7.2/fpm/conf.d/20-xdebug.ini
    fi
    
    touch /home/vagrant/.provisioned/.xdebug
fi

# npm install --no-bin-links # Vagrant on top of Windows. You cannot use symlinks.

# Acceso remoto a MySQL

find /etc/mysql -type f -name "*.cnf" -exec sed -i '/^bind-address/s/bind-address.*=.*/bind-address = ::/' {} +

# Usuario local de MySQL

mysql -u root -e "DROP USER IF EXISTS '$MYSQL_USER'@'localhost';";
mysql -u root -e "CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY 'secret';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'localhost' WITH GRANT OPTION;"

# Usuario remoto de MySQL

mysql -u root -e "DROP USER IF EXISTS '$MYSQL_USER'@'%';";
mysql -u root -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY 'secret';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;"

mysql -u root -e "FLUSH PRIVILEGES;"

# Reinicio MySQL

service mysql restart

# Habilito a Nginx a escribir en var/www
# Necesario para unoconv ya que crea un directorio .config en esta carpeta

chown -R www-data:www-data /var/www

# Elimino los Hosts virtuales creados anteriormente

rm /etc/nginx/sites-available/*
rm /etc/nginx/sites-enabled/*

# Reinicio nginx

service nginx restart

# Autoremove

apt-get autoremove -y
apt-get autoclean
