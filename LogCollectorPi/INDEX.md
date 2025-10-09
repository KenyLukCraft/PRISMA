# LogCollectorPi - Complete File Index

Quick reference guide to all files in the LogCollectorPi project.

## 📚 Documentation Files

### 1. README.md
**Purpose**: Main project documentation  
**Size**: 22KB+  
**Audience**: All users  
**Contents**:
- Feature overview
- Installation instructions
- Configuration guide
- Troubleshooting
- Full API reference

**Start Here**: ⭐ New users should read this first!

### 2. Pi_Quick_Start.md
**Purpose**: Fast 5-minute setup guide  
**Size**: 4.6KB  
**Audience**: Experienced users  
**Contents**:
- Quick installation steps
- Basic configuration
- Essential commands
- Common examples

**Use When**: You want to get up and running quickly

### 3. RaspberryPi_Setup_Guide.md
**Purpose**: Detailed setup and configuration  
**Size**: 10.7KB  
**Audience**: New users, troubleshooting  
**Contents**:
- Step-by-step installation
- PowerShell installation methods
- System optimizations
- Advanced configuration
- Troubleshooting guide

**Use When**: You need detailed instructions or encounter issues

### 4. VERSION.md
**Purpose**: Version history and compatibility  
**Size**: 5KB  
**Audience**: Maintainers, upgraders  
**Contents**:
- Current version information
- Changelog
- Migration guide
- Known issues
- Future roadmap

**Use When**: Checking compatibility or migration

### 5. INDEX.md
**Purpose**: This file - navigation guide  
**Size**: Current file  
**Audience**: All users  
**Contents**: File directory and quick reference

## 🔧 Script Files

### 6. LogCollectorPi.ps1
**Purpose**: Main PowerShell script  
**Size**: 11KB  
**Language**: PowerShell 7.5+  
**Execution**: `pwsh -File LogCollectorPi.ps1`

**What It Does**:
- Connects to printer web interface
- Extracts CSV and ACL file links
- Downloads latest 2 files
- Sends email with attachments
- Handles errors and offline scenarios
- Cleans up old files

**Configuration Required**:
- Printer IP address (`$baseUrl`)
- Printer log path (`$pagePath`)
- Email settings (SMTP, credentials)
- Encoded password (`$base64Password`)

**Optimization**:
- 30s web request timeout
- 60s download timeout
- Uses `/tmp` for temporary storage
- Auto-cleanup keeps last 5 files

### 7. Configuration_Template.ps1
**Purpose**: Configuration template and examples  
**Size**: 4.1KB  
**Language**: PowerShell  
**Usage**: Copy values to LogCollectorPi.ps1

**Contains**:
- All configuration options with descriptions
- Common printer brand settings (Canon, HP, Epson, Brother)
- Email provider examples (Gmail, Outlook, Yahoo, Zoho)
- Password encoding instructions
- Troubleshooting tips

**Use When**: Setting up or reconfiguring the script

## 🚀 Installation & Management Scripts

### 8. install_pi.sh
**Purpose**: Automated one-command installer  
**Size**: 12.2KB  
**Language**: Bash  
**Execution**: `sudo ./install_pi.sh`

**What It Does**:
1. Checks system requirements
2. Installs PowerShell Core 7.5.3
3. Creates directories (`/opt/logcollector`, `/tmp/printer_logs`)
4. Installs LogCollectorPi.ps1
5. Prompts for configuration
6. Sets up scheduling (cron or systemd)
7. Applies Pi Zero 2W optimizations

**Features**:
- Interactive prompts
- Multiple PowerShell installation methods (.deb, tar.gz)
- Automatic dependency resolution
- Swap space optimization
- Service configuration

**Use When**: First-time installation

### 9. update_pi.sh
**Purpose**: Update script from GitHub  
**Size**: 3.3KB  
**Language**: Bash  
**Execution**: `sudo ./update_pi.sh`

