# PRISMA - Printer Log Collection System

A comprehensive PowerShell-based solution for automated printer log collection and email delivery, with support for both Windows and Raspberry Pi Zero 2W platforms.

## 🚀 Features

- **Automated Log Collection**: Downloads latest CSV and ACL files from network printers
- **Email Integration**: Automatically sends collected logs via email with attachments
- **Multi-Platform Support**: Works on Windows and Raspberry Pi Zero 2W
- **Lightweight Pi Version**: Optimized for resource-constrained devices
- **Secure Credentials**: Base64 encoded password storage
- **Flexible Scheduling**: Cron jobs or systemd services for automation
- **Easy Configuration**: Simple setup with comprehensive guides

## 📁 Project Structure

```
PRISMA/
├── SimpleVersion/                    # Lightweight Pi-optimized version
│   ├── LogCollectorPi.ps1           # Main Pi script
│   ├── install_pi.sh                # Automated Pi installer
│   ├── logcollector.service         # Systemd service file
│   ├── logcollector.timer           # Systemd timer file
│   ├── RaspberryPi_Setup_Guide.md   # Detailed Pi setup guide
│   ├── Pi_Quick_Start.md            # Quick Pi setup guide
│   └── Configuration_Template.ps1   # Configuration template
├── LogCollectorEncrypt.ps1          # Main Windows script
├── LogCollectorEncrypt_Configuration_Guide.md  # Windows setup guide
├── test_csv_acl_oneliner.ps1        # Test script
└── README.md                        # This file
```

## 🖥️ Windows Version

### Quick Start
1. Download `LogCollectorEncrypt.ps1`
2. Configure printer IP and email settings
3. Run: `.\LogCollectorEncrypt.ps1`
4. Set up Windows Task Scheduler for automation

### Features
- Full-featured log collection
- Automatic file sorting by date
- Email delivery with attachments
- Comprehensive error handling

## 🍓 Raspberry Pi Zero 2W Version

### Quick Start (5 minutes)
```bash
# SSH into your Pi
ssh pi@raspberrypi.local

# Download and run installer
wget https://raw.githubusercontent.com/KenyLukCraft/PRISMA/main/SimpleVersion/install_pi.sh
chmod +x install_pi.sh
sudo ./install_pi.sh
```

### Pi Optimizations
- **Memory Efficient**: ~50MB RAM usage
- **Storage Optimized**: Uses RAM disk for downloads
- **Resource Limits**: Prevents system overload
- **Automatic Cleanup**: Manages disk space

## ⚙️ Configuration

### Printer Settings
```powershell
$baseUrl = "http://192.168.1.149"    # Your printer's IP
$pagePath = "/accounting"             # Log page path
```

### Email Settings
```powershell
$smtpServer = "smtp.gmail.com"       # Your SMTP server
$smtpPort = 587
$fromEmail = "your_email@gmail.com"  # Sender email
$toEmail = @("recipient@company.com") # Recipients
```

### Common Printer Paths
- **Canon**: `/accounting`, `/logs`, `/status`
- **HP**: `/hp/device/this/status`, `/hp/device/this/logs`
- **Epson**: `/logs`, `/status`, `/maintenance`
- **Brother**: `/logs`, `/status`, `/maintenance`

## 📧 Email Provider Setup

### Gmail
```powershell
$smtpServer = "smtp.gmail.com"
$smtpPort = 587
# Note: Use App Password if 2FA is enabled
```

### Outlook/Hotmail
```powershell
$smtpServer = "smtp-mail.outlook.com"
$smtpPort = 587
```

### Office 365
```powershell
$smtpServer = "smtp.office365.com"
$smtpPort = 587
```

## 🔧 Installation

### Windows
1. Ensure PowerShell 5.1+ is installed
2. Download the script
3. Configure settings
4. Test manually
5. Set up Task Scheduler

### Raspberry Pi
1. Flash Raspberry Pi OS Lite
2. Run the automated installer
3. Configure settings
4. Choose scheduling method (cron/systemd)

## 📊 Monitoring

### Check Status
```bash
# View logs
tail -f /var/log/logcollector.log

# Check system resources
htop

# Monitor temperature (Pi)
vcgencmd measure_temp
```

### Troubleshooting
```bash
# Test connectivity
ping [PRINTER_IP]

# Test web interface
curl -I http://[PRINTER_IP]/accounting

# Check service status
sudo systemctl status logcollector.timer
```

## 🛡️ Security

### Best Practices
- Use dedicated email accounts for automation
- Enable App Passwords for Gmail/Outlook
- Keep printer web interfaces on local network only
- Regular system updates
- Monitor log files for sensitive information

### Pi Security
- Change default passwords
- Setup firewall (UFW)
- Disable unnecessary services
- Use SSH keys instead of passwords

## 📈 Performance

### Windows
- Minimal resource usage
- Efficient file processing
- Background execution support

### Pi Zero 2W
- Optimized for 512MB RAM
- Uses RAM disk for temporary files
- Automatic cleanup prevents disk issues
- Configurable resource limits

## 🔄 Automation

### Windows Task Scheduler
- Daily execution at specified times
- Run with highest privileges
- Log all output for debugging

### Pi Cron Jobs
```bash
# Every 6 hours
0 */6 * * * cd /opt/logcollector && pwsh -File LogCollectorPi.ps1

# Daily at 2 AM
0 2 * * * cd /opt/logcollector && pwsh -File LogCollectorPi.ps1
```

### Pi Systemd Services
- More control over execution
- Better logging and monitoring
- Resource limits and security settings

## 📚 Documentation

- **[Windows Setup Guide](LogCollectorEncrypt_Configuration_Guide.md)**: Comprehensive Windows configuration
- **[Pi Setup Guide](SimpleVersion/RaspberryPi_Setup_Guide.md)**: Detailed Pi installation
- **[Pi Quick Start](SimpleVersion/Pi_Quick_Start.md)**: 5-minute Pi setup
- **[Configuration Template](SimpleVersion/Configuration_Template.ps1)**: Easy configuration

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is open source. Please ensure compliance with your organization's policies when using in production environments.

## 🆘 Support

### Common Issues
1. **"Cannot connect to printer"**: Check IP address and network connectivity
2. **"Email sending failed"**: Verify SMTP settings and credentials
3. **"Out of memory" (Pi)**: Increase swap space or optimize system
4. **"Permission denied"**: Check file permissions and execution policy

### Getting Help
1. Check the documentation
2. Review system logs
3. Test individual components
4. Verify network connectivity

## 🏷️ Version History

- **v1.0**: Initial release with Windows support
- **v1.1**: Added Raspberry Pi Zero 2W support
- **v1.2**: Enhanced security and performance optimizations

---

**Ready to automate your printer log collection!** 🎉

For questions or support, please open an issue in this repository.