# Ubuntu Server Setup

This repository contains a bash script to set up Docker, Portainer, PiVPN, Pi-hole, Nginx Proxy Manager, and Checkmk on **Ubuntu 24.04 LTS**.

## Requirements

- Ubuntu 24.04 LTS (clean install recommended)
- Internet access during setup

## Usage

1. Clone this repository:
    ```bash
    git clone https://github.com/RylanQ/ubuntu-server-setup.git
    cd ubuntu-server-setup
    ```

2. Run the installation script:
    ```bash
    sudo ./install-server-tools.sh
    ```

3. Reboot the server after installation:
    ```bash
    sudo reboot
    ```

4. Access the installed tools using the links provided below.

## Features

- **Docker**: Installs Docker CE and Docker Compose for containerized applications.
- **Portainer**: Simplified Docker container management.
- **PiVPN**: VPN server setup for secure remote access.
- **Pi-hole**: Ad-blocking DNS server with a web interface.
- **Nginx Proxy Manager**: Easy reverse proxy setup with SSL support.
- **Checkmk**: Infrastructure monitoring tool.

## Generated Credentials

During the installation, the script generates secure passwords for some services. These are saved to a secure file for your reference:
- `/root/setup-info.txt`: Contains passwords for Pi-hole and Checkmk.

Ensure you keep this file secure!

## Links and Default Credentials

Below are the URLs and credentials for accessing the installed services:

### **Portainer**
- **URL**: `https://<your-server-ip>:9443`
- **Default Credentials**: Set during first login.

### **PiVPN**
- **URL**: No specific URL. Access using a VPN client after configuration.
- **Default Credentials**: None (set up during installation).

### **Pi-hole**
- **URL**: `http://<your-server-ip>/admin`
- **Default Password**: Generated during installation. Saved to `/root/setup-info.txt`.

### **Nginx Proxy Manager**
- **URL**: `http://<your-server-ip>:81`
- **Default Credentials**:
  - Username: `admin@example.com`
  - Password: `changeme`

### **Checkmk**
- **URL**: `http://<your-server-ip>:5000`
- **Default Password**: Generated during installation. Saved to `/root/setup-info.txt`.

## Logging and Troubleshooting

- All script logs are saved to `/var/log/setup.log`. Review this log if you encounter any issues.
- Ensure no other services are using the default ports for each application before running the script.

## Notes

1. **Security**:
   - Generated passwords are saved securely. Modify the password storage method if you have custom security requirements.
   - Change the default credentials for Nginx Proxy Manager after the first login.

2. **Port Conflicts**:
   - Ensure that the following ports are not in use before running the script:
     - **Portainer**: 9443
     - **Pi-hole**: 53, 80, 443
     - **Nginx Proxy Manager**: 80, 81, 443
     - **Checkmk**: 5000

3. **Idempotence**:
   - The script is designed to be idempotent and can be re-run if interrupted. However, re-running it may reset some configurations.

4. **Test Environment**:
   - Run the script in a virtual machine or container to validate before deploying it in production.

---

For any issues or feature requests, please open a GitHub issue. Happy hosting!
