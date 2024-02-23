#! /bin/bash
sudo apt-get update
sudo apt-get install apache2 -y
sudo a2ensite default-ssl
sudo a2enmod ssl
cd /var/www/html
sudo mkdir app2
sudo echo "Application video" | \
tee /var/www/html/app2/index.html