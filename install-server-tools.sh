#!/bin/bash

# Set timezone to UTC
echo "Setting timezone to UTC"
timedatectl set-timezone UTC

# Update system and install dependencies
echo "Updating system packages and installing dependencies..."
apt update && apt upgrade -y
apt install -y curl apt-transport-https ca-certificates software-properties-common gnupg lsb-release

# Install Docker
echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl start docker

# Install Docker Compose
echo "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Set up Portainer
echo "Setting up Portainer..."
docker volume create portainer_data
docker run -d -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

# Set up Pi-hole
echo "Setting up Pi-hole..."
PIHOLE_PASSWORD=$(openssl rand -base64 32)
echo "Pi-hole Web Interface Password: $PIHOLE_PASSWORD"
docker volume create pihole_data
docker volume create dnsmasq_data
docker run -d --name pihole -e TZ="UTC" -e WEBPASSWORD="$PIHOLE_PASSWORD" -p 53:53/tcp -p 53:53/udp -p 80:80 -p 443:443 --dns=127.0.0.1 --dns=8.8.8.8 -v pihole_data:/etc/pihole -v dnsmasq_data:/etc/dnsmasq.d --restart=unless-stopped pihole/pihole:latest

# Set up PiVPN
echo "Setting up PiVPN..."
curl -L https://install.pivpn.io | bash

# Set up Nginx Proxy Manager
echo "Setting up Nginx Proxy Manager..."
docker volume create npm_data
docker volume create npm_letsencrypt
docker run -d -p 80:80 -p 81:81 -p 443:443 --name nginxproxymanager --restart=always -v npm_data:/data -v npm_letsencrypt:/etc/letsencrypt jc21/nginx-proxy-manager:latest

# Set up Checkmk
echo "Setting up Checkmk..."
CHECKMK_PASSWORD=$(openssl rand -base64 32)
docker volume create checkmk_data
docker run -d --name checkmk -p 5000:5000 --restart always -e CMK_PASSWORD=$CHECKMK_PASSWORD -v checkmk_data:/omd/sites checkmk/check-mk-raw:latest

# Display setup information
echo "Installations complete. Applications have been set up as Docker containers:"
echo "- Portainer is available on https://<your-server-ip>:9443"
echo "- Pi-hole is available on http://<your-server-ip>/admin"
echo "- Nginx Proxy Manager is available on http://<your-server-ip>:81"
echo "- Checkmk is available on http://<your-server-ip>:5000"

echo "Generated Passwords:"
echo "Pi-hole Web Interface Password: $PIHOLE_PASSWORD"
echo "Checkmk Admin Password: $CHECKMK_PASSWORD"
