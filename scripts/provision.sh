#!/bin/bash

MYSQL_USER=$1

sudo apt-get update

if [ ! -d /home/vagrant/.provisioned ]; then
    mkdir /home/vagrant/.provisioned
fi

# Nginx

if [ ! -f /home/vagrant/.provisioned/.nginx ] ; then
    echo "Installig NGINX"

    DEBIAN_FRONTEND=noninteractive apt-get install -yq nginx
    touch /home/vagrant/.provisioned/.nginx
fi

# MARIADB

if [ ! -f /home/vagrant/.provisioned/.mariadb ] ; then
    echo "Installig MARIADB"

    DEBIAN_FRONTEND=noninteractive apt-get install -yq mariadb-server mariadb-client
    
    echo "
        [mysqld] 
        bind-address = ::
    " >> /etc/mysql/mariadb.cnf

    touch /home/vagrant/.provisioned/.mariadb
fi

# PHP

if [ ! -f /home/vagrant/.provisioned/.php7 ] ; then
    echo "Installig PHP"

    DEBIAN_FRONTEND=noninteractive apt-get install -yq php php-{bcmath,xml,fpm,mysql,zip,intl,ldap,gd,imagick,bcmath,cli,bz2,curl,mbstring,pgsql,opcache,soap,cgi,sqlite3}
    touch /home/vagrant/.provisioned/.php7
fi

if [ ! -f /home/vagrant/.provisioned/.php8 ] ; then
    DEBIAN_FRONTEND=noninteractive apt-get install -yq software-properties-common && add-apt-repository ppa:ondrej/php -y
    DEBIAN_FRONTEND=noninteractive apt-get install -yq php8.1-{bcmath,xml,fpm,mysql,zip,intl,ldap,gd,imagick,bcmath,cli,bz2,curl,mbstring,pgsql,opcache,soap,cgi}

    touch /home/vagrant/.provisioned/.php8
fi

# Node

if [ ! -f /home/vagrant/.provisioned/.nodejs ] ; then
    echo "Installig NODE"

    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -

    touch /home/vagrant/.provisioned/.nodejs
fi

# Puppeteer

if [ ! -f /home/vagrant/.provisioned/.puppeteer ] ; then
    echo "Installig PUPPETEER"

    DEBIAN_FRONTEND=noninteractive apt-get install -yq nodejs gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget libgbm-dev libxshmfence-dev
    npm install --global --unsafe-perm puppeteer
    chmod -R o+rx /usr/lib/node_modules/puppeteer/.local-chromium

    touch /home/vagrant/.provisioned/.puppeteer
fi

# LibreOffice

if [ ! -f /home/vagrant/.provisioned/.libreoffice ] ; then
    echo "Installig LIBREOFFICE"

    DEBIAN_FRONTEND=noninteractive apt-get install -yq libreoffice-writer libreoffice-calc unoconv
    touch /home/vagrant/.provisioned/.libreoffice
fi

# ImageMagick

if [ ! -f /home/vagrant/.provisioned/.imagemagick ] ; then
    echo "Installig IMAGEMAGICK"

    DEBIAN_FRONTEND=noninteractive apt-get install -yq imagemagick
    touch /home/vagrant/.provisioned/.imagemagick
fi

# Composer

if [ ! -f /home/vagrant/.provisioned/.composer ] ; then
    echo "Installig COMPOSER"

    DEBIAN_FRONTEND=noninteractive apt-get install -yq curl unzip

    curl -sS https://getcomposer.org/installer -o composer-setup.php
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer

    touch /home/vagrant/.provisioned/.composer
fi

# Redis

if [ ! -f /home/vagrant/.provisioned/.redis ] ; then
    echo "Installig REDIS"

    DEBIAN_FRONTEND=noninteractive apt-get install -yq redis-server php-redis
    touch /home/vagrant/.provisioned/.redis
fi

# XDebug

if [ ! -f /home/vagrant/.provisioned/.xdebug ] ; then
    echo "Installig XDEBUG"

    DEBIAN_FRONTEND=noninteractive apt-get install -yq php-xdebug

    if [ -f /etc/php/7.4/fpm/conf.d/20-xdebug.ini ] ; then
        echo "
            xdebug.remote_enable = 1
            xdebug.remote_connect_back = 1
            xdebug.remote_port = 9000
            xdebug.max_nesting_level = 512
        " >> /etc/php/7.4/fpm/conf.d/20-xdebug.ini
    fi
    
    touch /home/vagrant/.provisioned/.xdebug
fi

# Default PHP version

update-alternatives --set php /usr/bin/php7.4

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
