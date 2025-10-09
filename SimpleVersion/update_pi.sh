#!/bin/bash
# update_pi.sh - Automated update script for LogCollectorPi.ps1

set -e  # Exit on any error

echo "🔄 Updating LogCollectorPi.ps1 on Raspberry Pi..."

# Configuration
SCRIPT_DIR="/opt/logcollector"
BACKUP_DIR="/opt/logcollector/backups"
REPO_URL="https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/SimpleVersion/LogCollectorPi.ps1"

# Create backup directory if it doesn't exist
sudo mkdir -p "$BACKUP_DIR"

# Create timestamp for backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "📁 Creating backup of current script..."
if [ -f "$SCRIPT_DIR/LogCollectorPi.ps1" ]; then
    sudo cp "$SCRIPT_DIR/LogCollectorPi.ps1" "$BACKUP_DIR/LogCollectorPi.ps1.backup.$TIMESTAMP"
    echo "✅ Backup created: LogCollectorPi.ps1.backup.$TIMESTAMP"
else
    echo "⚠️  No existing script found to backup"
fi

echo "⬇️  Downloading latest script..."
cd "$SCRIPT_DIR"
sudo wget -q "$REPO_URL" -O LogCollectorPi.ps1.new

echo "🔍 Validating downloaded script..."
if [ -s "LogCollectorPi.ps1.new" ]; then
    echo "✅ Script downloaded successfully"
    
    # Test the script syntax
    echo "🧪 Testing script syntax..."
    if sudo pwsh -Command "& { try { . './LogCollectorPi.ps1.new' -WhatIf; Write-Host 'Syntax OK' } catch { Write-Host 'Syntax Error:' \$_.Exception.Message; exit 1 } }" 2>/dev/null; then
        echo "✅ Script syntax is valid"
        
        # Replace the old script
        sudo mv LogCollectorPi.ps1.new LogCollectorPi.ps1
        sudo chmod +x LogCollectorPi.ps1
        sudo chown pi:pi LogCollectorPi.ps1
        
        echo "✅ Script updated successfully!"
        
        # Restart service if it exists
        if systemctl is-active --quiet logcollector.service 2>/dev/null; then
            echo "🔄 Restarting logcollector service..."
            sudo systemctl restart logcollector.service
            echo "✅ Service restarted"
        fi
        
        # Restart timer if it exists
        if systemctl is-active --quiet logcollector.timer 2>/dev/null; then
            echo "🔄 Restarting logcollector timer..."
            sudo systemctl restart logcollector.timer
            echo "✅ Timer restarted"
        fi
        
        echo "🎉 Update completed successfully!"
        echo "📊 Current version info:"
        head -5 LogCollectorPi.ps1 | grep -E "^#|^$" || echo "Script updated to latest version"
        
    else
        echo "❌ Script syntax validation failed"
        echo "🔄 Restoring backup..."
        if [ -f "$BACKUP_DIR/LogCollectorPi.ps1.backup.$TIMESTAMP" ]; then
            sudo cp "$BACKUP_DIR/LogCollectorPi.ps1.backup.$TIMESTAMP" LogCollectorPi.ps1
            echo "✅ Backup restored"
        fi
        sudo rm -f LogCollectorPi.ps1.new
        exit 1
    fi
else
    echo "❌ Failed to download script"
    sudo rm -f LogCollectorPi.ps1.new
    exit 1
fi

# Clean up old backups (keep last 5)
echo "🧹 Cleaning up old backups..."
cd "$BACKUP_DIR"
ls -t LogCollectorPi.ps1.backup.* 2>/dev/null | tail -n +6 | xargs -r sudo rm -f

echo "✨ Update process completed!"
echo ""
echo "📋 Next steps:"
echo "1. Test the script manually: sudo pwsh -File LogCollectorPi.ps1"
echo "2. Check service status: sudo systemctl status logcollector.service"
echo "3. View logs: sudo journalctl -u logcollector.service -f"
