# Ubuntu Server Setup

This repository contains a bash script to install Docker, Portainer, PiVPN, PiHole, Nginx Proxy Manager, and Checkmk on Ubuntu 24.04 LTS.

## Requirements
- Ubuntu 24.04 LTS

## Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/RylanQ/ubuntu-server-setup.git
   cd ubuntu-server-setup
2. Run the installation script:
   ```bash
   sudo ./install-server-tools.sh

3. Reboot the server:
   ```bash
   sudo reboot

## Links and Default Credentials

Here are the links and default credentials for accessing each service:

Portainer

URL: http://your-server-ip:9000

Default Credentials: Set during first login

PiVPN

URL: No specific URL. Access using VPN client after configuration.

Default Credentials: None (set up during installation)

Pi-hole

URL: http://your-server-ip/admin

Default Password: Set during installation (usually displayed at the end)

Nginx Proxy Manager

URL: http://your-server-ip:81

Default Credentials:

Username: admin@example.com

Password: changeme

Checkmk

URL: http://your-server-ip:5000

Default Credentials: Set during first setup

