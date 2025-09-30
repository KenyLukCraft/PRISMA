# LogCollectorEncrypt.ps1 Configuration and Operation Guide

## Overview
The `LogCollectorEncrypt.ps1` script is a PowerShell automation tool that:
- Connects to network printers via HTTP
- Downloads the latest log files (CSV and ACL formats)
- Automatically sends these files via email
- Uses encrypted credentials for security

## Prerequisites

### System Requirements
- Windows PowerShell 5.1 or PowerShell Core 6.0+
- Internet connectivity for email sending
- Access to the target printer's web interface

### Required PowerShell Modules
The script uses built-in PowerShell cmdlets, so no additional modules need to be installed.

## Configuration Guide

### 1. Printer Network Configuration

#### Base URL Configuration
```powershell
$baseUrl = "http://192.168.1.149"  # Change this to your printer's IP address
```

**How to find your printer's IP address:**
1. **From the printer's control panel:**
   - Navigate to Network Settings → Network Configuration
   - Look for IP Address or IPv4 Address

2. **From your network router:**
   - Access your router's admin panel
   - Check the DHCP client list or connected devices

3. **Using network discovery:**
   - Run `arp -a` in Command Prompt to see all devices on your network
   - Look for devices with manufacturer names like "Canon", "HP", "Epson", etc.

#### Page Path Configuration
```powershell
$pagePath = "/accounting"  # Change this to match your printer's log page
```

**Common page paths for different printer brands:**
- **Canon:** `/accounting`, `/logs`, `/status`
- **HP:** `/hp/device/this/status`, `/hp/device/this/logs`
- **Epson:** `/logs`, `/status`, `/maintenance`
- **Brother:** `/logs`, `/status`, `/maintenance`

**How to find the correct path:**
1. Open your browser and navigate to `http://[PRINTER_IP]`
2. Look for links to logs, accounting, or status pages
3. Check the URL in your browser's address bar when viewing logs

### 2. Email Configuration

#### SMTP Server Settings
```powershell
$smtpServer = "smtp.zoho.com.cn"  # Change to your email provider's SMTP server
$smtpPort = 587                    # Common ports: 587 (TLS), 465 (SSL), 25 (unencrypted)
```

**Popular SMTP servers:**
- **Gmail:** `smtp.gmail.com` (Port 587)
- **Outlook/Hotmail:** `smtp-mail.outlook.com` (Port 587)
- **Yahoo:** `smtp.mail.yahoo.com` (Port 587)
- **Zoho:** `smtp.zoho.com` (Port 587)
- **Office 365:** `smtp.office365.com` (Port 587)

#### Email Account Configuration
```powershell
$fromEmail = "kenyluk@zohomail.cn"  # Change to your email address
$toEmail = @("keny_luk@chk.canon.com.hk", "prismaixlog@gmail.com")  # Change recipient emails
```

**To add multiple recipients:**
```powershell
$toEmail = @("user1@company.com", "user2@company.com", "admin@company.com")
```

#### Password Security
The script uses Base64 encoding for the password. To change the password:

1. **Encode your new password:**
   ```powershell
   $newPassword = "your_new_password"
   $encodedPassword = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($newPassword))
   Write-Host $encodedPassword
   ```

2. **Update the script:**
   ```powershell
   $base64Password = "eW91cl9uZXdfcGFzc3dvcmQ="  # Replace with your encoded password
   ```

### 3. File Download Configuration

#### Download Directory
```powershell
$downloadFolder = "C:\Users\Keny\PycharmProjects\OnelinePowerShell\SimpleVersion\downloaded_files"
```
**Change this path to where you want to store downloaded files on your system.**

#### File Type Filtering
The script automatically filters for CSV and ACL files. If your printer uses different file extensions:
```powershell
# Modify this line to include other file types
$csvAclUrls = $fullUrls | Where-Object { $_ -match '\.(csv|acl|log|txt)$' }
```

## Operation Guide

### 1. Initial Setup

1. **Download the script** to your local machine
2. **Open PowerShell as Administrator** (right-click PowerShell → "Run as Administrator")
3. **Navigate to the script directory:**
   ```powershell
   cd "C:\path\to\your\script\folder"
   ```

