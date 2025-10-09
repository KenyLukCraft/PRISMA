# Secure Email Credential Setup Script
# Run this once to set up encrypted credentials for LogCollector.ps1

Write-Host "=== Secure Email Credential Setup ===" -ForegroundColor Green

# Method 1: Create encrypted credential file (recommended for automation)
Write-Host "`n1. Creating encrypted credential file..." -ForegroundColor Yellow
$fromEmail = "kenyluk@zohomail.cn"
$credentialPath = ".\email_credential.xml"

$credential = Get-Credential -UserName $fromEmail -Message "Enter your email password"
$credential | Export-Clixml -Path $credentialPath

Write-Host "✓ Credentials encrypted and saved to: $credentialPath" -ForegroundColor Green
Write-Host "  - This file can only be decrypted by your Windows user account" -ForegroundColor Cyan
Write-Host "  - LogCollector.ps1 will automatically use this file" -ForegroundColor Cyan

# Method 2: Test the encrypted credentials
Write-Host "`n2. Testing encrypted credentials..." -ForegroundColor Yellow
try {
    $testCred = Import-Clixml -Path $credentialPath
    Write-Host "✓ Credentials loaded successfully!" -ForegroundColor Green
    Write-Host "  - Username: $($testCred.UserName)" -ForegroundColor Cyan
    Write-Host "  - Password: [ENCRYPTED - HIDDEN]" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Failed to load credentials: $($_.Exception.Message)" -ForegroundColor Red
}

# Method 3: Show how to delete credentials if needed
Write-Host "`n3. Security Notes:" -ForegroundColor Yellow
Write-Host "  - To delete stored credentials: Remove-Item '$credentialPath'" -ForegroundColor Cyan
Write-Host "  - Credentials are tied to your Windows user account" -ForegroundColor Cyan
Write-Host "  - Different users cannot decrypt your credential file" -ForegroundColor Cyan

Write-Host "`n=== Setup Complete! ===" -ForegroundColor Green
Write-Host "You can now run LogCollector.ps1 without entering passwords." -ForegroundColor White 