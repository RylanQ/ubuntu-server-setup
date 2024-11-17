#!/bin/bash

# Exit on error
set -e  

# Log output to a file
exec > >(tee -i /var/log/setup.log) 2>&1

# Set timezone to UTC
echo "Setting timezone to UTC"
timedatectl set-timezone UTC || { echo "Failed to set timezone"; exit 1; }

# Update system and install dependencies
echo "Updating system packages and installing dependencies..."
apt update && apt upgrade -y
apt install -y curl apt-transport-https ca-certificates software-properties-common gnupg lsb-release || {
    echo "Dependency installation failed"; exit 1;
}

# Install Docker
echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io || { echo "Docker installation failed"; exit 1; }
systemctl enable docker
systemctl start docker

# Install Docker Compose
echo "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4 || echo "v2.20.2")
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Set up Portainer
echo "Setting up Portainer..."
docker volume create portainer_data
docker run -d -p 9444:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest || {
    echo "Portainer setup failed"; exit 1;
}

# Set up Pi-hole (Native Installation)
echo "Setting up Pi-hole..."
curl -sSL https://install.pi-hole.net -o install-pihole.sh
chmod +x install-pihole.sh
sudo ./install-pihole.sh || { echo "Pi-hole setup failed"; exit 1; }

# Adjust Pi-hole lighttpd configuration
echo "Configuring Pi-hole's web server to avoid conflicts..."
sudo sed -i 's/server.port *= *80/server.port = 8080/' /etc/lighttpd/lighttpd.conf
sudo sed -i 's|#server.bind.*|server.bind = "0.0.0.0"|' /etc/lighttpd/lighttpd.conf
sudo systemctl restart lighttpd || { echo "Failed to restart lighttpd"; exit 1; }

# Configure necessary firewall rules
echo "Configuring firewall rules..."
sudo ufw allow 8080/tcp comment "Pi-hole web interface"
sudo ufw allow 9444/tcp comment "Portainer web interface"
sudo ufw allow 80/tcp comment "Nginx Proxy Manager HTTP"
sudo ufw allow 81/tcp comment "Nginx Proxy Manager Admin"
sudo ufw allow 443/tcp comment "Nginx Proxy Manager HTTPS"
sudo ufw allow 5001/tcp comment "Checkmk web interface"
sudo ufw reload || { echo "Failed to reload firewall rules"; exit 1; }

# Set up PiVPN
echo "Setting up PiVPN..."
curl -L https://install.pivpn.io -o install-pivpn.sh
chmod +x install-pivpn.sh
bash install-pivpn.sh || { echo "PiVPN setup failed"; exit 1; }

# Set up Nginx Proxy Manager
echo "Setting up Nginx Proxy Manager..."
docker volume create npm_data
docker volume create npm_letsencrypt
docker run -d -p 80:80 -p 81:81 -p 443:443 --name nginxproxymanager --restart=always -v npm_data:/data -v npm_letsencrypt:/etc/letsencrypt jc21/nginx-proxy-manager:latest || {
    echo "Nginx Proxy Manager setup failed"; exit 1; }

# Set up Checkmk
echo "Setting up Checkmk..."
CHECKMK_PASSWORD=$(openssl rand -base64 32)
echo "Generated Checkmk Admin Password."
docker volume create checkmk_data
docker run -d --name checkmk -p 5001:5000 --restart always -e CMK_PASSWORD=$CHECKMK_PASSWORD -v checkmk_data:/omd/sites checkmk/check-mk-raw:latest || {
    echo "Checkmk setup failed"; exit 1; }

# Save credentials securely
echo "Saving passwords to /root/setup-info.txt"
echo "Checkmk Admin Password: $CHECKMK_PASSWORD" > /root/setup-info.txt
chmod 600 /root/setup-info.txt

# Display setup information
echo "Installations complete. Applications have been set up:"
echo "- Portainer is available on https://<your-server-ip>:9444"
echo "- Pi-hole is available on http://<your-server-ip>:8080/admin"
echo "- Nginx Proxy Manager is available on http://<your-server-ip>:81"
echo "- Checkmk is available on http://<your-server-ip>:5001"
echo "Generated credentials are securely saved to /root/setup-info.txt"
