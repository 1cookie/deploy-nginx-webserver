#!/bin/bash

dom="^[a-z]+\.[a-z]{3,5}$"
while ! [[ "${domain}" =~ ${dom} ]] 
do
    echo "Enter domain string (e.g. test.local):"
    read -r domain
done

printf "Socket information found:-\n"
ls /var/run/php
printf "==========================\n"

re="php[0-9]\.[0-9]-fpm.sock"
while ! [[ "${socket}" =~ ${re} ]] 
do
    echo "Enter socket string (e.g. php8.1-fpm.sock):"
    read -r socket
done

sudo rm /etc/nginx/sites-available/"${domain}"

sudo tee -a /etc/nginx/sites-available/"${domain}" >/dev/null <<EOF
server {
        listen 443 ssl;
        listen [::]:443 ssl;
        
        include snippets/self-signed.conf;
        include snippets/ssl-params.conf;

        root /var/www/${domain}/public;
        index index.php index.html index.htm index.nginx-debian.html;

        server_name ${domain} www.${domain};

        location / {
                try_files \$uri \$uri/ =404;
        }
        
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/var/run/php/$socket;
        }
}

server {
    listen 80;
    listen [::]:80;

    server_name ${domain} www.${domain};

    return 302 https://\$server_name\$request_uri;
}
EOF

sudo ln -s /etc/nginx/sites-available/"${domain}" /etc/nginx/sites-enabled/

fullPath="/var/www/${domain}"

rm -fr "${fullPath}" # mkdir: cannot create directory ‘’: File exists

mkdir "${fullPath}" 

mkdir "${fullPath}/public" 

sudo chmod -R 755 "${fullPath}"

sudo chown -R "$USER":www-data "${fullPath}"

echo "<?php phpinfo(); ?>" > "${fullPath}"/public/index.php

sudo tee -a /etc/hosts >/dev/null <<EOF
127.0.0.1		${domain}
EOF

echo "Testing nginx config:-"

testConfig=$(sudo nginx -t)

sudo systemctl restart nginx

<<comment
tail -f /var/log/nginx/access.log;
tail -f /var/log/nginx/error.log;
comment
