# Simple PowerShell Script to Download All Files from Accounting Page
# Target: http://192.168.1.149/accounting

param(
    [string]$BaseUrl = "http://192.168.1.149",
    [string]$PagePath = "/accounting",
    [string]$DownloadFolder = ".\accounting_files"
)

# Create download directory
if (!(Test-Path $DownloadFolder)) {
    New-Item -ItemType Directory -Path $DownloadFolder -Force | Out-Null
    Write-Host "Created directory: $DownloadFolder" -ForegroundColor Green
}

# Construct full URL
$fullUrl = $BaseUrl + $PagePath
Write-Host "Fetching files from: $fullUrl" -ForegroundColor Yellow

try {
    # Fetch the HTML content
    $response = Invoke-WebRequest -Uri $fullUrl -UseBasicParsing -TimeoutSec 30
    $html = $response.Content
    Write-Host "Successfully connected to the server" -ForegroundColor Green

    # Find all file links (common file extensions)
    $fileExtensions = @("csv", "acl", "log", "txt", "pdf", "doc", "docx", "xls", "xlsx", "zip", "rar", "xml", "json", "conf", "cfg", "ini", "bak", "dat", "db", "sql")
    $filePattern = 'href="([^"]*\.(' + ($fileExtensions -join '|') + '))"'
    
    $matches = [regex]::Matches($html, $filePattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $fileUrls = @()
    
    foreach ($match in $matches) {
        $fileUrl = $match.Groups[1].Value
        if ($fileUrl -and !$fileUrls.Contains($fileUrl)) {
            $fileUrls += $fileUrl
        }
    }

    # Convert relative URLs to absolute URLs
    $fullUrls = @()
    foreach ($url in $fileUrls) {
        if ($url.StartsWith("http")) {
            $fullUrls += $url
        } else {
            $fullUrls += $BaseUrl + "/" + $url.TrimStart('/')
        }
    }

    Write-Host "Found $($fullUrls.Count) files to download" -ForegroundColor Cyan

    if ($fullUrls.Count -eq 0) {
        Write-Host "No files found. The page might not contain direct file links." -ForegroundColor Yellow
        Write-Host "Raw HTML preview:" -ForegroundColor Yellow
        Write-Host $html.Substring(0, [Math]::Min(500, $html.Length)) -ForegroundColor Gray
        exit
    }

    # Display found files
    Write-Host "`nFiles found:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $fullUrls.Count; $i++) {
        $fileName = Split-Path $fullUrls[$i] -Leaf
        Write-Host "  $($i + 1). $fileName" -ForegroundColor White
    }

    # Download files
    Write-Host "`nDownloading files..." -ForegroundColor Cyan
    $successCount = 0

    foreach ($url in $fullUrls) {
        try {
            $fileName = Split-Path $url -Leaf
            $filePath = Join-Path $DownloadFolder $fileName
            
            # Handle duplicate filenames
            $counter = 1
            $originalPath = $filePath
            while (Test-Path $filePath) {
                $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($originalPath)
                $extension = [System.IO.Path]::GetExtension($originalPath)
                $filePath = Join-Path $DownloadFolder "$nameWithoutExt($counter)$extension"
                $counter++
            }

            Write-Host "Downloading: $fileName" -ForegroundColor White
            Invoke-WebRequest -Uri $url -OutFile $filePath -UseBasicParsing
            Write-Host "  ✓ Success" -ForegroundColor Green
            $successCount++
        }
        catch {
            Write-Host "  ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "`nDownload completed!" -ForegroundColor Green
    Write-Host "Successfully downloaded: $successCount files" -ForegroundColor Green
    Write-Host "Files saved to: $DownloadFolder" -ForegroundColor Yellow

    # List downloaded files
    if ($successCount -gt 0) {
        Write-Host "`nDownloaded files:" -ForegroundColor Cyan
        Get-ChildItem $DownloadFolder | ForEach-Object {
            $size = if ($_.Length -lt 1KB) { "$($_.Length) B" } 
                   elseif ($_.Length -lt 1MB) { "{0:N2} KB" -f ($_.Length / 1KB) }
                   else { "{0:N2} MB" -f ($_.Length / 1MB) }
            Write-Host "  $($_.Name) ($size)" -ForegroundColor Gray
        }
    }

} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check if the URL is accessible: $fullUrl" -ForegroundColor Yellow
}
