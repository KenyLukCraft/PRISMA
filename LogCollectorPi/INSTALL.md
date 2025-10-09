# LogCollectorPi - Clean Installation Guide

**Simple, step-by-step installation for Raspberry Pi Zero 2W**

---

## 🎯 Overview

This guide will help you install LogCollectorPi on your Raspberry Pi Zero 2W in **less than 10 minutes**.

**What it does:**
- Connects to your printer's web interface
- Downloads latest 2 CSV/ACL log files
- Emails them to you automatically
- Runs on schedule (every 6 hours, daily, etc.)
- Sends alerts if printer goes offline

---

## 📋 Prerequisites

### Hardware
- Raspberry Pi Zero 2W (or any Pi model)
- MicroSD card (8GB+)
- Power supply
- Network connection (WiFi or Ethernet)

### Information You Need
Before starting, gather:
1. **Printer IP address** (e.g., `192.168.1.149`)
2. **Printer log path** (e.g., `/accounting`)
3. **Your email address** (for sending logs)
4. **Recipient email(s)** (who receives the logs)
5. **Email password** (SMTP credentials)
6. **SMTP server** (e.g., `smtp.gmail.com`)

---

## 🚀 Installation Steps

### Step 1: Prepare Your Raspberry Pi

**If you haven't set up your Pi yet:**

