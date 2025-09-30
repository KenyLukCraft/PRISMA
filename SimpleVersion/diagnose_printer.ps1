# diagnose_printer.ps1 - Diagnostic script for printer connectivity and file detection
# Run this script to troubleshoot why no CSV/ACL files are found

param(
    [string]$PrinterIP = "172.30.0.38",
    [string]$PagePath = "/accounting"
)

Write-Host "=== PRINTER DIAGNOSTIC SCRIPT ===" -ForegroundColor Cyan
Write-Host "Printer IP: $PrinterIP" -ForegroundColor Yellow
Write-Host "Page Path: $PagePath" -ForegroundColor Yellow
Write-Host ""

# Test 1: Basic connectivity
Write-Host "1. Testing basic connectivity..." -ForegroundColor Green
try {
    $ping = Test-NetConnection -ComputerName $PrinterIP -Port 80 -InformationLevel Quiet
    if ($ping) {
        Write-Host "✓ Printer is reachable on port 80" -ForegroundColor Green
    } else {
        Write-Host "✗ Cannot reach printer on port 80" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Network error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Web interface accessibility
Write-Host "`n2. Testing web interface accessibility..." -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri "http://$PrinterIP$PagePath" -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ Web interface accessible (Status: $($response.StatusCode))" -ForegroundColor Green
    Write-Host "Content length: $($response.Content.Length) characters" -ForegroundColor Gray
} catch {
    Write-Host "✗ Cannot access web interface: $($_.Exception.Message)" -ForegroundColor Red
    
    # Try alternative paths
    Write-Host "`nTrying alternative paths..." -ForegroundColor Yellow
    $alternativePaths = @("/", "/logs", "/status", "/maintenance", "/hp/device/this/status")
    foreach ($path in $alternativePaths) {
        try {
            $altResponse = Invoke-WebRequest -Uri "http://$PrinterIP$path" -UseBasicParsing -TimeoutSec 5
            Write-Host "✓ Found accessible path: $path (Status: $($altResponse.StatusCode))" -ForegroundColor Green
            $PagePath = $path
            break
        } catch {
            Write-Host "✗ Path $path not accessible" -ForegroundColor Gray
        }
    }
}

# Test 3: Analyze HTML content
Write-Host "`n3. Analyzing HTML content..." -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri "http://$PrinterIP$PagePath" -UseBasicParsing -TimeoutSec 10
    $html = $response.Content
    
    Write-Host "HTML content preview (first 500 characters):" -ForegroundColor Gray
    Write-Host $html.Substring(0, [Math]::Min(500, $html.Length)) -ForegroundColor Gray
    
    # Look for all href links
    Write-Host "`nAll href links found:" -ForegroundColor Yellow
    $hrefMatches = [regex]::Matches($html, 'href="([^"]+)"', 'IgnoreCase')
    if ($hrefMatches.Count -gt 0) {
        $hrefMatches | ForEach-Object { Write-Host "  $($_.Groups[1].Value)" -ForegroundColor White }
    } else {
        Write-Host "  No href links found" -ForegroundColor Red
    }
    
    # Look for file links specifically
    Write-Host "`nFile links found:" -ForegroundColor Yellow
    $fileMatches = [regex]::Matches($html, 'href="([^"]*\.(csv|acl|log|txt|pdf))"', 'IgnoreCase')
    if ($fileMatches.Count -gt 0) {
        $fileMatches | ForEach-Object { Write-Host "  $($_.Groups[1].Value)" -ForegroundColor White }
    } else {
        Write-Host "  No file links found" -ForegroundColor Red
    }
    
    # Look for any downloadable content
    Write-Host "`nAny downloadable content:" -ForegroundColor Yellow
    $downloadMatches = [regex]::Matches($html, 'href="([^"]*\.(csv|acl|log|txt|pdf|zip|rar|7z))"', 'IgnoreCase')
    if ($downloadMatches.Count -gt 0) {
        $downloadMatches | ForEach-Object { Write-Host "  $($_.Groups[1].Value)" -ForegroundColor White }
    } else {
        Write-Host "  No downloadable files found" -ForegroundColor Red
    }
    
} catch {
    Write-Host "✗ Error analyzing HTML: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Check for authentication requirements
Write-Host "`n4. Checking for authentication requirements..." -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri "http://$PrinterIP$PagePath" -UseBasicParsing -TimeoutSec 10
    if ($response.Content -match "login|password|auth|401|403") {
        Write-Host "⚠ Possible authentication required" -ForegroundColor Yellow
        Write-Host "The printer may require login credentials" -ForegroundColor Yellow
    } else {
        Write-Host "✓ No obvious authentication requirements" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Error checking authentication: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Try different file extensions
Write-Host "`n5. Checking for different file extensions..." -ForegroundColor Green
$extensions = @("csv", "acl", "log", "txt", "pdf", "zip", "rar", "7z", "xlsx", "doc", "docx")
foreach ($ext in $extensions) {
    $pattern = "href=`"([^`"]*\.$ext)`""
    $matches = [regex]::Matches($html, $pattern, 'IgnoreCase')
    if ($matches.Count -gt 0) {
        Write-Host "✓ Found $($matches.Count) .$ext files" -ForegroundColor Green
        $matches | ForEach-Object { Write-Host "  $($_.Groups[1].Value)" -ForegroundColor White }
    }
}

# Summary and recommendations
Write-Host "`n=== DIAGNOSTIC SUMMARY ===" -ForegroundColor Cyan
Write-Host "1. Check if the printer IP address is correct" -ForegroundColor Yellow
Write-Host "2. Verify the page path (try /, /logs, /status, /maintenance)" -ForegroundColor Yellow
Write-Host "3. Check if the printer requires authentication" -ForegroundColor Yellow
Write-Host "4. Verify the printer has log files available" -ForegroundColor Yellow
Write-Host "5. Check if the printer uses different file extensions" -ForegroundColor Yellow
Write-Host ""
Write-Host "If files are found with different extensions, update the script:" -ForegroundColor Green
Write-Host "`$csvAclUrls = `$fullUrls | Where-Object { `$_ -match '\.(csv|acl|log|txt|pdf)$' }" -ForegroundColor Gray
