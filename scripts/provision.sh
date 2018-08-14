#!/bin/bash

function package_exists() {
    dpkg -l "$1" &> /dev/null
}

MYSQL_USER=$1

if ! package_exists 'apache2' ; then
    apt-get purge -y apache2 apache2-utils apache2.2-bin apache2-common
fi

if [ -d /etc/apache2 ] ; then
    rm -rf /etc/apache2
fi

# Nginx

if ! package_exists 'nginx' ; then
    apt-get install -y nginx
fi

# MySQL

if ! package_exists 'mariadb-server' ; then
    apt-get install -y mariadb-server mariadb-client
fi

# PHP

if ! package_exists 'php' ; then
    apt-get install -y php php-fpm php-bcmath php-bz2 php-cli php-curl php-intl php-json php-mbstring php-opcache php-soap php-sqlite3 php-xml php-xsl php-zip php-mysql php-imagick php-gd
fi

# Python 3 (pip)

if ! package_exists 'python3' ; then
    apt-get install -y python3-pip
fi

# WKHtml

if [ ! -f /usr/bin/wkhtmltopdf ]; then
    apt-get install libxrender1 fontconfig xvfb
    wget https://downloads.wkhtmltopdf.org/0.12/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz -P /tmp/
    cd /opt/
    tar xf /tmp/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
    ln -s /opt/wkhtmltox/bin/wkhtmltopdf /usr/bin/wkhtmltopdf
fi

# LibreOffice
if ! package_exists 'libreoffice' ; then
    apt-get install -y libreoffice-writer libreoffice-calc unoconv
fi

# ImageMagick

if ! package_exists 'imagemagick' ; then
    apt-get install -y imagemagick
fi

# Composer

if [ ! -f /usr/local/bin/composer ]; then
    apt-get install -y curl unzip
    curl -sS https://getcomposer.org/installer -o composer-setup.php
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
fi

# Node

if ! package_exists 'nodejs' ; then
    curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
    bash nodesource_setup.sh
    apt-get install -y nodejs build-essential
    apt-get install -y npm
fi

# Gulp

npm install gulp-cli -g

# npm install --no-bin-links # Vagrant on top of Windows. You cannot use symlinks.

# Acceso remoto a MySQL

find /etc/mysql -type f -name "*.cnf" -exec sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' {} +

# Usuario local de MySQL

mysql -u root -e "DROP USER IF EXISTS '$MYSQL_USER'@'localhost';";
mysql -u root -e "CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY 'secret';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'localhost' WITH GRANT OPTION;"

# Usuario remoto de MySQL

mysql -u root -e "DROP USER IF EXISTS '$MYSQL_USER'@'%';";
mysql -u root -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY 'secret';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;"

mysql -u root -e "FLUSH PRIVILEGES;"

service mysql restart

# Habilito a Nginx a escribir en var/www
# Necesario para unoconv ya que crea un directorio .config en esta carpeta

chown -R www-data:www-data /var/www

# Elimino los Hosts virtuales creados anteriormente

rm /etc/nginx/sites-available/*
rm /etc/nginx/sites-enabled/*

# Reinicio Nginx para que la configuración tome efecto

apt-get autoremove
apt-get autoclean
apt-get -f install
