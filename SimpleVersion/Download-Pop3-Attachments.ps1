# --- CONFIGURATION ---
$curlPath   = "C:\Users\Keny\PycharmProjects\OnelinePowerShell\SimpleVersion\curl-8.15.0_2-win64-mingw\bin\curl.exe"
$imapServer = "outlook.office365.com:993"
$imapUser   = "prismaixlog@outlook.com"
$imapPassword = Read-Host "Enter Outlook IMAP password (or app password)" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($imapPassword)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$saveFolder = "C:\Users\Keny\PycharmProjects\OnelinePowerShell\pop3_attachments"
$emailFile  = "latest_email.eml"

# --- Ensure save folder exists ---
if (-not (Test-Path $saveFolder)) {
    New-Item -ItemType Directory -Path $saveFolder | Out-Null
}

# --- Download the latest email using custom curl.exe (IMAP) ---
# The following command fetches the most recent email from the INBOX
$curlArgs = @(
    "--user", "$imapUser`:$UnsecurePassword"
    "--ssl-reqd"
    "imaps://$imapServer/INBOX;MAILINDEX=1"
    "-o", $emailFile
)
Write-Host "Running: $curlPath $($curlArgs -join ' ')"
& $curlPath @curlArgs

if (-not (Test-Path $emailFile)) {
    Write-Host "Failed to download email."
    exit
}

# --- Parse the .eml file and extract attachments ---
$emailContent = Get-Content $emailFile -Raw

# Find all MIME boundaries
$boundaryPattern = 'boundary="([^"]+)"'
$boundary = [regex]::Match($emailContent, $boundaryPattern).Groups[1].Value
if (-not $boundary) {
    Write-Host "No MIME boundary found. No attachments to extract."
    Remove-Item $emailFile -ErrorAction SilentlyContinue
    exit
}
$boundary = "--$boundary"

# Split the email into MIME parts
$parts = $emailContent -split [regex]::Escape($boundary)

foreach ($part in $parts) {
    # Look for attachment headers (skip inline images)
    if ($part -match 'Content-Disposition: attachment;.*filename="([^"]+)"') {
        $filename = $matches[1]
        # Find the start of the base64 content
        $base64Start = $part.IndexOf("base64") + 6
        if ($base64Start -lt 6) { continue }
        $base64Content = $part.Substring($base64Start) -replace "^\s+|\s+$", ""
        # Remove headers and blank lines
        $base64Content = ($base64Content -split "\r?\n\r?\n",2)[-1] -replace "\r?\n", ""
        try {
            $bytes = [System.Convert]::FromBase64String($base64Content)
            $filePath = Join-Path $saveFolder $filename
            [System.IO.File]::WriteAllBytes($filePath, $bytes)
            Write-Host "Extracted attachment: $filename"
        } catch {
            Write-Host "Failed to decode or save attachment: $filename"
        }
    }
}

# --- Cleanup ---
Remove-Item $emailFile -ErrorAction SilentlyContinue
Write-Host "Done. Attachments saved to $saveFolder"