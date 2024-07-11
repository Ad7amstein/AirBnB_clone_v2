#!/usr/bin/env bash
# Prepare the web server

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install nginx
sudo mkdir -p /data/web_static/releases/test /data/web_static/shared/

# Create a fake HTML file for testing
echo "<html>
  <head>
  </head>
  <body>
    Web static test
  </body>
</html>" | sudo tee /data/web_static/releases/test/index.html > /dev/null

sudo ln -sf /data/web_static/releases/test/ /data/web_static/current
sudo chown -hR ubuntu:ubuntu /data/

# Update nginx config
sudo sh -c ' echo "
server {
    listen 80;
    add_header X_served_By /$HOSTNAME;
    server_name adham3llam.tech;
    location /hbnb_static {
        alias /data/web_static/current/;
    }
}" >> /etc/nginx/sites-available/default'
check_error "Failed to update Nginx configuration."

# Restartic Nginx
sudo systemctl restart nginx
check_error "Failed to restart nginx"

