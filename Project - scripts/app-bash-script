#!/bin/bash


# Suppresses prompts
set -e
export DEBIAN_FRONTEND=noninteractive

# Update and upgrade packages
echo "Updating packages..."
apt-get update -y
apt-get upgrade -y

# Install nginx
echo "Installing Nginx..."
sudo DEBIAN_FRONTEND=noninteractive apt install -yq nginx

# Install nodejs
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Install unzip for my app folder (copies zip from github)
echo "Installing unzip..."
apt-get install -y unzip

echo "Installing pm2 globally..."
sudo npm install -g pm2

# If statement to delete previous app repos (avoid clash)
REPO_DIR="repo"
if [ -d "$REPO_DIR" ]; then
    echo "Folder $REPO_DIR already exists. Removing it..."
    rm -rf "$REPO_DIR"
fi

# Clone your application repository
echo "Cloning application repository..."
cd /home/ubuntu
git clone https://github.com/zainabx78/tech501-sparta-app repo

# Unzip application
echo "Unzipping application files..."
cd /home/ubuntu/repo
unzip nodejs20-sparta-test-app.zip

# nginx proxy
sudo systemctl enable nginx
sudo systemctl reload nginx

# configuring reverse proxy, checking syntax, and reloading nginx
sudo sed -i 's|try_files $uri $uri/ =404;|proxy_pass http://localhost:3000;|' /etc/nginx/sites-available/default
sudo nginx -t
sudo systemctl reload nginx


# Install application dependencies
echo "Installing app dependencies..."
cd /home/ubuntu/repo/app
#sudo chown -R $(whoami) /repo/app
sudo npm install
npm audit fix
sudo npm install pm2 -g
export DB_HOST=mongodb://172.31.48.131:27017/posts
node seeds/seed.js
pm2 start app.js

echo "User-data script execution complete."


