#! /bin/bash
sudo apt-get update
sudo apt-get install apache2 -y
sudo a2ensite default-ssl
sudo a2enmod ssl
cd /var/www/html
sudo mkdir app1
sudo echo "Application 1" | \
tee /var/www/html/app1/index.html