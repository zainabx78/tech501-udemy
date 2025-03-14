#!/bin/bash
set -e

# Suppress all prompts
export DEBIAN_FRONTEND=noninteractive

echo "Updating package lists..."
sudo apt-get update -y

echo "Upgrading packages..."
DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -y

echo "Installing gnupg and curl..."
sudo apt-get install -y gnupg curl

# If the key is downloaded then remove and download again (no clash).
GPG_KEY_FILE="/usr/share/keyrings/mongodb-server-7.0.gpg"

if [ -f "$GPG_KEY_FILE" ]; then
    echo "File $GPG_KEY_FILE exists. Overwriting..."
    sudo rm -f "$GPG_KEY_FILE"
fi

echo "Downloading MongoDB GPG key"
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
    sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
    --dearmor

echo "Adding MongoDB repository to sources list..."
echo "deb [signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list > /dev/null


echo "Updating package lists after adding MongoDB repo..."
sudo apt-get update -y

# Installing mongodb
echo "Installing MongoDB 7.0.6..."
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y mongodb-org=7.0.6 mongodb-org-database=7.0.6 mongodb-org-server=7.0.6 mongodb-mongosh mongodb-org-mongos=7.0.6 mongodb-org-tools=7.0.6

# start mongodb
echo "Starting MongoDB service..."
sudo systemctl start mongod

# enable mongodb so it starts automatically everytime
echo "Enabling MongoDB service to start on boot..."
sudo systemctl enable mongod

echo "Restarting MongoDB service..."
sudo systemctl restart mongod

echo "MongoDB installation and setup complete!"

# change the bind IP to allow all with correct formatting
echo "Configuring MongoDB to bind to all IP addresses..."
sudo sed -i '/^net:/,/^$/s/^ *bindIp:.*$/  bindIp: 0.0.0.0/' /etc/mongod.conf






