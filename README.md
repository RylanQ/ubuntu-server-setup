# Ubuntu Server Setup

This repository contains a bash script to set up Docker, Portainer, PiVPN, Pi-hole, Nginx Proxy Manager, and Checkmk on **Ubuntu 24.04 LTS**.

## Requirements

- Ubuntu 24.04 LTS (clean install recommended)
- Internet access during setup
- A cloud firewall or external firewall configuration for managing ports and access

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
- **Pi-hole**: Ad-blocking DNS server for network-wide ad filtering.
- **Nginx Proxy Manager**: Easy reverse proxy setup with SSL support.
- **Checkmk**: Infrastructure monitoring tool.

## Generated Credentials

During the installation, the script generates secure passwords for some services. These are saved to a secure file for your reference:
- `/root/setup-info.txt`: Contains passwords for Pi-hole and Checkmk.

Ensure you keep this file secure!

## Links and Default Credentials

Below are the URLs and credentials for accessing the installed services:

### **Portainer**
- **URL**: `https://<your-server-ip>:9444`
- **Default Credentials**: Set during first login.

### **PiVPN**
- **URL**: No specific URL. Access using a VPN client after configuration.
- **Default Credentials**: None (set up during installation).

### **Pi-hole**
- **URL**: `http://<your-server-ip>:8080/admin`
- **Default Password**: Generated during installation. Saved to `/root/setup-info.txt`.

### **Nginx Proxy Manager**
- **URL**: `http://<your-server-ip>:81`
- **Default Credentials**:
  - Username: `admin@example.com`
  - Password: `changeme`

### **Checkmk**
- **URL**: `http://<your-server-ip>:5001`
- **Default Password**: Generated during installation. Saved to `/root/setup-info.txt`.

## Logging and Troubleshooting

- All script logs are saved to `/var/log/setup.log`. Review this log if you encounter any issues.
- Ensure that the cloud firewall is configured to allow access to the necessary ports for each service.

## Notes

1. **Cloud Firewall Configuration**:
   - The script assumes that port management is handled by an external or cloud-based firewall. Ensure the following ports are open as needed:
     - **Pi-hole Web Interface**: 8080 (TCP)
     - **Portainer**: 9444 (TCP)
     - **Nginx Proxy Manager**: 80 (HTTP), 81 (Admin), 443 (HTTPS) (TCP)
     - **Checkmk**: 5001 (TCP)
     - **PiVPN**: Custom VPN port (set during installation)
   - External DNS (port 53) is not explicitly managed by this script.

2. **Security**:
   - Generated passwords are saved securely. Modify the password storage method if you have custom security requirements.
   - Change the default credentials for Nginx Proxy Manager after the first login.

3. **Port Conflicts**:
   - Ensure the following ports are not in use before running the script:
     - **Portainer**: 9444
     - **Pi-hole Web Interface**: 8080
     - **Nginx Proxy Manager**: 80, 81, 443
     - **Checkmk**: 5001

4. **Idempotence**:
   - The script is designed to be idempotent and can be re-run if interrupted. However, re-running it may reset some configurations.

5. **Test Environment**:
   - Run the script in a virtual machine or container to validate before deploying it in production.

---

For any issues or feature requests, please open a GitHub issue. Happy hosting!
