# Universal File Downloader for HTTP Directories
# Supports various web server directory listings and file patterns

param(
    [Parameter(Mandatory=$true)]
    [string]$Url,
    [string]$DownloadFolder = ".\downloaded_files",
    [string[]]$FileExtensions = @("csv", "acl", "log", "txt", "pdf", "doc", "docx", "xls", "xlsx", "zip", "rar", "xml", "json", "conf", "cfg", "ini", "bak", "dat", "db", "sql", "dmp", "dump"),
    [switch]$ListOnly,
    [switch]$Recursive,
    [switch]$Verbose
)

function Write-Status {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Get-FileSize {
    param([long]$Bytes)
    if ($Bytes -lt 1KB) { return "$Bytes B" }
    elseif ($Bytes -lt 1MB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    elseif ($Bytes -lt 1GB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    else { return "{0:N2} GB" -f ($Bytes / 1GB) }
}

function Get-AbsoluteUrl {
    param([string]$BaseUrl, [string]$RelativeUrl)
    if ($RelativeUrl.StartsWith("http")) { return $RelativeUrl }
    if ($RelativeUrl.StartsWith("/")) { return $BaseUrl + $RelativeUrl }
    return $BaseUrl.TrimEnd('/') + "/" + $RelativeUrl.TrimStart('/')
}

function Find-FilesInHtml {
    param([string]$Html, [string]$BaseUrl, [string[]]$Extensions)
    
    $allFiles = @()
    
    # Pattern 1: Standard href links
    $hrefPattern = 'href="([^"]*\.(' + ($Extensions -join '|') + '))"'
    $hrefMatches = [regex]::Matches($Html, $hrefPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    foreach ($match in $hrefMatches) {
        $fileUrl = $match.Groups[1].Value
        $absoluteUrl = Get-AbsoluteUrl $BaseUrl $fileUrl
        if (!$allFiles.Contains($absoluteUrl)) { $allFiles += $absoluteUrl }
    }
    
    # Pattern 2: src attributes
    $srcPattern = 'src="([^"]*\.(' + ($Extensions -join '|') + '))"'
    $srcMatches = [regex]::Matches($Html, $srcPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    foreach ($match in $srcMatches) {
        $fileUrl = $match.Groups[1].Value
        $absoluteUrl = Get-AbsoluteUrl $BaseUrl $fileUrl
        if (!$allFiles.Contains($absoluteUrl)) { $allFiles += $absoluteUrl }
    }
    
    # Pattern 3: Action attributes
    $actionPattern = 'action="([^"]*\.(' + ($Extensions -join '|') + '))"'
    $actionMatches = [regex]::Matches($Html, $actionPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    foreach ($match in $actionMatches) {
        $fileUrl = $match.Groups[1].Value
        $absoluteUrl = Get-AbsoluteUrl $BaseUrl $fileUrl
        if (!$allFiles.Contains($absoluteUrl)) { $allFiles += $absoluteUrl }
    }
    
    # Pattern 4: Direct file links without extensions (common in some systems)
    $directPattern = 'href="([^"]*[^/])"'
    $directMatches = [regex]::Matches($Html, $directPattern)
    foreach ($match in $directMatches) {
        $fileUrl = $match.Groups[1].Value
        if ($fileUrl -and !$fileUrl.Contains('.') -and !$fileUrl.Contains('?') -and !$fileUrl.Contains('#')) {
            $absoluteUrl = Get-AbsoluteUrl $BaseUrl $fileUrl
            if (!$allFiles.Contains($absoluteUrl)) { $allFiles += $absoluteUrl }
        }
    }
    
    return $allFiles
}

# Main execution
try {
    Write-Status "=== Universal File Downloader ===" "Cyan"
    Write-Status "Target URL: $Url" "Yellow"
    Write-Status "Download Folder: $DownloadFolder" "Yellow"
    Write-Status "File Extensions: $($FileExtensions -join ', ')" "Yellow"
    Write-Status "List Only: $ListOnly" "Yellow"
    Write-Status ""

    # Create download directory
    if (!(Test-Path $DownloadFolder)) {
        New-Item -ItemType Directory -Path $DownloadFolder -Force | Out-Null
        Write-Status "Created directory: $DownloadFolder" "Green"
    }

    # Fetch HTML content
    Write-Status "Fetching content from: $Url" "White"
    $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 30
    $html = $response.Content
    Write-Status "Successfully fetched content (Length: $($html.Length) characters)" "Green"

    # Find files
    Write-Status "Searching for files..." "White"
    $fileUrls = Find-FilesInHtml $html $Url $FileExtensions
    
    Write-Status "Found $($fileUrls.Count) files" "Cyan"
    Write-Status ""

    if ($fileUrls.Count -eq 0) {
        Write-Status "No files found matching the specified extensions." "Yellow"
        Write-Status "Available extensions in HTML:" "Yellow"
        $allExts = [regex]::Matches($html, '\.([a-zA-Z0-9]+)', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        $uniqueExts = $allExts | ForEach-Object { $_.Groups[1].Value.ToLower() } | Sort-Object -Unique
        Write-Status ($uniqueExts -join ', ') "Gray"
        
        if ($Verbose) {
            Write-Status "`nRaw HTML preview (first 1000 characters):" "Yellow"
            Write-Status $html.Substring(0, [Math]::Min(1000, $html.Length)) "Gray"
        }
        exit 0
    }

    # Display found files
    Write-Status "=== Found Files ===" "Cyan"
    for ($i = 0; $i -lt $fileUrls.Count; $i++) {
        $fileName = Split-Path $fileUrls[$i] -Leaf
        Write-Status "$($i + 1). $fileName" "White"
        if ($Verbose) {
            Write-Status "   URL: $($fileUrls[$i])" "Gray"
        }
    }
    Write-Status ""

    if ($ListOnly) {
        Write-Status "List-only mode enabled. No files will be downloaded." "Yellow"
        exit 0
    }

    # Download files
    Write-Status "=== Downloading Files ===" "Cyan"
    $successCount = 0
    $failCount = 0

    foreach ($url in $fileUrls) {
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

            Write-Status "Downloading: $fileName" "White"
            if ($Verbose) {
                Write-Status "  From: $url" "Gray"
                Write-Status "  To: $filePath" "Gray"
            }

            # Download the file
            Invoke-WebRequest -Uri $url -OutFile $filePath -UseBasicParsing -TimeoutSec 30

            # Get file info
            $fileInfo = Get-Item $filePath
            $fileSize = Get-FileSize $fileInfo.Length
            Write-Status "  ✓ Downloaded successfully ($fileSize)" "Green"
            $successCount++
        }
        catch {
            Write-Status "  ✗ Failed to download: $($_.Exception.Message)" "Red"
            $failCount++
        }
    }

    Write-Status ""
    Write-Status "=== Download Summary ===" "Cyan"
    Write-Status "Successfully downloaded: $successCount files" "Green"
    Write-Status "Failed downloads: $failCount files" "Red"
    Write-Status "Download location: $DownloadFolder" "Yellow"

    if ($successCount -gt 0) {
        Write-Status ""
        Write-Status "Downloaded files:" "White"
        Get-ChildItem $DownloadFolder | ForEach-Object {
            $fileSize = Get-FileSize $_.Length
            Write-Status "  $($_.Name) ($fileSize)" "Gray"
        }
    }

} catch {
    Write-Status "Script error: $($_.Exception.Message)" "Red"
    if ($Verbose) {
        Write-Status "Stack trace: $($_.ScriptStackTrace)" "Red"
    }
    exit 1
}

Write-Status ""
Write-Status "Script completed successfully." "Cyan"
