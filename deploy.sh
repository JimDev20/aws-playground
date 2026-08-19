#!/bin/bash
echo "Deploying Ecommerce site"
sudo mkdir -p /var/www/Ecommerce/
sudo cp -r Ecommerce/* /var/www/Ecommerce
echo "Deployed to /var/www/Ecommerce/"
