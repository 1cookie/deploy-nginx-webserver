# Deploy nginx webserver locally

Bash script to automate this process

## Pre-requisites
Install nginx locally
https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04

Install an SSL Certificate locally
https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu-20-04-1

Builds an nginx virtual host with a PHP bootstrap and served over `https`. 

## Usage
    
    ./nginxSetup.sh
    
Browse to: https://yourdomain.test 
