#!/bin/bash

MYSQL_USER=$1

sudo apt update

if [ ! -d /home/vagrant/.provisioned ]; then
    mkdir /home/vagrant/.provisioned
fi

# Nginx

if [ ! -f /home/vagrant/.provisioned/.nginx ] ; then
    echo "Installig NGINX"

    DEBIAN_FRONTEND=noninteractive apt-get install -yq nginx
    touch /home/vagrant/.provisioned/.nginx
fi

# MySQL

if [ ! -f /home/vagrant/.provisioned/.mariadb ] ; then
    echo "Installig MYSQL"

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

    DEBIAN_FRONTEND=noninteractive apt-get install -yq php php-fpm php-bcmath php-bz2 php-cli php-curl php-intl php-json php-mbstring php-opcache php-soap php-sqlite3 php-xml php-xsl php-zip php-mysql php-imagick php-gd
    touch /home/vagrant/.provisioned/.php7
fi

# Python 3 (pip)

if [ ! -f /home/vagrant/.provisioned/.python3 ] ; then
    echo "Installig PYTHON"

    DEBIAN_FRONTEND=noninteractive apt-get install -yq python3-pip
    touch /home/vagrant/.provisioned/.python3
fi

# WKHtml

if [ ! -f /home/vagrant/.provisioned/.wkhtml ] ; then
    echo "Installig WKHTML"

    DEBIAN_FRONTEND=noninteractive apt-get install -yq libxrender1 fontconfig xvfb xfonts-75dpi

    wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb
    sudo dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb
    sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
	sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin

    touch /home/vagrant/.provisioned/.wkhtml
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

# Node

if [ ! -f /home/vagrant/.provisioned/.nodejs ] ; then
    echo "Installig NODE"

    curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
    
    DEBIAN_FRONTEND=noninteractive apt-get install -yq nodejs

    touch /home/vagrant/.provisioned/.nodejs
fi

# NPM / Yarn / Gulp

if [ ! -f /home/vagrant/.provisioned/.npm ] ; then
    echo "Installig YARN/GULP"

    npm install -g npm
    npm install -g yarn
    npm install -g gulp-cli
    
    touch /home/vagrant/.provisioned/.npm
fi

# Redis

if [ ! -f /home/vagrant/.provisioned/.redis ] ; then
    echo "Installig REDIS"

    DEBIAN_FRONTEND=noninteractive apt-get install -yq redis-server
    touch /home/vagrant/.provisioned/.redis
fi

# XDebug

if [ ! -f /home/vagrant/.provisioned/.xdebug ] ; then
    echo "Installig XDEBUG"

    DEBIAN_FRONTEND=noninteractive apt-get install -yq php-xdebug

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
