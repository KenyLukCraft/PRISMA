# Configure these variables
$baseUrl = "http://172.30.0.38"
$pagePath = "/accounting"
$outputFile = "download_links.txt"

# Email configuration
$smtpServer = "smtp.zoho.com.cn"
$smtpPort = 587
$fromEmail = "kenyluk@zohomail.cn"
$toEmail = "keny_luk@chk.canon.com.hk"
$emailPassword = "demmi0-pugDyz-ciksyp"

# Fetch the webpage
$response = Invoke-WebRequest -Uri ("$baseUrl$pagePath") -UseBasicParsing
$html = $response.Content

# Convert to string if needed
if ($html -is [byte[]]) {
    $html = [System.Text.Encoding]::UTF8.GetString($html)
}

# Extract all href values from <a> tags (case-insensitive, robust)
$matches = [regex]::Matches($html, '<a[^>]+href="([^"]+)"', 'IgnoreCase')
$links = foreach ($m in $matches) { $m.Groups[1].Value }

# Build full URLs
$fullUrls = $links | ForEach-Object {
    if ($_ -match '^https?://') { $_ }
    elseif ($_ -like '/*') { "$baseUrl$_" }
    else { "$baseUrl/$_" }
}

# Filter for CSV and ACL files only
$csvAclUrls = $fullUrls | Where-Object { $_ -match '\.(CSV|ACL)$' }

# Save all links for reference
$fullUrls | Out-File -FilePath $outputFile
Write-Host "Extracted $($fullUrls.Count) total links, $($csvAclUrls.Count) CSV/ACL files:"
$csvAclUrls
Write-Host "`nSaved all links to: $outputFile"

# Find the latest file by extracting YYYYMMDD from last 8 digits of filename
if ($csvAclUrls.Count -eq 0) {
    Write-Host "No CSV or ACL files found!"
    exit
}

# Debug: Show all files with their extracted dates
Write-Host "`nDebug - All CSV/ACL files with extracted dates:"
$fileInfo = $csvAclUrls | ForEach-Object {
    $fileName = Split-Path $_ -Leaf
    $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    if ($nameWithoutExt.Length -ge 8) {
        $dateStr = $nameWithoutExt.Substring($nameWithoutExt.Length - 8)
        try {
            $dateObj = [DateTime]::ParseExact($dateStr, "yyyyMMdd", $null)
            [PSCustomObject]@{
                URL = $_
                FileName = $fileName
                DateString = $dateStr
                DateObject = $dateObj
            }
        } catch {
            [PSCustomObject]@{
                URL = $_
                FileName = $fileName
                DateString = $dateStr
                DateObject = $null
            }
        }
    }
} | Sort-Object DateObject -Descending

$fileInfo | ForEach-Object { 
    Write-Host "  $($_.FileName) -> Date: $($_.DateString) -> Parsed: $($_.DateObject)"
}

# Get the latest file
$latestFile = $fileInfo | Select-Object -First 1
if ($latestFile) {
    $latestUrl = $latestFile.URL
    $latestFileName = $latestFile.FileName
    $dateStr = $latestFile.DateString
    
    Write-Host "`nLatest file identified: $latestFileName"
    Write-Host "Date from filename: $dateStr"
    Write-Host "URL: $latestUrl"
} else {
    Write-Host "No valid files found with date pattern!"
    exit
}

# Download only the latest file
$downloadFolder = "downloaded_csvs"
if (-not (Test-Path $downloadFolder)) {
    New-Item -ItemType Directory -Path $downloadFolder | Out-Null
}

$destPath = Join-Path $downloadFolder $latestFileName
try {
    Write-Host "`nDownloading latest file..."
    Invoke-WebRequest -Uri $latestUrl -OutFile $destPath
    Write-Host "Successfully downloaded: $latestFileName"
    Write-Host "File saved to: $destPath"
    
    # Send email with the downloaded file as attachment
    Write-Host "`nSending email with attachment..."
    try {
        $emailSubject = "Latest Log File - $latestFileName (Date: $dateStr)"
        $emailBody = "Please find the latest log file attached.`n`nFile: $latestFileName`nDate: $dateStr`nDownloaded from: $latestUrl`n`nThis email was sent automatically by LogCollector script."
        
        Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential (New-Object System.Management.Automation.PSCredential($fromEmail, (ConvertTo-SecureString $emailPassword -AsPlainText -Force))) -From $fromEmail -To $toEmail -Subject $emailSubject -Body $emailBody -Attachments $destPath
        
        Write-Host "Email sent successfully!"
        Write-Host "Subject: $emailSubject"
        Write-Host "Attachment: $destPath"
    } catch {
        Write-Host "Failed to send email: $($_.Exception.Message)"
    }
} catch {
    Write-Host "Failed to download: $latestFileName"
    Write-Host "Error: $($_.Exception.Message)"
}