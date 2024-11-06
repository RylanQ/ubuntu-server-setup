#!/bin/bash

# Update the system
echo "Updating the system..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "Installing Docker..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker ${USER}

# Install Docker Compose
echo "Installing Docker Compose..."
sudo apt install -y docker-compose-plugin

# Install Portainer
echo "Setting up Portainer..."
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

# Install PiVPN (OpenVPN or WireGuard)
echo "Installing PiVPN..."
curl -L https://install.pivpn.io | bash

# Install PiHole
echo "Setting up PiHole..."
docker run -d --name pihole -e TZ="America/New_York" -e WEBPASSWORD="password" -v pihole_config:/etc/pihole -v dnsmasq_config:/etc/dnsmasq.d -p 80:80 -p 53:53/tcp -p 53:53/udp --restart=unless-stopped pihole/pihole:latest

# Install Nginx Proxy Manager
echo "Installing Nginx Proxy Manager..."
docker volume create npm_data
docker volume create npm_letsencrypt
docker run -d -p 80:80 -p 81:81 -p 443:443 --name=nginx-proxy-manager --restart=always -v npm_data:/data -v npm_letsencrypt:/etc/letsencrypt jc21/nginx-proxy-manager:latest

# Install Checkmk (Free Edition)
echo "Installing Checkmk..."
docker run -d --name checkmk -p 5000:5000 -p 8000:8000 checkmk/check-mk-raw:2.1.0-latest

echo "Installation completed. Please reboot to apply all changes."

