#!/bin/bash

site=$1
folder=$2

declare -A aliases=$3
site_aliases=""
if [ -n "$3" ]; then
    for element in "${!aliases[@]}"
    do
        site_aliases="${site_aliases}
        # Alias ${element}

        location /${element} {
            alias ${aliases[$element]};
            try_files \$uri \$uri/ @${element};

            location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_param SCRIPT_FILENAME \$request_filename;
                fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
            }
        }

        location @${element} {
            rewrite /${element}/(.*)$ /${element}/index.php?/\$1 last;
        }
        "
    done
fi

echo "server {
        listen 80;
        listen [::]:80;

        root ${folder};

        index index.html index.htm index.php;
        
        server_name ${site};

        location / {
            try_files \$uri \$uri/ /index.php\$is_args\$args;
        }

        ${site_aliases}

        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        }

        location ~ /\.ht {
            deny all;
        }

        # Cache busting
        # read: github.com/h5bp/html5-boilerplate/wiki/Version-Control-with-Cachebusting

        location ~* (.+)\.(?:\d+)\.(min.js|min.css)$ {
            try_files \$uri \$1.\$2;
        }
}" > /etc/nginx/sites-available/$site.conf

sudo ln -s /etc/nginx/sites-available/$site.conf /etc/nginx/sites-enabled/

echo "El sitio ${site} fue configurado!"