# Readable test script for CSV and ACL files
# This version is easier to debug and understand

$url = "http://192.168.1.149/accounting"
$dir = ".\csv_acl_files"

Write-Host "=== Testing CSV/ACL File Downloader ===" -ForegroundColor Cyan
Write-Host "Target URL: $url" -ForegroundColor Yellow
Write-Host "Download Directory: $dir" -ForegroundColor Yellow
Write-Host ""

try {
    # Test connection
    Write-Host "Testing connection to $url..." -ForegroundColor White
    $html = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
    Write-Host "✓ Connection successful (Content length: $($html.Content.Length) characters)" -ForegroundColor Green
    Write-Host ""

    # Search for CSV and ACL files
    Write-Host "Searching for CSV and ACL files..." -ForegroundColor White
    $pattern = 'href="([^"]*\.(csv|acl))"'
    $files = [regex]::Matches($html.Content, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    
    $fileUrls = $files | ForEach-Object { $_.Groups[1].Value } | Where-Object { $_ } | Sort-Object -Unique
    
    Write-Host "Found $($fileUrls.Count) CSV/ACL files" -ForegroundColor Cyan
    Write-Host ""

    if ($fileUrls.Count -eq 0) {
        Write-Host "No CSV or ACL files found!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Let's check what file types are available:" -ForegroundColor Yellow
        
        # Look for any file links
        $anyFilePattern = 'href="([^"]*\.([a-zA-Z0-9]+))"'
        $anyFiles = [regex]::Matches($html.Content, $anyFilePattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        $extensions = $anyFiles | ForEach-Object { $_.Groups[2].Value.ToLower() } | Sort-Object -Unique
        Write-Host "Available file extensions: $($extensions -join ', ')" -ForegroundColor Gray
        
        Write-Host ""
        Write-Host "Raw HTML preview (first 1000 characters):" -ForegroundColor Yellow
        Write-Host $html.Content.Substring(0, [Math]::Min(1000, $html.Content.Length)) -ForegroundColor Gray
    } else {
        Write-Host "=== Files Found ===" -ForegroundColor Cyan
        for ($i = 0; $i -lt $fileUrls.Count; $i++) {
            $fileUrl = $fileUrls[$i]
            if (!$fileUrl.StartsWith("http")) {
                $fileUrl = "http://192.168.1.149/" + $fileUrl.TrimStart('/')
            }
            $fileName = Split-Path $fileUrl -Leaf
            Write-Host "$($i + 1). $fileName" -ForegroundColor White
            Write-Host "   URL: $fileUrl" -ForegroundColor Gray
        }
        
        Write-Host ""
        Write-Host "=== Test Download (Dry Run) ===" -ForegroundColor Cyan
        
        # Create directory for test
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Host "Created directory: $dir" -ForegroundColor Green
        }
        
        $successCount = 0
        $failCount = 0
        
        foreach ($fileUrl in $fileUrls) {
            if (!$fileUrl.StartsWith("http")) {
                $fileUrl = "http://192.168.1.149/" + $fileUrl.TrimStart('/')
            }
            $fileName = Split-Path $fileUrl -Leaf
            $filePath = Join-Path $dir $fileName
            
            # Handle duplicates
            $counter = 1
            $originalPath = $filePath
            while (Test-Path $filePath) {
                $nameWithoutExt = [System.IO.Path]::GetFileNameWithoutExtension($originalPath)
                $extension = [System.IO.Path]::GetExtension($originalPath)
                $filePath = Join-Path $dir "$nameWithoutExt($counter)$extension"
                $counter++
            }
            
            try {
                Write-Host "Testing download: $fileName" -ForegroundColor White
                Write-Host "  From: $fileUrl" -ForegroundColor Gray
                Write-Host "  To: $filePath" -ForegroundColor Gray
                
                # Test the download
                Invoke-WebRequest -Uri $fileUrl -OutFile $filePath -UseBasicParsing -TimeoutSec 10
                
                # Get file info
                $fileInfo = Get-Item $filePath
                $fileSize = if ($fileInfo.Length -lt 1KB) { "$($fileInfo.Length) B" } 
                           elseif ($fileInfo.Length -lt 1MB) { "{0:N2} KB" -f ($fileInfo.Length / 1KB) }
                           else { "{0:N2} MB" -f ($fileInfo.Length / 1MB) }
                
                Write-Host "  ✓ Download successful ($fileSize)" -ForegroundColor Green
                $successCount++
            }
            catch {
                Write-Host "  ✗ Download failed: $($_.Exception.Message)" -ForegroundColor Red
                $failCount++
            }
        }
        
        Write-Host ""
        Write-Host "=== Test Results ===" -ForegroundColor Cyan
        Write-Host "Successful downloads: $successCount" -ForegroundColor Green
        Write-Host "Failed downloads: $failCount" -ForegroundColor Red
        Write-Host "Files saved to: $dir" -ForegroundColor Yellow
        
        if ($successCount -gt 0) {
            Write-Host ""
            Write-Host "Downloaded files:" -ForegroundColor White
            Get-ChildItem $dir | ForEach-Object {
                $size = if ($_.Length -lt 1KB) { "$($_.Length) B" } 
                       elseif ($_.Length -lt 1MB) { "{0:N2} KB" -f ($_.Length / 1KB) }
                       else { "{0:N2} MB" -f ($_.Length / 1MB) }
                Write-Host "  $($_.Name) ($size)" -ForegroundColor Gray
            }
        }
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check if the URL is accessible: $url" -ForegroundColor Yellow
    Write-Host "Make sure the device is online and the URL is correct." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Test completed." -ForegroundColor Cyan
