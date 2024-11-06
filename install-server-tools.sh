#!/bin/bash

# Update and Set Timezone
sudo apt update && sudo apt upgrade -y
sudo timedatectl set-timezone Asia/Kolkata

# Install Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.gpg > /dev/null
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Portainer
sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce

# Install Pi-hole
curl -sSL https://install.pi-hole.net | bash

# Install PiVPN
curl -L https://install.pivpn.io | bash

# Install Nginx Proxy Manager
sudo docker run -d -p 80:80 -p 81:81 -p 443:443 --name=nginx-proxy-manager --restart=always -v npm_data:/data -v npm_letsencrypt:/etc/letsencrypt jc21/nginx-proxy-manager:latest

# Install Checkmk
sudo docker run -d -p 5000:5000 --name checkmk --restart always -v checkmk_data:/omd/sites checkmk/check-mk-raw:latest

echo "All services have been installed successfully!"
