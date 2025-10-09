# LogCollectorPi - Quick Reference Card

**Version**: 1.0.0 | **Updated**: October 9, 2025

---

## 🚀 Quick Install (One Command)
```bash
wget https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/install_pi.sh && chmod +x install_pi.sh && sudo ./install_pi.sh
```

## 📁 Project Files (14 Total)

| File | Size | Purpose |
|------|------|---------|
| LogCollectorPi.ps1 | 11KB | Main script |
| install_pi.sh | 12KB | Installer |
| update_pi.sh | 3KB | Updater |
| run_logcollector.sh | 1KB | Wrapper |
| FixPermission.sh | 754B | Fix perms |
| Configuration_Template.ps1 | 4KB | Config |
| logcollector.service | 786B | Systemd |
| logcollector.timer | 604B | Timer |
| README.md | 16KB | Main docs |
| INDEX.md | 11KB | File index |
| VERSION.md | 5KB | Versions |
| GITHUB_SYNC_STATUS.md | 9KB | Sync info |
| Pi_Quick_Start.md | 5KB | Quick guide |
| RaspberryPi_Setup_Guide.md | 11KB | Full guide |

## 🔗 Essential URLs

### Download
```
https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/install_pi.sh
https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/update_pi.sh
https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/LogCollectorPi.ps1
```

### Browse
```
https://github.com/KenyLukCraft/OnelinePowerShell/tree/main/LogCollectorPi
```

## ⚙️ Configuration (Edit LogCollectorPi.ps1)

```powershell
$baseUrl = "http://192.168.1.149"     # Printer IP
$pagePath = "/accounting"              # Log path
$smtpServer = "smtp.gmail.com"        # SMTP
$smtpPort = 587                       # Port
$fromEmail = "your@email.com"         # From
$toEmail = @("recipient@email.com")   # To
$base64Password = "BASE64_HERE"       # Encoded password
```

### Encode Password
```bash
pwsh -Command '$pwd = "your_password"; [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($pwd))'
```

## 🎯 Common Commands

### Manual Run
```bash
cd /opt/logcollector
sudo pwsh -File LogCollectorPi.ps1
```

### View Logs
```bash
tail -f /var/log/logcollector.log
sudo journalctl -u logcollector.service -f
```

### Update
```bash
cd /opt/logcollector
wget https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/update_pi.sh
chmod +x update_pi.sh
sudo ./update_pi.sh
```

### Fix Permissions
```bash
cd /opt/logcollector
sudo ./FixPermission.sh
```

## ⏰ Scheduling

### Cron (Every 6 hours)
```bash
crontab -e
# Add: 0 */6 * * * cd /opt/logcollector && pwsh -File LogCollectorPi.ps1 >> /var/log/logcollector.log 2>&1
```

### Systemd
```bash
sudo systemctl enable logcollector.timer
sudo systemctl start logcollector.timer
sudo systemctl status logcollector.timer
```

## 🛠️ Troubleshooting

### Test Printer
```bash
ping 192.168.1.149
curl -I http://192.168.1.149/accounting
```

### Check PowerShell
```bash
pwsh --version
which pwsh
```

### System Resources
```bash
free -h                    # Memory
df -h                      # Disk
vcgencmd measure_temp      # Temperature
htop                       # All resources
```

### Service Status
```bash
sudo systemctl status logcollector.service
sudo systemctl status logcollector.timer
crontab -l
```

## 📚 Documentation

| Need | Read |
|------|------|
| Quick setup | Pi_Quick_Start.md |
| Full guide | RaspberryPi_Setup_Guide.md |
| Configuration | Configuration_Template.ps1 |
| All features | README.md |
| File info | INDEX.md |
| Versions | VERSION.md |

## 🎛️ Common Printer Paths

| Brand | Path |
|-------|------|
| Canon | `/accounting` |
| HP | `/hp/device/this/status` |
| Epson | `/logs` |
| Brother | `/logs` |

## 📧 Common SMTP Settings

| Provider | Server | Port |
|----------|--------|------|
| Gmail | smtp.gmail.com | 587 |
| Outlook | smtp-mail.outlook.com | 587 |
| Yahoo | smtp.mail.yahoo.com | 587 |
| Zoho | smtp.zoho.com | 587 |
| Office 365 | smtp.office365.com | 587 |

## 💾 Git Commands (For Maintainers)

```bash
# Stage files
cd C:\Users\Keny\PycharmProjects\OnelinePowerShell
git add LogCollectorPi/

# Check status
git status

# Commit
git commit -m "Consolidate LogCollectorPi project"

# Push
git push origin main
```

## ✅ Post-Install Checklist

- [ ] PowerShell installed (`pwsh --version`)
- [ ] Script configured (printer IP, email)
- [ ] Password encoded
- [ ] Manual test successful
- [ ] Logs visible
- [ ] Scheduling configured
- [ ] Email received

## 🎯 Quick Paths

| Location | Path |
|----------|------|
| Script | `/opt/logcollector/LogCollectorPi.ps1` |
| Logs | `/var/log/logcollector.log` |
| Downloads | `/tmp/printer_logs/` |
| Service | `/etc/systemd/system/logcollector.service` |
| Timer | `/etc/systemd/system/logcollector.timer` |

## 📞 Support

1. Check README.md
2. Check RaspberryPi_Setup_Guide.md
3. Check GitHub issues
4. Create new issue with details

---

**Repository**: https://github.com/KenyLukCraft/OnelinePowerShell  
**Project**: https://github.com/KenyLukCraft/OnelinePowerShell/tree/main/LogCollectorPi  
**Version**: 1.0.0