### 2. First Run Configuration

1. **Edit the configuration variables** in the script using your preferred text editor
2. **Test the connection** by running:
   ```powershell
   .\LogCollectorEncrypt.ps1
   ```

### 3. Regular Operation

#### Manual Execution
```powershell
.\LogCollectorEncrypt.ps1
```

#### Automated Execution (Scheduled Task)
1. **Open Task Scheduler** (search for "Task Scheduler" in Start menu)
2. **Create Basic Task:**
   - Name: "LogCollector"
   - Trigger: Daily (or your preferred frequency)
   - Action: Start a program
   - Program: `powershell.exe`
   - Arguments: `-ExecutionPolicy Bypass -File "C:\path\to\LogCollectorEncrypt.ps1"`

#### Automated Execution (Windows Service)
For enterprise environments, consider creating a Windows service using tools like NSSM or WinSW.

### 4. Monitoring and Troubleshooting

#### Check Script Output
The script provides detailed output including:
- Number of links found
- Files being downloaded
- Email sending status

#### Common Issues and Solutions

**1. "Access Denied" Error:**
- Ensure PowerShell is running as Administrator
- Check file permissions on the download directory

**2. "Cannot connect to printer":**
- Verify the printer IP address is correct
- Check if the printer is powered on and connected to the network
- Test connectivity: `ping [PRINTER_IP]`

**3. "Email sending failed":**
- Verify SMTP server and port settings
- Check email credentials
- Ensure your email provider allows SMTP authentication
- Check if 2-factor authentication is enabled (may require app-specific passwords)

**4. "No CSV or ACL files found":**
- Verify the page path is correct
- Check if the printer actually has log files available
- Inspect the HTML source of the printer's web page

#### Debug Mode
To see more detailed information, you can add debug output:
```powershell
# Add this line after the HTML fetch to see the raw HTML
Write-Host "Raw HTML content:" -ForegroundColor Yellow
Write-Host $html.Substring(0, [Math]::Min(1000, $html.Length))
```

## Security Considerations

### 1. Credential Protection
- The script uses Base64 encoding for basic obfuscation
- For production use, consider using Windows Credential Manager or encrypted configuration files
- Never commit passwords to version control

### 2. Network Security
- Ensure the printer's web interface is not exposed to the internet
- Use HTTPS if available (though most printers only support HTTP)
- Consider implementing network segmentation for printer management

### 3. File Security
- Downloaded log files may contain sensitive information
- Implement appropriate access controls on the download directory
- Consider automatic cleanup of old log files

## Customization Examples

### Example 1: HP Printer Configuration
```powershell
$baseUrl = "http://192.168.1.100"
$pagePath = "/hp/device/this/status"
$smtpServer = "smtp.gmail.com"
$fromEmail = "admin@company.com"
```

### Example 2: Brother Printer Configuration
```powershell
$baseUrl = "http://192.168.1.200"
$pagePath = "/logs"
$smtpServer = "smtp-mail.outlook.com"
$fromEmail = "support@company.com"
```

### Example 3: Epson Printer Configuration
```powershell
$baseUrl = "http://192.168.1.300"
$pagePath = "/status"
$smtpServer = "smtp.zoho.com"
$fromEmail = "logs@company.com"
```

## Support and Maintenance

### Regular Maintenance Tasks
1. **Verify printer connectivity** monthly
2. **Check email delivery** weekly
3. **Review downloaded files** for completeness
4. **Update script** when printer firmware is updated

### Backup and Recovery
1. **Keep a backup** of your configured script
2. **Document your configuration** in a separate file
3. **Test the script** after any network changes

### Getting Help
If you encounter issues:
1. Check the script output for error messages
2. Verify all configuration parameters
3. Test network connectivity to the printer
4. Check email provider settings
5. Review this guide for common solutions

## Version History
- **v1.0:** Initial release with basic functionality
- Supports CSV and ACL file downloads
- Automatic email sending with attachments
- Base64 encoded password security

---

**Note:** This script is designed for internal network use. Ensure compliance with your organization's security policies and network management guidelines.