**What It Does**:
1. Creates timestamped backup
2. Downloads latest version from GitHub
3. Validates syntax
4. Replaces old script
5. Restarts services
6. Cleans up old backups (keeps last 5)

**Safety Features**:
- Automatic backup before update
- Syntax validation
- Rollback on failure
- Service restart

**Use When**: Updating to latest version from GitHub

### 10. run_logcollector.sh
**Purpose**: Bash wrapper for PowerShell script  
**Size**: 1.3KB  
**Language**: Bash  
**Execution**: `./run_logcollector.sh`

**What It Does**:
- Checks PowerShell installation
- Locates LogCollectorPi.ps1
- Runs script with pwsh
- Reports exit code

**Use When**: Running script from cron or manually via bash

### 11. FixPermission.sh
**Purpose**: Fix common permission issues  
**Size**: 754 bytes  
**Language**: Bash  
**Execution**: `sudo ./FixPermission.sh`

**What It Does**:
- Fixes PowerShell binary permissions
- Fixes script file permissions
- Creates/fixes log directories
- Tests PowerShell and script

**Use When**: Encountering "Permission denied" errors

## ⚙️ System Service Files

### 12. logcollector.service
**Purpose**: Systemd service definition  
**Size**: 753 bytes  
**Format**: Systemd unit file  
**Location**: `/etc/systemd/system/logcollector.service`

**Configuration**:
- Type: oneshot
- User/Group: pi
- Working Directory: `/opt/logcollector`
- Command: `/usr/bin/pwsh -File LogCollectorPi.ps1`
- Memory Limit: 200MB
- CPU Quota: 50%

**Security Settings**:
- NoNewPrivileges
- PrivateTmp
- ProtectSystem=strict
- ProtectHome

**Use When**: Setting up systemd-based scheduling

### 13. logcollector.timer
**Purpose**: Systemd timer for scheduling  
**Size**: 571 bytes  
**Format**: Systemd timer file  
**Location**: `/etc/systemd/system/logcollector.timer`

**Default Schedule**: Every 6 hours (00:00, 06:00, 12:00, 18:00)

**Alternative Schedules** (commented in file):
- Every 4 hours
- Every 8 hours
- Daily at 2 AM
- Weekdays at 6 AM

**Settings**:
- Persistent: true (runs missed schedules)
- RandomizedDelay: 300s (prevents exact-time load spikes)
- Accuracy: 1 minute

**Use When**: Prefer systemd over cron for scheduling

## 📁 Directory Structure After Installation

```
/opt/logcollector/                    # Main installation directory
├── LogCollectorPi.ps1               # Main script
├── backups/                          # Created by update_pi.sh
│   └── LogCollectorPi.ps1.backup.*  # Timestamped backups
└── [other scripts if copied]

/tmp/printer_logs/                    # Temporary download directory
└── [downloaded CSV/ACL files]        # Auto-cleaned (keeps last 5)

/var/log/
└── logcollector.log                 # Script execution logs

/etc/systemd/system/                 # If using systemd
├── logcollector.service
└── logcollector.timer
```

## 🔗 Quick Command Reference

### Installation
```bash
# Quick install
wget https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/install_pi.sh
chmod +x install_pi.sh
sudo ./install_pi.sh
```

### Running
```bash
# Manual run
cd /opt/logcollector
sudo pwsh -File LogCollectorPi.ps1

# Via wrapper
./run_logcollector.sh
```

### Updating
```bash
# Download and run updater
cd /opt/logcollector
wget https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/update_pi.sh
chmod +x update_pi.sh
sudo ./update_pi.sh
```

### Monitoring
```bash
# View logs
tail -f /var/log/logcollector.log

# Systemd logs
sudo journalctl -u logcollector.service -f

# Check timer status
sudo systemctl status logcollector.timer

# List timers
sudo systemctl list-timers logcollector.timer
```

### Troubleshooting
```bash
# Fix permissions
sudo ./FixPermission.sh

# Test connectivity
ping [PRINTER_IP]
curl -I http://[PRINTER_IP]/accounting

# Check PowerShell
pwsh --version

# System resources
htop
free -h
df -h
```

