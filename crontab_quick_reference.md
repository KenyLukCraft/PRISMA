# Crontab Quick Reference for LogCollectorPi.ps1

## 🚀 Quick Setup

### 1. Basic Setup (Raspberry Pi)
```bash
# Copy script to home directory
cp LogCollectorPi.ps1 /home/pi/
chmod +x /home/pi/LogCollectorPi.ps1

# Create log directory
sudo mkdir -p /var/log
sudo touch /var/log/logcollector.log
sudo chown pi:pi /var/log/logcollector.log

# Test the script
./run_logcollector.sh
```

### 2. Add to Crontab
```bash
# Edit crontab
sudo crontab -e

# Add one of these lines:
```

## 📅 Recommended Schedules

| Schedule | Crontab Entry | Description |
|----------|---------------|-------------|
| **Every 6 hours** | `0 */6 * * * /home/pi/run_logcollector.sh >> /var/log/logcollector.log 2>&1` | Most common |
| **Every 4 hours** | `0 */4 * * * /home/pi/run_logcollector.sh >> /var/log/logcollector.log 2>&1` | More frequent |
| **Twice daily** | `0 6,18 * * * /home/pi/run_logcollector.sh >> /var/log/logcollector.log 2>&1` | 6 AM & 6 PM |
| **Business hours** | `0 9-17 * * 1-5 /home/pi/run_logcollector.sh >> /var/log/logcollector.log 2>&1` | Weekdays 9-5 |
| **Every 2 hours** | `0 */2 * * * /home/pi/run_logcollector.sh >> /var/log/logcollector.log 2>&1` | High frequency |

## 🔧 Crontab Commands

```bash
# View current crontab
crontab -l

# Edit crontab
crontab -e

# Remove all crontab entries
crontab -r

# Test crontab syntax
echo "0 */6 * * * /usr/bin/pwsh -File /home/pi/LogCollectorPi.ps1" | crontab -
```

## 📊 Monitoring

```bash
# View logs in real-time
tail -f /var/log/logcollector.log

# View recent logs
tail -n 50 /var/log/logcollector.log

# Check if script is running
ps aux | grep LogCollectorPi

# Check crontab service
sudo systemctl status cron
```

## 🐛 Troubleshooting

### Common Issues

1. **PowerShell not found**
   ```bash
   # Install PowerShell
   curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
   echo 'deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-20.04-prod focal main' | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
   sudo apt update && sudo apt install -y powershell
   ```

2. **Permission denied**
   ```bash
   # Fix permissions
   sudo chown pi:pi /home/pi/LogCollectorPi.ps1
   chmod +x /home/pi/LogCollectorPi.ps1
   ```

3. **Script not running**
   ```bash
   # Check crontab logs
   sudo journalctl -u cron
   
   # Test manually
   /usr/bin/pwsh -File /home/pi/LogCollectorPi.ps1
   ```

4. **Email not sending**
   - Check email credentials in the script
   - Verify SMTP settings
   - Check network connectivity

## 📝 Crontab Format

```
* * * * * command
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, Sunday = 0 or 7)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

## 🎯 Best Practices

1. **Always test manually first**
2. **Use absolute paths** in crontab
3. **Redirect output** to log files
4. **Check logs regularly**
5. **Use appropriate frequency** (not too often)
6. **Monitor disk space** for downloaded files

## 🔄 Alternative: Systemd Timer

If you prefer systemd over crontab:

```bash
# Create service file
sudo nano /etc/systemd/system/logcollector.service

# Create timer file  
sudo nano /etc/systemd/system/logcollector.timer

# Enable and start
sudo systemctl enable logcollector.timer
sudo systemctl start logcollector.timer
```

See `crontab_examples.txt` for complete systemd service examples.
