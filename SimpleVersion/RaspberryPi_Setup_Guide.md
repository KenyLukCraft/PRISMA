# Raspberry Pi Zero 2W Setup Guide for LogCollectorPi.ps1

## Overview
This guide helps you set up the lightweight LogCollectorPi.ps1 script on a Raspberry Pi Zero 2W for automated printer log collection and email delivery.

## Pi Zero 2W Specifications
- **CPU**: Quad-core 64-bit ARM Cortex-A53 @ 1GHz
- **RAM**: 512MB LPDDR2 SDRAM
- **Storage**: MicroSD card (8GB minimum recommended)
- **Power**: 5V/2.5A via USB-C or GPIO
- **OS**: Raspberry Pi OS Lite (recommended for minimal resource usage)

## Prerequisites

### Hardware Requirements
- Raspberry Pi Zero 2W
- MicroSD card (8GB+ Class 10)
- USB-C power supply (5V/2.5A)
- Ethernet cable or WiFi connection
- USB-C to USB-A adapter (for initial setup)

### Software Requirements
- Raspberry Pi OS Lite (64-bit recommended)
- PowerShell Core 7.x (not Windows PowerShell)

## Installation Steps

### 1. Prepare Raspberry Pi OS

1. **Download Raspberry Pi OS Lite**:
   ```bash
   # Download from: https://www.raspberrypi.org/downloads/
   # Use Raspberry Pi Imager to flash to microSD card
   ```

2. **Enable SSH and WiFi** (create these files on boot partition):
   
   **ssh** (empty file):
   ```bash
   touch /boot/ssh
   ```
   
   **wpa_supplicant.conf**:
   ```bash
   country=US
   ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
   update_config=1
   
   network={
       ssid="YOUR_WIFI_NAME"
       psk="YOUR_WIFI_PASSWORD"
   }
   ```

3. **Boot the Pi** and connect via SSH:
   ```bash
   ssh pi@raspberrypi.local
   # Default password: raspberry
   ```

### 2. Install PowerShell Core

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install PowerShell Core
# Note: Microsoft repository doesn't have PowerShell for Debian Bookworm yet
# Use direct download method instead

echo "Downloading PowerShell directly from GitHub..."
wget https://github.com/PowerShell/PowerShell/releases/download/v7.5.3/powershell_7.5.3-1.deb_arm64.deb
sudo dpkg -i powershell_7.5.3-1.deb_arm64.deb
sudo apt-get install -f  # Fix any dependency issues
rm -f powershell_7.5.3-1.deb_arm64.deb  # Clean up

# Alternative: Use snap (if preferred)
# sudo snap install powershell --classic

# Verify installation
pwsh --version
```

### 3. Install LogCollectorPi.ps1

```bash
# Create application directory
sudo mkdir -p /opt/logcollector
cd /opt/logcollector

# Download the script (copy from your development machine)
sudo nano LogCollectorPi.ps1
# Paste the script content and save (Ctrl+X, Y, Enter)

# Make executable
sudo chmod +x LogCollectorPi.ps1

# Create log directory
sudo mkdir -p /tmp/printer_logs
sudo chown pi:pi /tmp/printer_logs
```

### 4. Configure the Script

Edit the configuration section in LogCollectorPi.ps1:

```powershell
# Modify these values for your setup
$baseUrl = "http://192.168.1.149"        # Your printer's IP
$pagePath = "/accounting"                 # Your printer's log path
$smtpServer = "smtp.gmail.com"           # Your email provider
$smtpPort = 587
$fromEmail = "your_email@gmail.com"      # Your email
$toEmail = @("recipient@company.com")    # Recipients

# Encode your password
$base64Password = "YOUR_ENCODED_PASSWORD"
```

**To encode your password**:
```powershell
pwsh -Command '$pwd = "your_password"; [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($pwd))'
```

### 5. Test the Script

```bash
# Test run
cd /opt/logcollector
sudo pwsh -File LogCollectorPi.ps1

# Check for errors
echo $?
```

### 6. Set Up Automatic Execution

#### Option A: Cron Job (Recommended for Pi Zero 2W)

```bash
# Edit crontab
sudo crontab -e

# Add this line to run every 6 hours
0 */6 * * * cd /opt/logcollector && pwsh -File LogCollectorPi.ps1 >> /var/log/logcollector.log 2>&1

# Or run daily at 2 AM
0 2 * * * cd /opt/logcollector && pwsh -File LogCollectorPi.ps1 >> /var/log/logcollector.log 2>&1
```

#### Option B: Systemd Service (For more control)

Create service file:
```bash
sudo nano /etc/systemd/system/logcollector.service
```

Service content:
```ini
[Unit]
Description=Printer Log Collector
After=network.target

[Service]
Type=oneshot
User=pi
WorkingDirectory=/opt/logcollector
ExecStart=/usr/bin/pwsh -File LogCollectorPi.ps1
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