## 📖 Suggested Reading Order

### For New Users
1. **README.md** - Get overview and understand features
2. **Pi_Quick_Start.md** - Follow quick installation
3. **Configuration_Template.ps1** - Understand configuration options
4. Run **install_pi.sh**
5. Test manually
6. **RaspberryPi_Setup_Guide.md** - If issues arise

### For Experienced Users
1. **Pi_Quick_Start.md** - Quick setup
2. **Configuration_Template.ps1** - Copy needed values
3. Run **install_pi.sh** or manual installation
4. **README.md** - Reference as needed

### For Troubleshooting
1. **README.md** → Troubleshooting section
2. **RaspberryPi_Setup_Guide.md** → Troubleshooting section
3. **FixPermission.sh** - Run if permission issues
4. **VERSION.md** - Check known issues

### For Maintainers
1. **VERSION.md** - Version history
2. **README.md** - Full documentation
3. **INDEX.md** - This file
4. All script files - Understand implementation

## 🔄 File Dependencies

```
install_pi.sh
    ↓ downloads/installs
PowerShell Core
    ↓ required by
LogCollectorPi.ps1 ← configured by ← Configuration_Template.ps1
    ↓ executed by
run_logcollector.sh
    ↓ scheduled by
logcollector.timer → triggers → logcollector.service
    ↓ updated by
update_pi.sh
    ↓ fixed by
FixPermission.sh
```

## 🎯 File Selection Guide

**I want to...**

- **Understand the project** → README.md
- **Install quickly** → Pi_Quick_Start.md + install_pi.sh
- **Install with details** → RaspberryPi_Setup_Guide.md + install_pi.sh
- **Configure settings** → Configuration_Template.ps1 → LogCollectorPi.ps1
- **Update to latest** → update_pi.sh
- **Fix permissions** → FixPermission.sh
- **Run manually** → run_logcollector.sh or LogCollectorPi.ps1
- **Schedule execution** → logcollector.service + logcollector.timer
- **Check version** → VERSION.md
- **Find a file** → INDEX.md (this file)
- **Troubleshoot** → README.md or RaspberryPi_Setup_Guide.md

## 📊 File Statistics

| Category | Count | Total Size |
|----------|-------|------------|
| Documentation | 5 | ~45KB |
| Scripts (PowerShell) | 2 | ~15KB |
| Scripts (Bash) | 4 | ~17KB |
| System Files | 2 | ~1.3KB |
| **Total** | **13** | **~78KB** |

## 🌐 All GitHub URLs

### Download Links
```
# Main installer
https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/install_pi.sh

# Update script
https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/update_pi.sh

# Main script (used by updater)
https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/LogCollectorPi.ps1

# Repository
https://github.com/KenyLukCraft/OnelinePowerShell

# Project folder
https://github.com/KenyLukCraft/OnelinePowerShell/tree/main/LogCollectorPi
```

### PowerShell Downloads
```
# .deb package (recommended)
https://github.com/PowerShell/PowerShell/releases/download/v7.5.3/powershell_7.5.3-1.deb_arm64.deb

# tar.gz package (alternative)
https://github.com/PowerShell/PowerShell/releases/download/v7.5.3/powershell-7.5.3-linux-arm64.tar.gz
```

## 📝 Notes

### Character Encoding
All files use UTF-8 encoding without BOM.

### Line Endings
- Bash scripts (.sh): LF (Unix)
- PowerShell scripts (.ps1): CRLF (Windows) or LF (Unix) - both work
- Documentation (.md): LF (Unix)

### Permissions
After download, scripts need execute permissions:
```bash
chmod +x *.sh
```

PowerShell scripts don't need execute permission (run via `pwsh -File`).

---

**Last Updated**: October 9, 2025  
**Document Version**: 1.0  
**Files Documented**: 13  
**Total Project Size**: ~78KB

