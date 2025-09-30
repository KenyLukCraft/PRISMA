# LogCollectorEncrypt.ps1 Configuration Template
# Copy this file and modify the values below for your specific printer setup

# =============================================================================
# PRINTER NETWORK CONFIGURATION
# =============================================================================

# Change this to your printer's IP address
$baseUrl = "http://172.30.0.38"

# Change this to match your printer's log page path
# Common paths: /accounting, /logs, /status, /hp/device/this/status
$pagePath = "/accounting"

# =============================================================================
# EMAIL CONFIGURATION
# =============================================================================

# SMTP Server - Change to your email provider's server
$smtpServer = "smtp.zoho.com.cn"

# SMTP Port - Common ports: 587 (TLS), 465 (SSL), 25 (unencrypted)
$smtpPort = 587

# Sender email address
$fromEmail = "your_email@domain.com"

# Recipient email addresses (can be multiple)
$toEmail = @("recipient1@company.com", "recipient2@company.com")

# =============================================================================
# PASSWORD CONFIGURATION
# =============================================================================

# To encode your password, run this in PowerShell:
# $newPassword = "your_password_here"
# $encodedPassword = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($newPassword))
# Write-Host $encodedPassword
# Then copy the output below:

$base64Password = "eW91cl9wYXNzd29yZF9oZXJl"  # Replace with your encoded password

# =============================================================================
# FILE DOWNLOAD CONFIGURATION
# =============================================================================

# Local path to save downloaded files
$downloadFolder = "C:\Logs\PrinterLogs"  # Change to your preferred path

# =============================================================================
# COMMON PRINTER BRAND CONFIGURATIONS
# =============================================================================

# CANON PRINTERS
# $baseUrl = "http://192.168.1.100"
# $pagePath = "/accounting"

# HP PRINTERS
# $baseUrl = "http://192.168.1.200"
# $pagePath = "/hp/device/this/status"

# EPSON PRINTERS
# $baseUrl = "http://192.168.1.300"
# $pagePath = "/logs"

# BROTHER PRINTERS
# $baseUrl = "http://192.168.1.400"
# $pagePath = "/logs"

# =============================================================================
# COMMON EMAIL PROVIDER SETTINGS
# =============================================================================

# GMAIL
# $smtpServer = "smtp.gmail.com"
# $smtpPort = 587
# Note: May require App Password if 2FA is enabled

# OUTLOOK/HOTMAIL
# $smtpServer = "smtp-mail.outlook.com"
# $smtpPort = 587

# YAHOO
# $smtpServer = "smtp.mail.yahoo.com"
# $smtpPort = 587

# OFFICE 365
# $smtpServer = "smtp.office365.com"
# $smtpPort = 587

# ZOHO
# $smtpServer = "smtp.zoho.com"
# $smtpPort = 587

# =============================================================================
# USAGE INSTRUCTIONS
# =============================================================================

# 1. Copy this template to a new file
# 2. Modify the values above for your printer and email settings
# 3. Replace the configuration section in LogCollectorEncrypt.ps1 with your values
# 4. Test the script: .\LogCollectorEncrypt.ps1
# 5. Set up scheduled task for automatic execution

# =============================================================================
# TROUBLESHOOTING TIPS
# =============================================================================

# Test printer connectivity:
# ping [YOUR_PRINTER_IP]

# Test web interface:
# Open http://[YOUR_PRINTER_IP] in your browser

# Check PowerShell execution policy:
# Get-ExecutionPolicy
# If restricted, run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Test email credentials:
# Test-NetConnection -ComputerName [SMTP_SERVER] -Port [SMTP_PORT]
