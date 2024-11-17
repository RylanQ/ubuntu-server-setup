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

# Reset terminal settings to prevent scroll issues
echo "Resetting terminal settings..."
reset

# Reconfigure lighttpd to avoid port conflicts with NGINX and allow network access
echo "Reconfiguring lighttpd for Pi-hole..."
sudo sed -i 's/server.port *= *80/server.port = 8080/' /etc/lighttpd/lighttpd.conf
sudo sed -i 's|#server.bind.*|server.bind = "0.0.0.0"|' /etc/lighttpd/lighttpd.conf
sudo systemctl restart lighttpd || { echo "Failed to restart lighttpd"; exit 1; }

# Install Unbound for Pi-hole
echo "Installing Unbound DNS resolver..."
apt install -y unbound || { echo "Unbound installation failed"; exit 1; }

# Configure Unbound with Pi-hole
echo "Configuring Unbound with Pi-hole..."
cat <<EOL | sudo tee /etc/unbound/unbound.conf.d/pi-hole.conf
server:
    verbosity: 0
    interface: 127.0.0.1
    port: 5335
    do-ip4: yes
    do-udp: yes
    do-tcp: yes
    root-hints: "/var/lib/unbound/root.hints"
    harden-dnssec-stripped: yes
    use-caps-for-id: yes
    edns-buffer-size: 1232
    prefetch: yes
    prefetch-key: yes
    cache-min-ttl: 3600
    cache-max-ttl: 86400
    private-address: 192.168.0.0/16
    private-address: 172.16.0.0/12
    private-address: 10.0.0.0/8
EOL

# Download and update root hints for Unbound
curl -o /var/lib/unbound/root.hints https://www.internic.net/domain/named.root

# Fix permissions for Unbound
echo "Fixing permissions for Unbound directories..."
sudo chown -R unbound:unbound /etc/unbound
sudo chown -R unbound:unbound /var/lib/unbound
sudo chmod -R 755 /etc/unbound
sudo chmod -R 755 /var/lib/unbound

# Restart Unbound to apply changes
echo "Restarting Unbound service..."
sudo systemctl restart unbound || { echo "Unbound failed to start. Check configuration and permissions."; exit 1; }
sudo systemctl enable unbound

# Configure Pi-hole to use Unbound
echo "Configuring Pi-hole to use Unbound as DNS resolver..."
sudo pihole -a setdns 127.0.0.1#5335 || { echo "Failed to configure Pi-hole to use Unbound"; exit 1; }

# Ensure firewall rules allow access for web and DNS
echo "Configuring firewall rules for Pi-hole, DNS, and Unbound..."
sudo ufw allow 8080/tcp    # Web interface for Pi-hole
sudo ufw allow 8181/tcp    # Alternative web port
sudo ufw allow 53/tcp      # DNS traffic (TCP)
sudo ufw allow 53/udp      # DNS traffic (UDP)
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
    echo "Nginx Proxy Manager setup failed"; exit 1;
}

# Set up Checkmk
echo "Setting up Checkmk..."
CHECKMK_PASSWORD=$(openssl rand -base64 32)
echo "Generated Checkmk Admin Password."
docker volume create checkmk_data
docker run -d --name checkmk -p 5001:5000 --restart always -e CMK_PASSWORD=$CHECKMK_PASSWORD -v checkmk_data:/omd/sites checkmk/check-mk-raw:latest || {
    echo "Checkmk setup failed"; exit 1;
}

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
echo "Credentials for Pi-hole are set during installation."
echo "Other generated credentials are securely saved to /root/setup-info.txt"
