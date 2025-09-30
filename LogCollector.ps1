# Configure these variables
$baseUrl = "http://172.30.0.35"
$pagePath = "/accounting"
$outputFile = "download_links.txt"

# Email configuration
$smtpServer = "smtp.zoho.com.cn"
$smtpPort = 587
$fromEmail = "kenyluk@zohomail.cn"
$toEmail = "keny_luk@chk.canon.com.hk"

# Secure password handling - Choose one of the methods below:

# Method 1: Prompt for password (most secure, but requires interaction)
# $credential = Get-Credential -UserName $fromEmail -Message "Enter email password"

# Method 2: Read from encrypted file (secure and automated)
$credentialPath = ".\email_credential.xml"
if (Test-Path $credentialPath) {
    Write-Host "Loading encrypted credentials..."
    $credential = Import-Clixml -Path $credentialPath
} else {
    Write-Host "First time setup - Please enter your email credentials:"
    $credential = Get-Credential -UserName $fromEmail -Message "Enter email password (will be encrypted and saved)"
    $credential | Export-Clixml -Path $credentialPath
    Write-Host "Credentials encrypted and saved to: $credentialPath"
}

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
$csvAclUrls = $fullUrls | Where-Object { $_ -match '\.(csv|acl)$' }

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

# Get the latest two files
$latestFiles = $fileInfo | Select-Object -First 2
if ($latestFiles.Count -eq 2) {
    $latestFile1 = $latestFiles[0]
    $latestFile2 = $latestFiles[1]
    $latestUrls = @($latestFile1.URL, $latestFile2.URL)
    $latestFileNames = @($latestFile1.FileName, $latestFile2.FileName)
    $dateStrs = @($latestFile1.DateString, $latestFile2.DateString)
    Write-Host "`nLatest files identified: $($latestFileNames -join ', ')"
    Write-Host "Dates from filenames: $($dateStrs -join ', ')"
    Write-Host "URLs: $($latestUrls -join ', ')"
} elseif ($latestFiles.Count -eq 1) {
    $latestFile1 = $latestFiles[0]
    $latestUrls = @($latestFile1.URL)
    $latestFileNames = @($latestFile1.FileName)
    $dateStrs = @($latestFile1.DateString)
    Write-Host "`nOnly one file found: $($latestFileNames[0])"
} else {
    Write-Host "No valid files found with date pattern!"
    exit
}

# Download the latest files
$downloadFolder = "downloaded_csvs"
if (-not (Test-Path $downloadFolder)) {
    New-Item -ItemType Directory -Path $downloadFolder | Out-Null
}

$destPaths = @()
foreach ($i in 0..($latestFileNames.Count-1)) {
    $fileName = $latestFileNames[$i]
    $url = $latestUrls[$i]
    $destPath = Join-Path $downloadFolder $fileName
    try {
        Write-Host "`nDownloading: $fileName ..."
        Invoke-WebRequest -Uri $url -OutFile $destPath
        Write-Host "Successfully downloaded: $fileName"
        Write-Host "File saved to: $destPath"
        $destPaths += $destPath
    } catch {
        Write-Host "Failed to download: $fileName"
        Write-Host "Error: $($_.Exception.Message)"
    }
}

# Send email with the downloaded files as attachments
Write-Host "`nSending email with attachments..."
try {
    $emailSubject = "Latest Log Files - $($latestFileNames -join ', ') (Dates: $($dateStrs -join ', '))"
    $emailBody = "Please find the latest log files attached.`n`nFiles: $($latestFileNames -join ', ')`nDates: $($dateStrs -join ', ')`nDownloaded from: $($latestUrls -join ', ')`n`nThis email was sent automatically by LogCollector script."
    Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $credential -From $fromEmail -To $toEmail -Subject $emailSubject -Body $emailBody -Attachments $destPaths
    Write-Host "Email sent successfully!"
    Write-Host "Subject: $emailSubject"
    Write-Host "Attachments: $($destPaths -join ', ')"
} catch {
    Write-Host "Failed to send email: $($_.Exception.Message)"
}