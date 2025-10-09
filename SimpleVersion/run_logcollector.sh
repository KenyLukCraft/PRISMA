#!/bin/bash
# Wrapper script to run LogCollectorPi.ps1 with PowerShell
# This ensures the PowerShell script runs correctly on Raspberry Pi

# Check if PowerShell is installed
if ! command -v pwsh &> /dev/null; then
    echo "Error: PowerShell is not installed."
    echo "Please install PowerShell first:"
    echo "curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -"
    echo "echo 'deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-20.04-prod focal main' | sudo tee /etc/apt/sources.list.d/microsoft-prod.list"
    echo "sudo apt update && sudo apt install -y powershell"
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PS_SCRIPT="$SCRIPT_DIR/LogCollectorPi.ps1"

# Check if the PowerShell script exists
if [ ! -f "$PS_SCRIPT" ]; then
    echo "Error: LogCollectorPi.ps1 not found in $SCRIPT_DIR"
    exit 1
fi

# Run the PowerShell script
echo "Running LogCollectorPi.ps1 with PowerShell..."
pwsh -File "$PS_SCRIPT"

# Capture the exit code
EXIT_CODE=$?

# Report the result
if [ $EXIT_CODE -eq 0 ]; then
    echo "LogCollectorPi.ps1 completed successfully"
else
    echo "LogCollectorPi.ps1 failed with exit code: $EXIT_CODE"
fi

exit $EXIT_CODE
