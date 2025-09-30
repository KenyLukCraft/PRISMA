# LogCollectorPi.ps1 - Lightweight version for Raspberry Pi Zero 2W
# Optimized for minimal resource usage and Pi compatibility

# =============================================================================
# CONFIGURATION (Modify these values for your setup)
# =============================================================================
$baseUrl = "http://192.168.1.149"
$pagePath = "/accounting"
$outputFile = "download_links.txt"

# Email configuration
$smtpServer = "smtp.zoho.com.cn"
$smtpPort = 587
$fromEmail = "kenyluk@zohomail.cn"
$toEmail = @("keny_luk@chk.canon.com.hk", "prismaixlog@gmail.com")

# Portable password (Base64 encoded)
$base64Password = "ZGVtbWkwLXB1Z0R5ei1jaWtzeXA="
$emailPassword = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($base64Password))
$credential = New-Object System.Management.Automation.PSCredential($fromEmail, (ConvertTo-SecureString $emailPassword -AsPlainText -Force))

# Pi-optimized download folder (use /tmp for minimal disk usage)
$downloadFolder = "/tmp/printer_logs"
if (-not (Test-Path $downloadFolder)) {
    New-Item -ItemType Directory -Path $downloadFolder -Force | Out-Null
}

# =============================================================================
# MAIN EXECUTION (Optimized for Pi Zero 2W)
# =============================================================================

try {
    # Fetch webpage with timeout and minimal memory usage
    Write-Host "Connecting to printer..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri ("$baseUrl$pagePath") -UseBasicParsing -TimeoutSec 30
    $html = $response.Content

    # Extract CSV/ACL files in one efficient operation
    $csvAclUrls = [regex]::Matches($html, 'href="([^"]*\.(csv|acl))"', 'IgnoreCase') | 
                  ForEach-Object { 
                      $url = $_.Groups[1].Value
                      if ($url -notmatch '^https?://') {
                          if ($url.StartsWith('/')) { "$baseUrl$url" } else { "$baseUrl/$url" }
                      } else { $url }
                  } | Sort-Object -Unique

    if ($csvAclUrls.Count -eq 0) {
        Write-Host "No CSV or ACL files found!" -ForegroundColor Red
        exit 1
    }

    Write-Host "Found $($csvAclUrls.Count) CSV/ACL files" -ForegroundColor Green

    # Find latest files by date (extract YYYYMMDD from filename)
    $latestFiles = $csvAclUrls | ForEach-Object {
        $fileName = Split-Path $_ -Leaf
        $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        if ($nameWithoutExt.Length -ge 8) {
            $dateStr = $nameWithoutExt.Substring($nameWithoutExt.Length - 8)
            try {
                $dateObj = [DateTime]::ParseExact($dateStr, "yyyyMMdd", $null)
                [PSCustomObject]@{ URL = $_; FileName = $fileName; Date = $dateObj }
            } catch { $null }
        }
    } | Where-Object { $_ } | Sort-Object Date -Descending | Select-Object -First 2

    if ($latestFiles.Count -eq 0) {
        Write-Host "No valid dated files found!" -ForegroundColor Red
        exit 1
    }

    # Download latest files with progress indication
    $destPaths = @()
    foreach ($file in $latestFiles) {
        $destPath = Join-Path $downloadFolder $file.FileName
        try {
            Write-Host "Downloading: $($file.FileName)..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri $file.URL -OutFile $destPath -TimeoutSec 60
            Write-Host "✓ Downloaded: $($file.FileName)" -ForegroundColor Green
            $destPaths += $destPath
        } catch {
            Write-Host "✗ Failed: $($file.FileName) - $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    # Send email if files were downloaded
    if ($destPaths.Count -gt 0) {
        Write-Host "Sending email..." -ForegroundColor Cyan
        $fileNames = $latestFiles | Select-Object -First $destPaths.Count | ForEach-Object { $_.FileName }
        $emailSubject = "Pi Log Files - $($fileNames -join ', ')"
        $emailBody = "Latest printer log files from Raspberry Pi.`nFiles: $($fileNames -join ', ')`nTimestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        
        Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $credential -From $fromEmail -To $toEmail -Subject $emailSubject -Body $emailBody -Attachments $destPaths -TimeoutSec 30
        Write-Host "✓ Email sent successfully!" -ForegroundColor Green
    }

    # Cleanup old files to save disk space (keep only last 5 files)
    $oldFiles = Get-ChildItem $downloadFolder -File | Sort-Object LastWriteTime -Descending | Select-Object -Skip 5
    if ($oldFiles) {
        $oldFiles | Remove-Item -Force
        Write-Host "Cleaned up $($oldFiles.Count) old files" -ForegroundColor Gray
    }

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Always cleanup on exit
    if (Test-Path $downloadFolder) {
        # Keep only the most recent files
        Get-ChildItem $downloadFolder -File | Sort-Object LastWriteTime -Descending | Select-Object -Skip 3 | Remove-Item -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Script completed successfully" -ForegroundColor Green