Create timer file:
```bash
sudo nano /etc/systemd/system/logcollector.timer
```

Timer content:
```ini
[Unit]
Description=Run LogCollector every 6 hours
Requires=logcollector.service

[Timer]
OnCalendar=*-*-* 00,06,12,18:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable logcollector.timer
sudo systemctl start logcollector.timer
sudo systemctl status logcollector.timer
```

## Pi Zero 2W Optimizations

### 1. Memory Management
The script is optimized for Pi Zero 2W's 512MB RAM:
- Uses `/tmp` for temporary files (RAM-based)
- Automatic cleanup of old files
- Minimal memory footprint
- Timeout settings to prevent hanging

### 2. Storage Optimization
- Downloads stored in `/tmp` (RAM disk)
- Automatic cleanup keeps only recent files
- Minimal disk usage

### 3. Network Optimization
- 30-second timeout for web requests
- 60-second timeout for downloads
- Efficient regex parsing
- Minimal network overhead

### 4. Power Management
```bash
# Disable unnecessary services
sudo systemctl disable bluetooth
sudo systemctl disable hciuart

# Reduce GPU memory split
sudo raspi-config
# Advanced Options → Memory Split → 16

# Enable power management
echo 'dtparam=audio=off' | sudo tee -a /boot/config.txt
```

## Monitoring and Maintenance

### Check Script Status
```bash
# View recent logs
sudo journalctl -u logcollector.service -f

# Check cron logs
tail -f /var/log/logcollector.log

# Test connectivity
ping 192.168.1.149
```

### System Monitoring
```bash
# Check memory usage
free -h

# Check disk usage
df -h

# Check temperature
vcgencmd measure_temp

# Check CPU usage
top
```

### Troubleshooting

#### Common Issues:

1. **"PowerShell not found" or repository errors**:
   ```bash
   # Microsoft repository doesn't have PowerShell for Debian Bookworm
   # Use direct download method instead
    wget https://github.com/PowerShell/PowerShell/releases/download/v7.5.3/powershell_7.5.3-1.deb_arm64.deb
    sudo dpkg -i powershell_7.5.3-1.deb_arm64.deb
    sudo apt-get install -f  # Fix dependencies
    rm -f powershell_7.5.3-1.deb_arm64.deb  # Clean up
   ```

2. **Alternative installation methods**:
   ```bash
   # Method 1: Using snap (if available)
   sudo snap install powershell --classic
   
   # Method 2: Using .NET installation
   wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb
   sudo dpkg -i packages-microsoft-prod.deb
   sudo apt update
   sudo apt install -y powershell
   ```

3. **"Permission denied"**:
   ```bash
   sudo chmod +x LogCollectorPi.ps1
   sudo chown pi:pi LogCollectorPi.ps1
   ```

4. **"Cannot connect to printer"**:
   ```bash
   ping 192.168.1.149
   curl -I http://192.168.1.149/accounting
   ```

5. **"Email sending failed"**:
   - Check SMTP settings
   - Verify credentials
   - Test network connectivity

6. **"Out of memory"**:
   ```bash
   # Increase swap space
   sudo dphys-swapfile swapoff
   sudo nano /etc/dphys-swapfile
   # Change CONF_SWAPSIZE=100 to CONF_SWAPSIZE=512
   sudo dphys-swapfile setup
   sudo dphys-swapfile swapon
   ```

## Performance Tips

### 1. Optimize for Pi Zero 2W
- Use Pi OS Lite (no desktop)
- Disable unnecessary services
- Use cron instead of systemd for simple scheduling
- Monitor memory usage regularly

### 2. Network Optimization
- Use wired Ethernet if possible
- Ensure stable WiFi connection
- Consider running during off-peak hours

### 3. Storage Management
- Regular cleanup of log files
- Monitor `/tmp` usage
- Use external storage for long-term logs if needed

## Security Considerations

### 1. SSH Security
```bash
# Change default password
passwd

# Disable password authentication (use SSH keys)
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart ssh
```

### 2. Firewall
```bash
# Install and configure UFW
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable
```

### 3. Regular Updates
```bash
# Set up automatic security updates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades
```

## Backup and Recovery

### Backup Configuration
```bash
# Backup script and configuration
sudo tar -czf logcollector-backup.tar.gz /opt/logcollector /etc/crontab
```

### Recovery
```bash
# Restore from backup
sudo tar -xzf logcollector-backup.tar.gz -C /
```

## Support

For issues specific to Pi Zero 2W:
1. Check system resources: `htop`
2. Monitor temperature: `vcgencmd measure_temp`
3. Check network: `ip addr show`
4. Review logs: `journalctl -xe`

---

**Note**: The Pi Zero 2W is a resource-constrained device. This lightweight script is optimized for minimal resource usage while maintaining functionality.
