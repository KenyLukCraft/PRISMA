# PowerShell Script to List and Download All Files from HTTP URL
# Target URL: http://192.168.1.149/accounting
# Author: Generated for OnelinePowerShell project

param(
    [string]$BaseUrl = "http://192.168.1.149",
    [string]$PagePath = "/accounting",
    [string]$DownloadFolder = ".\downloaded_files",
    [switch]$ListOnly = $false,
    [switch]$Verbose = $false
)

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Function to create directory if it doesn't exist
function Ensure-Directory {
    param([string]$Path)
    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-ColorOutput "Created directory: $Path" "Green"
    }
}

# Function to get file size in human readable format
function Get-FileSize {
    param([long]$Bytes)
    if ($Bytes -lt 1KB) { return "$Bytes B" }
    elseif ($Bytes -lt 1MB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    elseif ($Bytes -lt 1GB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    else { return "{0:N2} GB" -f ($Bytes / 1GB) }
}

# Main script execution
try {
    Write-ColorOutput "=== File Downloader Script ===" "Cyan"
    Write-ColorOutput "Target URL: $BaseUrl$PagePath" "Yellow"
    Write-ColorOutput "Download Folder: $DownloadFolder" "Yellow"
    Write-ColorOutput "List Only Mode: $ListOnly" "Yellow"
    Write-ColorOutput ""

    # Create download directory
    Ensure-Directory $DownloadFolder

    # Construct full URL
    $fullUrl = $BaseUrl + $PagePath
    Write-ColorOutput "Fetching content from: $fullUrl" "White"

    # Fetch the HTML content
    try {
        $response = Invoke-WebRequest -Uri $fullUrl -UseBasicParsing -TimeoutSec 30
        $html = $response.Content
        Write-ColorOutput "Successfully fetched content (Length: $($html.Length) characters)" "Green"
    }
    catch {
        Write-ColorOutput "Error fetching content: $($_.Exception.Message)" "Red"
        Write-ColorOutput "Please check if the URL is accessible and the device is online." "Red"
        exit 1
    }

    # Parse HTML to find file links
    Write-ColorOutput "Parsing HTML for file links..." "White"
    
    # Common patterns for file links in web pages
    $filePatterns = @(
        'href="([^"]*\.(csv|acl|log|txt|pdf|doc|docx|xls|xlsx|zip|rar|7z|tar|gz|xml|json|conf|cfg|ini|bak|old|dat|db|sql|dmp|dump))"',
        'href="([^"]*\.(csv|acl|log|txt|pdf|doc|docx|xls|xlsx|zip|rar|7z|tar|gz|xml|json|conf|cfg|ini|bak|old|dat|db|sql|dmp|dump))"',
        'src="([^"]*\.(csv|acl|log|txt|pdf|doc|docx|xls|xlsx|zip|rar|7z|tar|gz|xml|json|conf|cfg|ini|bak|old|dat|db|sql|dmp|dump))"',
        'action="([^"]*\.(csv|acl|log|txt|pdf|doc|docx|xls|xlsx|zip|rar|7z|tar|gz|xml|json|conf|cfg|ini|bak|old|dat|db|sql|dmp|dump))"'
    )

    $fileUrls = @()
    foreach ($pattern in $filePatterns) {
        $matches = [regex]::Matches($html, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        foreach ($match in $matches) {
            $fileUrl = $match.Groups[1].Value
            if ($fileUrl -and !$fileUrls.Contains($fileUrl)) {
                $fileUrls += $fileUrl
            }
        }
    }

    # Also look for direct file links without extensions (common in some web interfaces)
    $directFilePattern = 'href="([^"]*[^/])"'
    $directMatches = [regex]::Matches($html, $directFilePattern)
    foreach ($match in $directMatches) {
        $fileUrl = $match.Groups[1].Value
        if ($fileUrl -and !$fileUrl.Contains('.') -and !$fileUrls.Contains($fileUrl)) {
            # This might be a file without extension, add it
            $fileUrls += $fileUrl
        }
    }

    # Convert relative URLs to absolute URLs
    $fullUrls = @()
    foreach ($url in $fileUrls) {
        if ($url.StartsWith("http://") -or $url.StartsWith("https://")) {
            $fullUrls += $url
        }
        elseif ($url.StartsWith("/")) {
            $fullUrls += $BaseUrl + $url
        }
        else {
            $fullUrls += $BaseUrl + "/" + $url
        }
    }

    Write-ColorOutput "Found $($fullUrls.Count) potential file links" "Green"
    Write-ColorOutput ""

    if ($fullUrls.Count -eq 0) {
        Write-ColorOutput "No file links found in the HTML content." "Yellow"
        Write-ColorOutput "This might be because:" "Yellow"
        Write-ColorOutput "1. The page doesn't contain direct file links" "Yellow"
        Write-ColorOutput "2. Files are loaded via JavaScript (not visible in static HTML)" "Yellow"
        Write-ColorOutput "3. The page structure is different than expected" "Yellow"
        Write-ColorOutput ""
        Write-ColorOutput "Raw HTML preview (first 1000 characters):" "Yellow"
        Write-ColorOutput $html.Substring(0, [Math]::Min(1000, $html.Length)) "Gray"
        exit 0
    }

    # Display found files
    Write-ColorOutput "=== Found Files ===" "Cyan"
    for ($i = 0; $i -lt $fullUrls.Count; $i++) {
        $fileName = Split-Path $fullUrls[$i] -Leaf
        Write-ColorOutput "$($i + 1). $fileName" "White"
        Write-ColorOutput "   URL: $($fullUrls[$i])" "Gray"
    }
    Write-ColorOutput ""

    if ($ListOnly) {
        Write-ColorOutput "List-only mode enabled. No files will be downloaded." "Yellow"
        exit 0
    }

    # Download files
    Write-ColorOutput "=== Downloading Files ===" "Cyan"
    $successCount = 0
    $failCount = 0

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

            Write-ColorOutput "Downloading: $fileName" "White"
            if ($Verbose) {
                Write-ColorOutput "  From: $url" "Gray"
                Write-ColorOutput "  To: $filePath" "Gray"
            }

            # Download the file
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($url, $filePath)
            $webClient.Dispose()

            # Get file info
            $fileInfo = Get-Item $filePath
            $fileSize = Get-FileSize $fileInfo.Length
            Write-ColorOutput "  ✓ Downloaded successfully ($fileSize)" "Green"
            $successCount++
        }
        catch {
            Write-ColorOutput "  ✗ Failed to download: $($_.Exception.Message)" "Red"
            $failCount++
        }
    }

    Write-ColorOutput ""
    Write-ColorOutput "=== Download Summary ===" "Cyan"
    Write-ColorOutput "Successfully downloaded: $successCount files" "Green"
    Write-ColorOutput "Failed downloads: $failCount files" "Red"
    Write-ColorOutput "Download location: $DownloadFolder" "Yellow"

    if ($successCount -gt 0) {
        Write-ColorOutput ""
        Write-ColorOutput "Downloaded files:" "White"
        Get-ChildItem $DownloadFolder | ForEach-Object {
            $fileSize = Get-FileSize $_.Length
            Write-ColorOutput "  $($_.Name) ($fileSize)" "Gray"
        }
    }

}
catch {
    Write-ColorOutput "Script error: $($_.Exception.Message)" "Red"
    Write-ColorOutput "Stack trace: $($_.ScriptStackTrace)" "Red"
    exit 1
}

Write-ColorOutput ""
Write-ColorOutput "Script completed." "Cyan"
