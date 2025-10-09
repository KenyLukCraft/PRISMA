#!/bin/bash
# Complete permission fix for PRISMA on Raspberry Pi

echo "Fixing PowerShell permissions..."
chmod +x ~/powershell/pwsh

echo "Fixing script permissions..."
sudo chmod +x /opt/logcollector/LogCollectorPi.ps1
sudo chown pi:pi /opt/logcollector/LogCollectorPi.ps1

echo "Fixing directory permissions..."
sudo mkdir -p /tmp/printer_logs
sudo chown pi:pi /tmp/printer_logs
sudo chmod 755 /tmp/printer_logs

echo "Fixing log permissions..."
sudo touch /var/log/logcollector.log
sudo chown pi:pi /var/log/logcollector.log
sudo chmod 644 /var/log/logcollector.log

echo "Testing PowerShell..."
pwsh --version

echo "Testing script..."
cd /opt/logcollector
sudo pwsh -File LogCollectorPi.ps1

echo "All permissions fixed!"