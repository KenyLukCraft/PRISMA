#!/bin/bash
# install_pi.sh - Automated installation script for LogCollectorPi.ps1 on Raspberry Pi Zero 2W
# Run this script on your Raspberry Pi after initial setup

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="/opt/logcollector"
LOG_FILE="/var/log/logcollector_install.log"
SERVICE_USER="pi"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  LogCollectorPi.ps1 Installation Script${NC}"
echo -e "${BLUE}  For Raspberry Pi Zero 2W${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}Error: This script should not be run as root${NC}"
        echo -e "${YELLOW}Please run as: sudo -u pi ./install_pi.sh${NC}"
        exit 1
    fi
}

# Function to check system requirements
check_requirements() {
    log_message "Checking system requirements..."
    
    # Check if running on Raspberry Pi
    if ! grep -q "Raspberry Pi" /proc/cpuinfo; then
        echo -e "${YELLOW}Warning: This doesn't appear to be a Raspberry Pi${NC}"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Check available memory
    MEMORY_MB=$(free -m | awk 'NR==2{printf "%.0f", $2}')
    if [ "$MEMORY_MB" -lt 400 ]; then
        echo -e "${YELLOW}Warning: Low memory detected (${MEMORY_MB}MB)${NC}"
        echo -e "${YELLOW}Pi Zero 2W should have 512MB. Consider optimizing system.${NC}"
    fi
    
    # Check disk space
    DISK_SPACE=$(df / | awk 'NR==2 {print $4}')
    if [ "$DISK_SPACE" -lt 1048576 ]; then  # Less than 1GB free
        echo -e "${RED}Error: Insufficient disk space (less than 1GB free)${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ System requirements check passed${NC}"
}

# Function to install PowerShell Core
install_powershell() {
    log_message "Installing PowerShell Core..."
    
    if command -v pwsh &> /dev/null; then
        echo -e "${GREEN}✓ PowerShell Core already installed${NC}"
        pwsh --version
        return 0
    fi
    
    echo -e "${YELLOW}Installing PowerShell Core...${NC}"
    
    # Update package list
    sudo apt update
    
    # Install prerequisites
    sudo apt install -y curl gnupg apt-transport-https
    
    # Install PowerShell Core using direct download
    # Note: Microsoft repository doesn't have PowerShell for Debian Bookworm yet
    echo -e "${YELLOW}Downloading PowerShell directly from GitHub...${NC}"
    
    # Try .deb package first
    if wget https://github.com/PowerShell/PowerShell/releases/download/v7.5.3/powershell_7.5.3-1.deb_arm64.deb; then
        if sudo dpkg -i powershell_7.5.3-1.deb_arm64.deb; then
            sudo apt-get install -f  # Fix any dependency issues
            rm -f powershell_7.5.3-1.deb_arm64.deb
        else
            echo -e "${YELLOW}.deb installation failed, trying tar.gz method...${NC}"
            rm -f powershell_7.5.3-1.deb_arm64.deb
            # Fallback to tar.gz method
            wget https://github.com/PowerShell/PowerShell/releases/download/v7.5.3/powershell-7.5.3-linux-arm64.tar.gz
            mkdir -p ~/powershell
            tar -xzf powershell-7.5.3-linux-arm64.tar.gz -C ~/powershell
            sudo ln -s ~/powershell/pwsh /usr/local/bin/pwsh
            rm -f powershell-7.5.3-linux-arm64.tar.gz
        fi
    else
        echo -e "${YELLOW}Download failed, trying tar.gz method...${NC}"
        # Fallback to tar.gz method
        wget https://github.com/PowerShell/PowerShell/releases/download/v7.5.3/powershell-7.5.3-linux-arm64.tar.gz
        mkdir -p ~/powershell
        tar -xzf powershell-7.5.3-linux-arm64.tar.gz -C ~/powershell
        sudo ln -s ~/powershell/pwsh /usr/local/bin/pwsh
        rm -f powershell-7.5.3-linux-arm64.tar.gz
    fi
    
    # Verify installation
    if command -v pwsh &> /dev/null; then
        echo -e "${GREEN}✓ PowerShell Core installed successfully${NC}"
        pwsh --version
    else
        echo -e "${RED}✗ PowerShell Core installation failed${NC}"
        exit 1
    fi
}

