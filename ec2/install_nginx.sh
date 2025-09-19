#!/bin/bash

sudo apt update -y
sudo apt install -y nginx
sudo systemctl enable nginx --now
echo "<h1> Hello world..!!</h1?" | sudo tee /var/www/html/index.html