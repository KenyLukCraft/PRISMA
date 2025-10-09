#!/bin/bash
# Setup script for LogCollectorPi.ps1 crontab
# Run this script to easily configure the log collector

echo "=== LogCollectorPi.ps1 Crontab Setup ==="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as a regular user, not as root."
    echo "The script will use sudo when needed."
    exit 1
fi

# Check if PowerShell is installed
if ! command -v pwsh &> /dev/null; then
    echo "PowerShell is not installed. Please install PowerShell first:"
    echo "curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -"
    echo "echo 'deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-20.04-prod focal main' | sudo tee /etc/apt/sources.list.d/microsoft-prod.list"
    echo "sudo apt update && sudo apt install -y powershell"
    exit 1
fi

echo "✓ PowerShell is installed: $(pwsh --version)"

# Check if LogCollectorPi.ps1 exists
if [ ! -f "LogCollectorPi.ps1" ]; then
    echo "❌ LogCollectorPi.ps1 not found in current directory"
    echo "Please run this script from the directory containing LogCollectorPi.ps1"
    exit 1
fi

echo "✓ LogCollectorPi.ps1 found"

# Create log directory
echo "Creating log directory..."
sudo mkdir -p /var/log
sudo touch /var/log/logcollector.log
sudo chown $USER:$USER /var/log/logcollector.log
echo "✓ Log directory created: /var/log/logcollector.log"

# Copy script to home directory
echo "Copying script to home directory..."
cp LogCollectorPi.ps1 /home/$USER/
chmod +x /home/$USER/LogCollectorPi.ps1
echo "✓ Script copied to: /home/$USER/LogCollectorPi.ps1"

# Test the script
echo "Testing the script..."
if /usr/bin/pwsh -File /home/$USER/LogCollectorPi.ps1; then
    echo "✓ Script test successful"
else
    echo "❌ Script test failed. Please check the configuration."
    exit 1
fi

# Show crontab options
echo ""
echo "=== Crontab Options ==="
echo "Choose a schedule:"
echo "1) Every 6 hours (recommended)"
echo "2) Every 4 hours"
echo "3) Every 2 hours during business hours (8 AM - 6 PM)"
echo "4) Twice daily (6 AM and 6 PM)"
echo "5) Every hour during business hours (9 AM - 5 PM, weekdays only)"
echo "6) Custom schedule"
echo ""

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        CRON_SCHEDULE="0 */6 * * *"
        ;;
    2)
        CRON_SCHEDULE="0 */4 * * *"
        ;;
    3)
        CRON_SCHEDULE="0 8-18/2 * * *"
        ;;
    4)
        CRON_SCHEDULE="0 6,18 * * *"
        ;;
    5)
        CRON_SCHEDULE="0 9-17 * * 1-5"
        ;;
    6)
        echo "Enter custom crontab schedule (format: minute hour day month weekday):"
        echo "Examples:"
        echo "  '0 */6 * * *' - every 6 hours"
        echo "  '0 2 * * *' - daily at 2 AM"
        echo "  '*/30 * * * *' - every 30 minutes"
        read -p "Schedule: " CRON_SCHEDULE
        ;;
    *)
        echo "Invalid choice. Using default: every 6 hours"
        CRON_SCHEDULE="0 */6 * * *"
        ;;
esac

# Create crontab entry
CRON_COMMAND="$CRON_SCHEDULE /usr/bin/pwsh -File /home/$USER/LogCollectorPi.ps1 >> /var/log/logcollector.log 2>&1"

echo ""
echo "Adding crontab entry:"
echo "$CRON_COMMAND"
echo ""

# Add to crontab
(crontab -l 2>/dev/null; echo "$CRON_COMMAND") | crontab -

if [ $? -eq 0 ]; then
    echo "✓ Crontab entry added successfully"
else
    echo "❌ Failed to add crontab entry"
    exit 1
fi

# Show current crontab
echo ""
echo "Current crontab entries:"
crontab -l

echo ""
echo "=== Setup Complete ==="
echo "The LogCollectorPi.ps1 script will now run automatically."
echo ""
echo "Useful commands:"
echo "  View logs: tail -f /var/log/logcollector.log"
echo "  Edit crontab: crontab -e"
echo "  View crontab: crontab -l"
echo "  Remove crontab: crontab -r"
echo "  Test script: /usr/bin/pwsh -File /home/$USER/LogCollectorPi.ps1"
echo ""
echo "The script will download the latest 2 CSV/ACL files from your printer"
echo "and email them to the configured recipients."
