#!/usr/bin/env bash
# Prepare the web server

# Function to check for errors
check_error() {
  if [ $? -ne 0 ]; then
    echo "Error: $1"
    exit 1
  fi
}

# Install Nginx
sudo apt-get update
check_error "Failed to update package index."
sudo apt-get -y install nginx
check_error "Failed to install nginx."
sudo systemctl start nginx
check_error "Failed to start nginx."
sudo systemctl enable nginx
check_error "Failed to enable nginx."

# Create some directories if not exist
sudo mkdir -p /data/web_static/shared/ /data/web_static/releases/test/
check_error "Failed to create directories."

# Create a fake HTML file for testing
echo "<html>
  <head>
  </head>
  <body>
    Web static test
  </body>
</html>" | sudo tee /data/web_static/releases/test/index.html > /dev/null
check_error "Failed to create fake HTML file."

# Create a symlink
SYMLINK="/data/web_static/current"
TARGET="/data/web_static/releases/test"

# Remove the existing symbolic link if it exists and create a new one
sudo ln -sfn "$TARGET" "$SYMLINK"
check_error "Failed to create symbolic link."

# Give ownership to ubuntu
sudo chown -R ubuntu:ubuntu /data/
check_error "Failed to set ownership."

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

