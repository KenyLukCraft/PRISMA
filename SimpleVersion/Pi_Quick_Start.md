# Raspberry Pi Zero 2W Quick Start Guide

## 🚀 Quick Setup (5 minutes)

### 1. Prepare Your Pi
```bash
# Flash Raspberry Pi OS Lite to microSD card
# Enable SSH and WiFi (create files on boot partition)
```

### 2. Connect and Install
```bash
# SSH into your Pi
ssh pi@raspberrypi.local

# Download and run the installer
wget https://raw.githubusercontent.com/your-repo/install_pi.sh
chmod +x install_pi.sh
sudo ./install_pi.sh
```

### 3. Configure
```bash
# Edit the script configuration
sudo nano /opt/logcollector/LogCollectorPi.ps1

# Update these values:
# - $baseUrl = "http://YOUR_PRINTER_IP"
# - $pagePath = "/accounting"  # or your printer's log path
# - $smtpServer = "smtp.gmail.com"
# - $fromEmail = "your_email@gmail.com"
# - $toEmail = @("recipient@company.com")
```

### 4. Test
```bash
# Test the script
cd /opt/logcollector
sudo pwsh -File LogCollectorPi.ps1
```

### 5. Enable Automation
The installer will set up automatic execution. Choose your preferred method:
- **Cron job** (recommended for Pi Zero 2W)
- **Systemd service** (more control)

## 📁 Files Included

| File | Purpose |
|------|---------|
| `LogCollectorPi.ps1` | Main lightweight script |
| `install_pi.sh` | Automated installer |
| `logcollector.service` | Systemd service file |
| `logcollector.timer` | Systemd timer file |
| `RaspberryPi_Setup_Guide.md` | Detailed setup guide |

## ⚡ Pi Zero 2W Optimizations

### Memory Usage
- **RAM**: ~50MB during execution
- **Storage**: Uses `/tmp` (RAM disk) for downloads
- **Cleanup**: Automatic file cleanup

### Performance
- **Timeout**: 30s web requests, 60s downloads
- **Concurrent**: Single-threaded execution
- **Resource limits**: 200MB memory, 50% CPU

### Power Efficiency
- **Minimal services**: Disabled Bluetooth, audio
- **Swap**: 512MB for memory management
- **Scheduling**: Configurable execution frequency

## 🔧 Configuration Examples

### Canon Printer
```powershell
$baseUrl = "http://192.168.1.100"
$pagePath = "/accounting"
```

### HP Printer
```powershell
$baseUrl = "http://192.168.1.200"
$pagePath = "/hp/device/this/status"
```

### Gmail SMTP
```powershell
$smtpServer = "smtp.gmail.com"
$smtpPort = 587
# Note: Use App Password if 2FA enabled
```

## 📊 Monitoring

### Check Status
```bash
# View recent logs
tail -f /var/log/logcollector.log

# Check system resources
htop

# Monitor temperature
vcgencmd measure_temp

# Check service status
sudo systemctl status logcollector.timer
```

### Troubleshooting
```bash
# Test printer connectivity
ping 192.168.1.149

# Test web interface
curl -I http://192.168.1.149/accounting

# Check PowerShell
pwsh --version

# View system logs
sudo journalctl -u logcollector.service -f
```

## 🛡️ Security

### Basic Security
```bash
# Change default password
passwd

# Setup firewall
sudo ufw enable
sudo ufw allow ssh

# Disable password SSH (use keys)
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
```

### Email Security
- Use App Passwords for Gmail/Outlook
- Consider dedicated email account
- Monitor email delivery

## 📈 Performance Tips

### For Pi Zero 2W
1. **Use Pi OS Lite** (no desktop)
2. **Wired Ethernet** preferred over WiFi
3. **Run during off-peak hours**
4. **Monitor memory usage** regularly
5. **Use cron** instead of systemd for simple scheduling

### Network Optimization
1. **Stable connection** to printer
2. **Local network** only (no internet required for printer access)
3. **Test connectivity** before automation

## 🔄 Maintenance

### Regular Tasks
- **Weekly**: Check logs and email delivery
- **Monthly**: Verify printer connectivity
- **Quarterly**: Update system packages

### Backup
```bash
# Backup configuration
sudo tar -czf logcollector-backup.tar.gz /opt/logcollector /etc/crontab
```

### Updates
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Update PowerShell (if needed)
sudo apt install --only-upgrade powershell
```

## 🆘 Support

### Common Issues
1. **"Out of memory"** → Increase swap space
2. **"Cannot connect"** → Check network and printer IP
3. **"Email failed"** → Verify SMTP settings and credentials
4. **"Permission denied"** → Check file permissions

### Getting Help
1. Check the detailed setup guide
2. Review system logs
3. Test individual components
4. Verify network connectivity

---

**Ready to go!** Your Pi Zero 2W will now automatically collect printer logs and email them on schedule. 🎉
