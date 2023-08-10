#!/bin/bash

export DEBIAN_FRONTEND="noninteractive"

apt-get install -yq wget curl unzip debconf-utils lsb-release apt-transport-https ca-certificates software-properties-common gnupg

if [ ! -d /home/vagrant/.provisioned ]; then
    mkdir /home/vagrant/.provisioned
fi

# Nginx

if [ ! -f /home/vagrant/.provisioned/.nginx ] ; then
    echo "Installing NGINX"

    apt-get install -yq nginx

    # Habilito a Nginx a escribir en var/www
    # Necesario para unoconv ya que crea un directorio .config en esta carpeta

    chown -R www-data:www-data /var/www

    touch /home/vagrant/.provisioned/.nginx
fi

# MYSQL

if [ ! -f /home/vagrant/.provisioned/.mysql ] ; then
    echo "Installing MYSQL"

    wget https://repo.mysql.com//mysql-apt-config_0.8.26-1_all.deb
    dpkg -i mysql-apt-config_0.8.26-1_all.deb

    apt-get update && apt-get install -yq mysql-server

    # Acceso remoto a MySQL

    find /etc/mysql -type f -name "*.cnf" -exec sed -i '/^bind-address/s/bind-address.*=.*/bind-address = ::/' {} +

    # Usuario remoto de MySQL

    mysql -u root -e "DROP USER IF EXISTS 'vagrant'@'%';";
    mysql -u root -e "CREATE USER 'vagrant'@'%' IDENTIFIED BY 'secret';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'%' WITH GRANT OPTION;"

    service mysql restart

    touch /home/vagrant/.provisioned/.mysql
fi

# PHP

if [ ! -f /home/vagrant/.provisioned/.php ] ; then
    echo "Installing PHP"

    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
    
    apt-get update && apt-get install -yq php8.2 php8.2-{fpm,bcmath,xml,mysql,zip,intl,ldap,gd,imagick,bcmath,cli,bz2,curl,mbstring,pgsql,opcache,soap,cgi,xdebug,redis}
    
    echo "
        xdebug.idekey=VSCODE
        xdebug.mode=debug
        xdebug.start_with_request=yes
        xdebug.remote_autorestart = 1
        xdebug.client_port=9003
        xdebug.discover_client_host=1
        xdebug.max_nesting_level = 512
        xdebug.log_level=10
        xdebug.connect_timeout_ms=600
        xdebug.log=/var/log/xdebug/xdebug33.log
        xdebug.show_error_trace=true
    " >> /etc/php/8.2/fpm/conf.d/20-xdebug.ini
    
    mkdir /var/log/xdebug
    touch /var/log/xdebug/xdebug33.log
    chown -R www-data:www-data /var/log/xdebug

    touch /home/vagrant/.provisioned/.php
fi

# Composer

if [ ! -f /home/vagrant/.provisioned/.composer ] ; then
    echo "Installing COMPOSER"

    curl -sS https://getcomposer.org/installer -o composer-setup.php
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer

    touch /home/vagrant/.provisioned/.composer
fi

# Node

if [ ! -f /home/vagrant/.provisioned/.nodejs ] ; then
    echo "Installing NODE"

    curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -

    apt-get update && apt-get install -yq nodejs

    touch /home/vagrant/.provisioned/.nodejs
fi

# Puppeteer

if [ ! -f /home/vagrant/.provisioned/.puppeteer ] ; then
    echo "Installing PUPPETEER"

    apt-get install -yq gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils libgbm-dev libxshmfence-dev
    npm install --location=global --unsafe-perm puppeteer
    
    mv /root/.cache /var/www/.cache
    chown -R www-data:www-data /var/www/.cache

    touch /home/vagrant/.provisioned/.puppeteer
fi

# LibreOffice

if [ ! -f /home/vagrant/.provisioned/.libreoffice ] ; then
    echo "Installing LIBREOFFICE"

    apt-get install -yq libreoffice-writer libreoffice-calc unoconv
    touch /home/vagrant/.provisioned/.libreoffice
fi

# ImageMagick

if [ ! -f /home/vagrant/.provisioned/.imagemagick ] ; then
    echo "Installing IMAGEMAGICK"

    apt-get install -yq imagemagick
    touch /home/vagrant/.provisioned/.imagemagick
fi

# Redis

if [ ! -f /home/vagrant/.provisioned/.redis ] ; then
    echo "Installing REDIS"

    apt-get install -yq redis-server
    phpenmod -v 8.2 -s ALL redis
    touch /home/vagrant/.provisioned/.redis
fi

# npm install --no-bin-links # Vagrant on top of Windows. You cannot use symlinks.

rm /etc/nginx/sites-available/*
rm /etc/nginx/sites-enabled/*

service nginx restart