# Function to create application directory
setup_directories() {
    log_message "Setting up application directories..."
    
    # Create main directory
    sudo mkdir -p "$SCRIPT_DIR"
    sudo chown "$SERVICE_USER:$SERVICE_USER" "$SCRIPT_DIR"
    
    # Create log directory
    sudo mkdir -p /tmp/printer_logs
    sudo chown "$SERVICE_USER:$SERVICE_USER" /tmp/printer_logs
    
    # Create log file
    sudo touch "$LOG_FILE"
    sudo chown "$SERVICE_USER:$SERVICE_USER" "$LOG_FILE"
    
    echo -e "${GREEN}✓ Directories created successfully${NC}"
}

# Function to install the PowerShell script
install_script() {
    log_message "Installing LogCollectorPi.ps1 script..."
    
    # Check if script exists in current directory
    if [ ! -f "LogCollectorPi.ps1" ]; then
        echo -e "${RED}Error: LogCollectorPi.ps1 not found in current directory${NC}"
        echo -e "${YELLOW}Please ensure the script is in the same directory as this installer${NC}"
        exit 1
    fi
    
    # Copy script to application directory
    cp LogCollectorPi.ps1 "$SCRIPT_DIR/"
    chmod +x "$SCRIPT_DIR/LogCollectorPi.ps1"
    
    echo -e "${GREEN}✓ Script installed successfully${NC}"
}

# Function to configure the script
configure_script() {
    log_message "Configuring LogCollectorPi.ps1..."
    
    echo -e "${YELLOW}Script configuration required:${NC}"
    echo -e "${BLUE}Please edit the configuration section in LogCollectorPi.ps1${NC}"
    echo ""
    echo -e "${YELLOW}Required settings:${NC}"
    echo "  - Printer IP address (baseUrl)"
    echo "  - Printer log path (pagePath)"
    echo "  - Email SMTP server"
    echo "  - Email credentials"
    echo "  - Recipient email addresses"
    echo ""
    
    read -p "Open script for editing now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        nano "$SCRIPT_DIR/LogCollectorPi.ps1"
    else
        echo -e "${YELLOW}Remember to configure the script before running it!${NC}"
    fi
}

# Function to test the script
test_script() {
    log_message "Testing LogCollectorPi.ps1..."
    
    echo -e "${YELLOW}Testing script execution...${NC}"
    
    cd "$SCRIPT_DIR"
    if sudo -u "$SERVICE_USER" pwsh -File LogCollectorPi.ps1; then
        echo -e "${GREEN}✓ Script test completed successfully${NC}"
    else
        echo -e "${RED}✗ Script test failed${NC}"
        echo -e "${YELLOW}Please check the configuration and try again${NC}"
        return 1
    fi
}

# Function to setup cron job
setup_cron() {
    log_message "Setting up cron job..."
    
    echo -e "${YELLOW}Setting up automatic execution...${NC}"
    echo "Choose execution frequency:"
    echo "1) Every 6 hours"
    echo "2) Daily at 2 AM"
    echo "3) Every 12 hours"
    echo "4) Custom (manual setup)"
    echo "5) Skip (no automatic execution)"
    
    read -p "Enter choice (1-5): " choice
    
    case $choice in
        1)
            CRON_SCHEDULE="0 */6 * * *"
            ;;
        2)
            CRON_SCHEDULE="0 2 * * *"
            ;;
        3)
            CRON_SCHEDULE="0 */12 * * *"
            ;;
        4)
            echo -e "${YELLOW}Manual cron setup required${NC}"
            echo "Add this line to your crontab:"
            echo "cd $SCRIPT_DIR && pwsh -File LogCollectorPi.ps1 >> $LOG_FILE 2>&1"
            return 0
            ;;
        5)
            echo -e "${YELLOW}Skipping automatic execution setup${NC}"
            return 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            return 1
            ;;
    esac
    
    # Add cron job
    (crontab -l 2>/dev/null; echo "$CRON_SCHEDULE cd $SCRIPT_DIR && pwsh -File LogCollectorPi.ps1 >> $LOG_FILE 2>&1") | crontab -
    
    echo -e "${GREEN}✓ Cron job added successfully${NC}"
    echo -e "${BLUE}Schedule: $CRON_SCHEDULE${NC}"
}

