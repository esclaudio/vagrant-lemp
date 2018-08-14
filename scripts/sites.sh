site=$1
folder=$2

declare -A aliases=$3
aliasesTXT=""
if [ -n "$3" ]; then
    for element in "${!aliases[@]}"
    do
        aliasesTXT="${aliasesTXT}
            Alias /${element} ${aliases[$element]}
                <Directory \"${aliases[$element]}\">
                        Options Indexes FollowSymLinks
                        AllowOverride All
                        Require all granted
                </Directory>
        "
    done
fi

echo "server {
        listen 80;
        root ${folder};
        index index.php;
        server_name ${site};

        location / {
            try_files \$uri /index.php\$is_args\$args;
        }

        location ~ \.php\$ {
            try_files \$uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
            fastcgi_param SCRIPT_NAME \$fastcgi_script_name;
            fastcgi_index index.php;
            fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        }

        location ~ /\.ht {
            deny all;
        }

        location ~* (.+)\.(?:\d+)\.(min.js|min.css)$ {
            try_files \$uri \$1.\$2;
        }
}" > /etc/nginx/sites-available/$site.conf

sudo ln -s /etc/nginx/sites-available/$site.conf /etc/nginx/sites-enabled/

echo "${site} configurado!"

service nginx restart
