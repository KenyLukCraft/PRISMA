# Different Secure Password Methods for PowerShell Email Scripts

Write-Host "=== Secure Password Options ===" -ForegroundColor Green

# Option 1: Interactive Prompt (Most Secure)
Write-Host "`n1. Interactive Credential Prompt:" -ForegroundColor Yellow
Write-Host "   Always prompts for password when script runs" -ForegroundColor Cyan
Write-Host '   $credential = Get-Credential -UserName "kenyluk@zohomail.cn"' -ForegroundColor White

# Option 2: Encrypted File Storage (Automated + Secure)
Write-Host "`n2. Encrypted File Storage (CURRENT METHOD):" -ForegroundColor Yellow
Write-Host "   Encrypts password file tied to your Windows account" -ForegroundColor Cyan
Write-Host '   $credential = Import-Clixml -Path ".\email_credential.xml"' -ForegroundColor White

# Option 3: Environment Variable (Less Secure)
Write-Host "`n3. Environment Variable:" -ForegroundColor Yellow
Write-Host "   Store password in Windows environment variable" -ForegroundColor Cyan
Write-Host '   [Environment]::SetEnvironmentVariable("EMAIL_PASSWORD", "your-password", "User")' -ForegroundColor White
Write-Host '   $securePassword = ConvertTo-SecureString $env:EMAIL_PASSWORD -AsPlainText -Force' -ForegroundColor White

# Option 4: Windows Credential Manager (Advanced)
Write-Host "`n4. Windows Credential Manager:" -ForegroundColor Yellow
Write-Host "   Store in Windows built-in credential store" -ForegroundColor Cyan
Write-Host '   cmdkey /generic:"EmailScript" /user:"kenyluk@zohomail.cn" /pass:"your-password"' -ForegroundColor White
Write-Host '   $credential = Get-StoredCredential -Target "EmailScript"' -ForegroundColor White

# Security Comparison
Write-Host "`n=== Security Comparison ===" -ForegroundColor Green
Write-Host "Most Secure   → Interactive Prompt (requires manual input)" -ForegroundColor Green
Write-Host "Recommended   → Encrypted File (current method - automated + secure)" -ForegroundColor Yellow
Write-Host "Moderate      → Windows Credential Manager" -ForegroundColor Orange
Write-Host "Least Secure  → Environment Variable or Plain Text" -ForegroundColor Red

Write-Host "`n=== Current Implementation ===" -ForegroundColor Green
Write-Host "Your LogCollector.ps1 now uses Method 2 (Encrypted File Storage)" -ForegroundColor White
Write-Host "- Password is encrypted and tied to your Windows user account" -ForegroundColor Cyan
Write-Host "- Fully automated - no prompts after initial setup" -ForegroundColor Cyan
Write-Host "- Other users cannot decrypt your credential file" -ForegroundColor Cyan 