# Function to setup systemd service (alternative to cron)
setup_systemd() {
    log_message "Setting up systemd service..."
    
    read -p "Setup systemd service instead of cron? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 0
    fi
    
    # Create service file
    sudo tee /etc/systemd/system/logcollector.service > /dev/null <<EOF
[Unit]
Description=Printer Log Collector
After=network.target

[Service]
Type=oneshot
User=$SERVICE_USER
WorkingDirectory=$SCRIPT_DIR
ExecStart=/usr/bin/pwsh -File LogCollectorPi.ps1
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    # Create timer file
    sudo tee /etc/systemd/system/logcollector.timer > /dev/null <<EOF
[Unit]
Description=Run LogCollector every 6 hours
Requires=logcollector.service

[Timer]
OnCalendar=*-*-* 00,06,12,18:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

    # Enable and start
    sudo systemctl daemon-reload
    sudo systemctl enable logcollector.timer
    sudo systemctl start logcollector.timer
    
    echo -e "${GREEN}✓ Systemd service configured successfully${NC}"
    sudo systemctl status logcollector.timer
}

# Function to optimize system for Pi Zero 2W
optimize_system() {
    log_message "Optimizing system for Pi Zero 2W..."
    
    read -p "Apply Pi Zero 2W optimizations? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 0
    fi
    
    # Disable unnecessary services
    sudo systemctl disable bluetooth 2>/dev/null || true
    sudo systemctl disable hciuart 2>/dev/null || true
    
    # Increase swap space
    if [ -f /etc/dphys-swapfile ]; then
        sudo sed -i 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=512/' /etc/dphys-swapfile
        sudo dphys-swapfile setup
        sudo dphys-swapfile swapon
        echo -e "${GREEN}✓ Swap space increased to 512MB${NC}"
    fi
    
    # Disable audio
    echo 'dtparam=audio=off' | sudo tee -a /boot/config.txt > /dev/null
    
    echo -e "${GREEN}✓ System optimizations applied${NC}"
}

# Function to show final instructions
show_final_instructions() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Installation Completed Successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Configure the script: nano $SCRIPT_DIR/LogCollectorPi.ps1"
    echo "2. Test the script: cd $SCRIPT_DIR && pwsh -File LogCollectorPi.ps1"
    echo "3. Check logs: tail -f $LOG_FILE"
    echo "4. Monitor system: htop"
    echo ""
    echo -e "${BLUE}Useful commands:${NC}"
    echo "  - View cron jobs: crontab -l"
    echo "  - Check service status: sudo systemctl status logcollector.timer"
    echo "  - View recent logs: sudo journalctl -u logcollector.service -f"
    echo "  - Test connectivity: ping [PRINTER_IP]"
    echo ""
    echo -e "${YELLOW}Remember to:${NC}"
    echo "  - Configure your printer IP and email settings"
    echo "  - Test the script before relying on automation"
    echo "  - Monitor system resources on Pi Zero 2W"
    echo ""
    echo -e "${GREEN}Installation log saved to: $LOG_FILE${NC}"
}

# Main execution
main() {
    log_message "Starting LogCollectorPi.ps1 installation"
    
    check_root
    check_requirements
    install_powershell
    setup_directories
    install_script
    configure_script
    
    # Ask if user wants to test now
    read -p "Test the script now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        test_script
    fi
    
    setup_cron
    setup_systemd
    optimize_system
    show_final_instructions
    
    log_message "Installation completed successfully"
}

# Run main function
main "$@"
