# LogCollectorPi - Printer Log Collection for Raspberry Pi Zero 2W

[![PowerShell](https://img.shields.io/badge/PowerShell-7.5+-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-Zero%202W-red.svg)](https://www.raspberrypi.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A lightweight, optimized PowerShell-based solution for automated printer log collection and email delivery on Raspberry Pi Zero 2W.

## 🚀 Features

- **Lightweight & Optimized**: Designed specifically for Pi Zero 2W's 512MB RAM
- **Automated Collection**: Downloads latest CSV and ACL files from network printers
- **Email Notifications**: Sends logs via email with comprehensive status reporting
- **Smart Handling**: Handles printer offline scenarios gracefully
- **Resource Efficient**: RAM-based temporary storage with automatic cleanup
- **Easy Installation**: One-command automated setup
- **Flexible Scheduling**: Cron jobs or systemd timers
- **Auto-Updates**: Built-in update mechanism from GitHub

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [System Requirements](#-system-requirements)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Scheduling](#-scheduling)
- [Updating](#-updating)
- [Troubleshooting](#-troubleshooting)
- [File Structure](#-file-structure)
- [Contributing](#-contributing)

## ⚡ Quick Start

### 1. Prepare Your Raspberry Pi
```bash
# Flash Raspberry Pi OS Lite to microSD card
# Enable SSH and WiFi on boot partition
# Boot and connect via SSH
ssh pi@raspberrypi.local
```

### 2. One-Command Installation
```bash
# Download and run the installer
wget https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/install_pi.sh
chmod +x install_pi.sh
sudo ./install_pi.sh
```

### 3. Configure
```bash
# Edit the script configuration
sudo nano /opt/logcollector/LogCollectorPi.ps1

# Update these values:
# - $baseUrl = "http://YOUR_PRINTER_IP"
# - $pagePath = "/accounting"
# - $smtpServer, $fromEmail, $toEmail
# - $base64Password (encode your email password)
```

### 4. Test & Schedule
```bash
# Test the script
cd /opt/logcollector
sudo pwsh -File LogCollectorPi.ps1

# The installer will help you set up automatic scheduling
```

## 💻 System Requirements

### Hardware
- **Raspberry Pi Zero 2W** (or higher)
- **512MB RAM** minimum
- **8GB microSD card** (Class 10 recommended)
- **Network connection** (WiFi or Ethernet)

### Software
- **Raspberry Pi OS Lite** (64-bit recommended)
- **PowerShell Core 7.5+**
- **Network access** to printer and SMTP server

### Network Requirements
- Printer with web interface accessible via HTTP
- SMTP server for email delivery (port 587/465/25)
- Stable network connection

## 🔧 Installation

### Method 1: Automated Installer (Recommended)

The automated installer handles everything:
- Installs PowerShell Core
- Creates directories
- Sets up the script
- Configures scheduling
- Applies Pi Zero 2W optimizations

```bash
wget https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/install_pi.sh
chmod +x install_pi.sh
sudo ./install_pi.sh
```

### Method 2: Manual Installation

```bash
# Install PowerShell Core
wget https://github.com/PowerShell/PowerShell/releases/download/v7.5.3/powershell_7.5.3-1.deb_arm64.deb
sudo dpkg -i powershell_7.5.3-1.deb_arm64.deb
sudo apt-get install -f

# Create directories
sudo mkdir -p /opt/logcollector
sudo mkdir -p /tmp/printer_logs

# Download the script
cd /opt/logcollector
sudo wget https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/LogCollectorPi.ps1
sudo chmod +x LogCollectorPi.ps1
sudo chown pi:pi LogCollectorPi.ps1

# Configure (see Configuration section below)
sudo nano LogCollectorPi.ps1
```

## ⚙️ Configuration

### Required Settings

Edit `LogCollectorPi.ps1` and update these values:

#### Printer Configuration
```powershell
$baseUrl = "http://192.168.1.149"    # Your printer's IP address
$pagePath = "/accounting"             # Path to printer's log page
```

#### Email Configuration
```powershell
$smtpServer = "smtp.gmail.com"       # Your SMTP server
$smtpPort = 587                      # SMTP port (587 for TLS)
$fromEmail = "your_email@gmail.com"  # Sender email
$toEmail = @("recipient@company.com") # Recipient(s)
```

#### Password Configuration
Encode your email password:
```powershell
# Run this on any machine with PowerShell:
pwsh -Command '$pwd = "your_password"; [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($pwd))'
```

Then update in the script:
```powershell
$base64Password = "YOUR_ENCODED_PASSWORD_HERE"
```

### Common Printer Paths

| Printer Brand | Common Paths |
|---------------|--------------|
| **Canon** | `/accounting`, `/logs`, `/status` |
| **HP** | `/hp/device/this/status`, `/hp/device/this/logs` |
| **Epson** | `/logs`, `/status`, `/maintenance` |
| **Brother** | `/logs`, `/status`, `/maintenance` |

### Common SMTP Settings

| Provider | SMTP Server | Port | Notes |
|----------|-------------|------|-------|
| **Gmail** | `smtp.gmail.com` | 587 | Requires App Password if 2FA enabled |
| **Outlook** | `smtp-mail.outlook.com` | 587 | - |
| **Office 365** | `smtp.office365.com` | 587 | - |
| **Yahoo** | `smtp.mail.yahoo.com` | 587 | - |
| **Zoho** | `smtp.zoho.com` | 587 | - |

## 🎯 Usage

### Manual Execution
```bash
# Run the script once
cd /opt/logcollector
sudo pwsh -File LogCollectorPi.ps1

# Or use the wrapper script
./run_logcollector.sh
```

### View Logs
```bash
# View recent logs
tail -f /var/log/logcollector.log

# View systemd logs (if using systemd)
sudo journalctl -u logcollector.service -f

# Check last 50 lines
tail -n 50 /var/log/logcollector.log
```

### Test Connectivity
```bash
# Test printer connectivity
ping 192.168.1.149

# Test printer web interface
curl -I http://192.168.1.149/accounting

# Test SMTP server
telnet smtp.gmail.com 587
```

## ⏰ Scheduling

### Option 1: Cron Jobs (Recommended for Pi Zero 2W)

```bash
# Edit crontab
crontab -e

# Add one of these schedules:

# Every 6 hours
0 */6 * * * cd /opt/logcollector && pwsh -File LogCollectorPi.ps1 >> /var/log/logcollector.log 2>&1

# Daily at 2 AM
0 2 * * * cd /opt/logcollector && pwsh -File LogCollectorPi.ps1 >> /var/log/logcollector.log 2>&1

# Every 12 hours
0 */12 * * * cd /opt/logcollector && pwsh -File LogCollectorPi.ps1 >> /var/log/logcollector.log 2>&1

# Weekdays at 6 AM
0 6 * * 1-5 cd /opt/logcollector && pwsh -File LogCollectorPi.ps1 >> /var/log/logcollector.log 2>&1
```

### Option 2: Systemd Service (Advanced)

```bash
# Copy service files
sudo cp logcollector.service /etc/systemd/system/
sudo cp logcollector.timer /etc/systemd/system/

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable logcollector.timer
sudo systemctl start logcollector.timer

# Check status
sudo systemctl status logcollector.timer
sudo systemctl list-timers logcollector.timer
```

## 🔄 Updating

### Automatic Update
```bash
# Download and run the update script
cd /opt/logcollector
wget https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/update_pi.sh
chmod +x update_pi.sh
sudo ./update_pi.sh
```

The update script will:
- Create a backup of your current script
- Download the latest version
- Validate syntax
- Restart services if needed
- Clean up old backups

### Manual Update
```bash
cd /opt/logcollector
sudo cp LogCollectorPi.ps1 LogCollectorPi.ps1.backup
sudo wget https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/LogCollectorPi.ps1 -O LogCollectorPi.ps1
sudo chmod +x LogCollectorPi.ps1
sudo chown pi:pi LogCollectorPi.ps1
```

## 🛠️ Troubleshooting

### Common Issues

#### 1. PowerShell Not Found
```bash
# Check if installed
pwsh --version

# If not found, reinstall
wget https://github.com/PowerShell/PowerShell/releases/download/v7.5.3/powershell_7.5.3-1.deb_arm64.deb
sudo dpkg -i powershell_7.5.3-1.deb_arm64.deb
sudo apt-get install -f
```

#### 2. Permission Denied
```bash
# Fix permissions
sudo chmod +x /opt/logcollector/LogCollectorPi.ps1
sudo chown pi:pi /opt/logcollector/LogCollectorPi.ps1
sudo chmod +x ~/powershell/pwsh  # If PowerShell is in home directory
```

#### 3. Cannot Connect to Printer
```bash
# Test connectivity
ping 192.168.1.149

# Test web interface
curl -v http://192.168.1.149/accounting

# Check if printer requires authentication
curl -I http://192.168.1.149/accounting
```

#### 4. Email Sending Failed
- Verify SMTP server and port
- Check firewall settings
- Ensure credentials are correct
- For Gmail: Use App Password if 2FA is enabled
- Test SMTP connection: `telnet smtp.gmail.com 587`

#### 5. Out of Memory
```bash
# Increase swap space
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile
# Change CONF_SWAPSIZE=100 to CONF_SWAPSIZE=512
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# Check memory usage
free -h
```

#### 6. Script Runs But No Files Downloaded
- Check printer IP and path are correct
- Verify printer web interface is accessible
- Check if files exist on printer
- Review script output for error messages

### Diagnostic Commands

```bash
# System resources
htop                           # CPU and memory usage
free -h                        # Memory usage
df -h                          # Disk usage
vcgencmd measure_temp          # Pi temperature

# Network
ip addr show                   # Network interfaces
ping 192.168.1.149            # Printer connectivity
netstat -an | grep :587       # SMTP connection

# Services
sudo systemctl status logcollector.service
sudo systemctl status logcollector.timer
crontab -l                     # List cron jobs

# Logs
tail -f /var/log/logcollector.log
sudo journalctl -xe
dmesg | tail
```

## 📁 File Structure

```
LogCollectorPi/
├── LogCollectorPi.ps1              # Main PowerShell script
├── install_pi.sh                   # Automated installer
├── update_pi.sh                    # Update script
├── run_logcollector.sh             # Wrapper script
├── FixPermission.sh                # Permission fix script
├── Configuration_Template.ps1      # Configuration template
├── logcollector.service            # Systemd service file
├── logcollector.timer              # Systemd timer file
├── RaspberryPi_Setup_Guide.md      # Detailed setup guide
├── Pi_Quick_Start.md               # Quick start guide
└── README.md                       # This file
```

### File Descriptions

| File | Purpose |
|------|---------|
| `LogCollectorPi.ps1` | Main script that downloads logs and sends emails |
| `install_pi.sh` | One-command installer for complete setup |
| `update_pi.sh` | Updates the script from GitHub with backup |
| `run_logcollector.sh` | Bash wrapper to run the PowerShell script |
| `FixPermission.sh` | Fixes common permission issues |
| `Configuration_Template.ps1` | Template with all configuration options |
| `logcollector.service` | Systemd service definition |
| `logcollector.timer` | Systemd timer for scheduling |
| `RaspberryPi_Setup_Guide.md` | Comprehensive setup documentation |
| `Pi_Quick_Start.md` | Quick 5-minute setup guide |

## 🎛️ Pi Zero 2W Optimizations

This project is specifically optimized for the Raspberry Pi Zero 2W:

### Memory Management
- **RAM Usage**: ~50MB during execution
- **Storage**: Uses `/tmp` (RAM disk) for temporary files
- **Cleanup**: Automatic old file cleanup
- **Limits**: 200MB memory limit in systemd service

### Performance
- **Timeouts**: 30s for web requests, 60s for downloads
- **CPU**: 50% CPU quota to prevent system overload
- **Single-threaded**: Avoids parallel processing overhead

### Power Efficiency
- Minimal service footprint
- Configurable execution frequency
- Efficient regex parsing
- Optimized network operations

## 🔐 Security Considerations

### Best Practices
- ✅ Use dedicated email account for automation
- ✅ Enable App Passwords for Gmail/Outlook
- ✅ Keep printer on local network only
- ✅ Regular system updates
- ✅ Change default Pi passwords
- ✅ Use SSH keys instead of passwords
- ✅ Enable firewall (UFW)

### Securing Your Pi
```bash
# Change default password
passwd

# Setup firewall
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable

# Disable password authentication (use SSH keys)
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart ssh
```

## 📊 Monitoring & Maintenance

### Regular Tasks
- **Weekly**: Check logs and email delivery
- **Monthly**: Verify printer connectivity and disk space
- **Quarterly**: Update system packages and PowerShell

### Backup
```bash
# Backup configuration
sudo tar -czf ~/logcollector-backup-$(date +%Y%m%d).tar.gz /opt/logcollector

# Backup to another location
scp ~/logcollector-backup-*.tar.gz user@backup-server:/backups/
```

### Updates
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Update PowerShell (if new version available)
# Check: https://github.com/PowerShell/PowerShell/releases
```

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on Pi Zero 2W
5. Submit a pull request

## 📄 License

This project is open source. Please ensure compliance with your organization's policies when using in production environments.

## 🆘 Support

### Getting Help
1. Check this README and documentation
2. Review system logs
3. Test individual components
4. Verify network connectivity
5. Check GitHub issues

### Useful Resources
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- [Raspberry Pi Documentation](https://www.raspberrypi.org/documentation/)
- [Systemd Documentation](https://systemd.io/)
- [Cron Tutorial](https://crontab.guru/)

## 🏆 Features Overview

| Feature | Status | Notes |
|---------|--------|-------|
| Automated log collection | ✅ | Downloads latest 2 files |
| Email notifications | ✅ | Success, failure, and offline scenarios |
| Pi Zero 2W optimized | ✅ | Memory and CPU limits |
| Auto-update | ✅ | From GitHub repository |
| Cron scheduling | ✅ | Flexible time intervals |
| Systemd service | ✅ | Advanced scheduling |
| Error handling | ✅ | Comprehensive error reporting |
| Resource cleanup | ✅ | Automatic old file deletion |
| Configuration template | ✅ | Easy setup |
| Multiple printers | ⚠️ | Requires script modification |
| Web dashboard | ❌ | Planned for future |

## 🎉 Acknowledgments

Built with:
- PowerShell Core
- Raspberry Pi Zero 2W
- Love for automation

---

**Version**: 1.0  
**Last Updated**: October 2025  
**Maintainer**: KenyLukCraft  
**Repository**: https://github.com/KenyLukCraft/OnelinePowerShell

**Ready to automate your printer log collection!** 🚀

