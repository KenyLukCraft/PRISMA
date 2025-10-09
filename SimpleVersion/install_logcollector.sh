#!/bin/bash
# Installation script for LogCollectorPi.ps1
# This script sets up the proper environment and permissions

echo "=== LogCollectorPi.ps1 Installation Script ==="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as a regular user, not as root."
    echo "The script will use sudo when needed."
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PS_SCRIPT="$SCRIPT_DIR/LogCollectorPi.ps1"
WRAPPER_SCRIPT="$SCRIPT_DIR/run_logcollector.sh"

echo "Script directory: $SCRIPT_DIR"
echo ""

# Check if PowerShell is installed
if ! command -v pwsh &> /dev/null; then
    echo "PowerShell is not installed. Installing..."
    echo ""
    
    # Install PowerShell
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    echo 'deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-20.04-prod focal main' | sudo tee /etc/apt/sources.list.d/microsoft-prod.list
    sudo apt update
    sudo apt install -y powershell
    
    if [ $? -eq 0 ]; then
        echo "✓ PowerShell installed successfully"
    else
        echo "✗ Failed to install PowerShell"
        exit 1
    fi
else
    echo "✓ PowerShell is already installed: $(pwsh --version)"
fi

# Check if LogCollectorPi.ps1 exists
if [ ! -f "$PS_SCRIPT" ]; then
    echo "✗ LogCollectorPi.ps1 not found in $SCRIPT_DIR"
    exit 1
fi

echo "✓ LogCollectorPi.ps1 found"

# Make the PowerShell script executable (though it won't run directly)
chmod +x "$PS_SCRIPT"
echo "✓ Set permissions on LogCollectorPi.ps1"

# Make the wrapper script executable
chmod +x "$WRAPPER_SCRIPT"
echo "✓ Set permissions on run_logcollector.sh"

# Create log directory
echo "Creating log directory..."
sudo mkdir -p /var/log
sudo touch /var/log/logcollector.log
sudo chown $USER:$USER /var/log/logcollector.log
echo "✓ Log directory created: /var/log/logcollector.log"

# Test the script
echo ""
echo "Testing the script..."
if "$WRAPPER_SCRIPT"; then
    echo "✓ Script test successful"
else
    echo "⚠ Script test completed (may have failed due to printer connectivity)"
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Usage instructions:"
echo "1. To run the script manually:"
echo "   ./run_logcollector.sh"
echo ""
echo "2. To add to crontab (run every 6 hours):"
echo "   0 */6 * * * $(pwd)/run_logcollector.sh >> /var/log/logcollector.log 2>&1"
echo ""
echo "3. To edit crontab:"
echo "   crontab -e"
echo ""
echo "4. To view logs:"
echo "   tail -f /var/log/logcollector.log"
echo ""
echo "The script will now:"
echo "- Always send email notifications (success or failure)"
echo "- Handle printer offline scenarios gracefully"
echo "- Download the latest 2 CSV/ACL files when printer is online"
echo "- Provide detailed error messages when printer is offline"