1. **Flash Raspberry Pi OS Lite** to your microSD card
   - Download: [Raspberry Pi Imager](https://www.raspberrypi.org/software/)
   - Choose: Raspberry Pi OS Lite (64-bit)

2. **Enable SSH** (create empty file named `ssh` on boot partition)

3. **Configure WiFi** (create `wpa_supplicant.conf` on boot partition):
   ```
   country=US
   ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
   update_config=1
   
   network={
       ssid="YOUR_WIFI_NAME"
       psk="YOUR_WIFI_PASSWORD"
   }
   ```

4. **Boot your Pi** and find its IP address

---

### Step 2: Connect to Your Pi

```bash
ssh pi@raspberrypi.local
# Default password: raspberry
```

**First time? Change your password:**
```bash
passwd
```

---

### Step 3: Run the Automated Installer

**One command installation:**

```bash
wget https://raw.githubusercontent.com/KenyLukCraft/PRISMA/master/LogCollectorPi/install_pi.sh && chmod +x install_pi.sh && sudo ./install_pi.sh
```

**What this does:**
- ✅ Installs PowerShell Core 7.5.3
- ✅ Creates necessary directories
- ✅ Downloads LogCollectorPi.ps1
- ✅ Sets up proper permissions
- ✅ Configures scheduling (your choice)
- ✅ Applies Pi Zero 2W optimizations

**The installer will ask you:**
- Whether to edit configuration now
- Whether to test the script
- How often to run (every 6 hours, daily, etc.)
- Whether to use cron or systemd
- Whether to apply Pi optimizations

---

### Step 4: Configure the Script

**Edit the configuration:**
```bash
sudo nano /opt/logcollector/LogCollectorPi.ps1
```

**Update these values** (lines 7-17):

```powershell
# Printer configuration
$baseUrl = "http://192.168.1.149"     # ← Your printer IP
$pagePath = "/accounting"              # ← Your printer log path

# Email configuration
$smtpServer = "smtp.gmail.com"        # ← Your SMTP server
$smtpPort = 587                       # ← SMTP port (usually 587)
$fromEmail = "your@email.com"         # ← Your email address
$toEmail = @("recipient@email.com")   # ← Who receives logs

# Password (Base64 encoded)
$base64Password = "YOUR_ENCODED_PASSWORD_HERE"  # ← See below
```

**Save and exit:** Press `Ctrl+X`, then `Y`, then `Enter`

---

### Step 5: Encode Your Password

**On your Pi (or any computer with PowerShell):**

```bash
pwsh -Command '
$password = "your_actual_password"
$encoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($password))
Write-Host "Your encoded password: $encoded"
'
```

**Copy the output** and paste it into the `$base64Password` line in Step 4.

**For Gmail users:** If you have 2-factor authentication, use an [App Password](https://support.google.com/accounts/answer/185833).

---

### Step 6: Test the Script

```bash
cd /opt/logcollector
sudo pwsh -File LogCollectorPi.ps1
```

**What to expect:**
- Script connects to printer
- Downloads latest 2 files
- Sends email with attachments
- Shows success message

**If successful, you'll see:**
```
✓ Downloaded: filename1.CSV
✓ Downloaded: filename2.ACL
✓ Email sent successfully with attachments!
Script completed successfully
```

---

### Step 7: Set Up Automatic Execution

The installer already set this up, but you can modify it:

#### Option A: Using Cron (Recommended)

```bash
crontab -e
```

**Add one of these schedules:**

```bash
# Every 6 hours (at 00:00, 06:00, 12:00, 18:00)
0 */6 * * * cd /opt/logcollector && pwsh -File LogCollectorPi.ps1 >> /var/log/logcollector.log 2>&1

# Daily at 2 AM
0 2 * * * cd /opt/logcollector && pwsh -File LogCollectorPi.ps1 >> /var/log/logcollector.log 2>&1

# Every 12 hours
0 */12 * * * cd /opt/logcollector && pwsh -File LogCollectorPi.ps1 >> /var/log/logcollector.log 2>&1

# Weekdays at 6 AM
0 6 * * 1-5 cd /opt/logcollector && pwsh -File LogCollectorPi.ps1 >> /var/log/logcollector.log 2>&1
```

#### Option B: Using Systemd

**Check if already enabled:**
```bash
sudo systemctl status logcollector.timer
```

**Enable/start:**
```bash
sudo systemctl enable logcollector.timer
sudo systemctl start logcollector.timer
```

**Modify schedule:**
```bash
sudo nano /etc/systemd/system/logcollector.timer
```

---

## ✅ Verification

### Check Logs
```bash
# View recent activity
tail -f /var/log/logcollector.log

# View systemd logs (if using systemd)
sudo journalctl -u logcollector.service -f
```

### Check Scheduled Tasks
```bash
# Cron
crontab -l

# Systemd
sudo systemctl list-timers logcollector.timer
```

### Test Printer Connectivity
```bash
ping 192.168.1.149
curl -I http://192.168.1.149/accounting
```

---

## 🎛️ Common Printer Settings

| Printer Brand | IP Example | Log Path | Notes |
|---------------|------------|----------|-------|
| **Canon** | 192.168.1.100 | `/accounting` | Most common |
| **HP** | 192.168.1.200 | `/hp/device/this/status` | or `/logs` |
| **Epson** | 192.168.1.300 | `/logs` | or `/status` |
| **Brother** | 192.168.1.400 | `/logs` | or `/maintenance` |

**Finding your printer's IP:**
```bash
# Check printer's display panel
# OR check your router's device list
# OR try: nmap -sn 192.168.1.0/24
```

---

## 📧 SMTP Server Settings

| Provider | SMTP Server | Port | Notes |
|----------|-------------|------|-------|
| **Gmail** | smtp.gmail.com | 587 | Use App Password if 2FA enabled |
| **Outlook/Hotmail** | smtp-mail.outlook.com | 587 | |
| **Yahoo** | smtp.mail.yahoo.com | 587 | |
| **Office 365** | smtp.office365.com | 587 | |
| **Zoho** | smtp.zoho.com | 587 | Different for .cn |

---

## 🛠️ Troubleshooting

### PowerShell Not Found
```bash
# Check installation
pwsh --version

# If missing, install manually
wget https://github.com/PowerShell/PowerShell/releases/download/v7.5.3/powershell_7.5.3-1.deb_arm64.deb
sudo dpkg -i powershell_7.5.3-1.deb_arm64.deb
sudo apt-get install -f
```

### Permission Denied
```bash
# Fix all permissions
cd /opt/logcollector
sudo chmod +x LogCollectorPi.ps1
sudo chown pi:pi LogCollectorPi.ps1

# Or use fix script
sudo ./FixPermission.sh
```

### Cannot Connect to Printer
```bash
# Test network
ping 192.168.1.149

# Test printer web interface
curl -v http://192.168.1.149/accounting

# Check firewall
sudo ufw status
```

### Email Sending Failed
- ✅ Verify SMTP server and port
- ✅ Check credentials
- ✅ For Gmail: Enable "Less secure app access" or use App Password
- ✅ Test SMTP connection: `telnet smtp.gmail.com 587`

### Script Runs But No Email
- Check spam/junk folder
- Verify recipient email addresses
- Check system logs: `journalctl -xe`
- Test manually: `sudo pwsh -File LogCollectorPi.ps1`

---

## 🔄 Updating

**To update to the latest version:**

```bash
cd /opt/logcollector
wget https://raw.githubusercontent.com/KenyLukCraft/PRISMA/master/LogCollectorPi/update_pi.sh
chmod +x update_pi.sh
sudo ./update_pi.sh
```

**What the updater does:**
- ✅ Creates backup of current script
- ✅ Downloads latest version
- ✅ Validates syntax
- ✅ Restarts services
- ✅ Rolls back if there's an error

---

## 📊 Monitoring

### System Resources
```bash
# Memory usage
free -h

# Disk space
df -h

# CPU and temperature
htop
vcgencmd measure_temp
```

### Script Performance
```bash
# View last execution
tail -n 100 /var/log/logcollector.log

# Check cron execution
grep CRON /var/log/syslog

# Check systemd execution
sudo systemctl status logcollector.service
```

---

## 🔐 Security Tips

### 1. Change Default Password
```bash
passwd
```

### 2. Use SSH Keys (Optional but Recommended)
```bash
# On your computer, generate key
ssh-keygen -t rsa -b 4096

# Copy to Pi
ssh-copy-id pi@raspberrypi.local

# Disable password authentication
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart ssh
```

### 3. Enable Firewall
```bash
sudo apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable
```

### 4. Keep System Updated
```bash
sudo apt update && sudo apt upgrade -y
```

---

## 📁 File Locations

| Item | Path |
|------|------|
| Main Script | `/opt/logcollector/LogCollectorPi.ps1` |
| Downloaded Files | `/tmp/printer_logs/` |
| Log File | `/var/log/logcollector.log` |
| Systemd Service | `/etc/systemd/system/logcollector.service` |
| Systemd Timer | `/etc/systemd/system/logcollector.timer` |
| Cron Jobs | `crontab -l` |

---

## 🆘 Getting Help

1. **Check the logs first:**
   ```bash
   tail -f /var/log/logcollector.log
   ```

2. **Read the detailed guide:**
   - [Raspberry Pi Setup Guide](RaspberryPi_Setup_Guide.md)
   - [README](README.md)
   - [Quick Reference](QUICK_REFERENCE.md)

3. **Test components individually:**
   - Printer: `curl http://[PRINTER_IP]/accounting`
   - Email: Run script manually
   - PowerShell: `pwsh --version`

4. **GitHub Issues:**
   https://github.com/KenyLukCraft/PRISMA/issues

---

## ✅ Installation Checklist

- [ ] Raspberry Pi OS installed and booted
- [ ] SSH enabled and connected
- [ ] Ran installer script
- [ ] PowerShell installed (`pwsh --version`)
- [ ] Script configured (printer IP, email)
- [ ] Password encoded and added
- [ ] Manual test successful
- [ ] Email received
- [ ] Scheduling configured (cron or systemd)
- [ ] Logs visible (`tail -f /var/log/logcollector.log`)

---

## 🎉 Done!

Your LogCollectorPi is now set up and running!

**What happens next:**
- Script runs automatically on your schedule
- Downloads latest 2 log files from printer
- Emails them to you with timestamps
- Alerts you if printer goes offline
- Cleans up old files automatically

**You'll receive emails:**
- ✅ When files are successfully downloaded
- ⚠️ When printer is online but no files found
- ❌ When printer is offline or unreachable

---

**Version:** 1.0.0  
**Repository:** https://github.com/KenyLukCraft/PRISMA/tree/master/LogCollectorPi  
**Support:** https://github.com/KenyLukCraft/PRISMA/issues

**Happy automating!** 🚀

