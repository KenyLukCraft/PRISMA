# LogCollectorPi.ps1 - Lightweight version for Raspberry Pi Zero 2W
# Optimized for minimal resource usage and Pi compatibility

# =============================================================================
# CONFIGURATION (Modify these values for your setup)
# =============================================================================
$baseUrl = "http://172.30.0.38"
$pagePath = "/accounting"

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
    
    # Handle different content types properly
    if ($response.Content -is [byte[]]) {
        $html = [System.Text.Encoding]::UTF8.GetString($response.Content)
    } else {
        $html = $response.Content.ToString()
    }
    
    # Debug: Check HTML content type and length
    Write-Host "Debug: HTML content type: $($html.GetType().Name)" -ForegroundColor Gray
    Write-Host "Debug: HTML content length: $($html.Length)" -ForegroundColor Gray

    # Extract CSV/ACL files in one efficient operation
    $csvAclUrls = [regex]::Matches($html, 'href="([^"]*\.(CSV|ACL))"', 'IgnoreCase') | 
                  ForEach-Object { 
                      $url = $_.Groups[1].Value
                      if ($url -notmatch '^https?://') {
                          if ($url.StartsWith('/')) { "$baseUrl$url" } else { "$baseUrl/$url" }
                      } else { $url }
                  } | Sort-Object -Unique

    # Debug: Show all href links found
    Write-Host "Debug: All href links found:" -ForegroundColor Gray
    $allHrefs = [regex]::Matches($html, 'href="([^"]+)"', 'IgnoreCase')
    if ($allHrefs.Count -gt 0) {
        $allHrefs | ForEach-Object { Write-Host "  $($_.Groups[1].Value)" -ForegroundColor Gray }
    } else {
        Write-Host "  No href links found in HTML" -ForegroundColor Gray
    }

    if ($csvAclUrls.Count -eq 0) {
        Write-Host "No CSV or ACL files found!" -ForegroundColor Red
        Write-Host "Debug: HTML content preview (first 500 chars):" -ForegroundColor Yellow
        if ($html -and $html.Length -gt 0) {
            $previewLength = [Math]::Min(500, $html.Length)
            Write-Host $html.Substring(0, $previewLength) -ForegroundColor Gray
        } else {
            Write-Host "HTML content is empty or null" -ForegroundColor Red
        }
        Write-Host "`nTroubleshooting suggestions:" -ForegroundColor Yellow
        Write-Host "1. Check if printer IP is correct: $baseUrl" -ForegroundColor Gray
        Write-Host "2. Check if page path is correct: $pagePath" -ForegroundColor Gray
        Write-Host "3. Try running: pwsh -File diagnose_printer.ps1" -ForegroundColor Gray
        Write-Host "4. Check if printer requires authentication" -ForegroundColor Gray
        exit 1
    }

    Write-Host "Found $($csvAclUrls.Count) CSV/ACL files" -ForegroundColor Green

    # Find latest files by date (extract YYYYMMDD from filename)
    Write-Host "Processing $($csvAclUrls.Count) CSV/ACL files to find latest 2..." -ForegroundColor Cyan
    $latestFiles = $csvAclUrls | ForEach-Object {
        $fileName = Split-Path $_ -Leaf
        $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        Write-Host "  Processing: $fileName" -ForegroundColor Gray
        
        if ($nameWithoutExt.Length -ge 8) {
            $dateStr = $nameWithoutExt.Substring($nameWithoutExt.Length - 8)
            try {
                $dateObj = [DateTime]::ParseExact($dateStr, "yyyyMMdd", $null)
                Write-Host "    ✓ Valid date found: $dateStr ($dateObj)" -ForegroundColor Green
                [PSCustomObject]@{ URL = $_; FileName = $fileName; Date = $dateObj; DateString = $dateStr }
            } catch {
                Write-Host "    ✗ Invalid date format: $dateStr" -ForegroundColor Red
                $null
            }
        } else {
            Write-Host "    ✗ Filename too short for date extraction: $nameWithoutExt" -ForegroundColor Red
            $null
        }
    } | Where-Object { $_ } | Sort-Object Date -Descending | Select-Object -First 2

    if ($latestFiles.Count -eq 0) {
        Write-Host "No valid dated files found!" -ForegroundColor Red
        exit 1
    }

    Write-Host "Selected $($latestFiles.Count) latest files:" -ForegroundColor Green
    $latestFiles | ForEach-Object { 
        Write-Host "  - $($_.FileName) (Date: $($_.DateString))" -ForegroundColor Yellow 
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
        $fileDates = $latestFiles | Select-Object -First $destPaths.Count | ForEach-Object { $_.DateString }
        $emailSubject = "Pi Log Files - Latest 2 Files ($($fileDates -join ', '))"
        $emailBody = "Latest 2 printer log files from Raspberry Pi.`n`nFiles: $($fileNames -join ', ')`nDates: $($fileDates -join ', ')`nTimestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`nTotal files found: $($csvAclUrls.Count)"
        
        Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $credential -From $fromEmail -To $toEmail -Subject $emailSubject -Body $emailBody -Attachments $destPaths
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
