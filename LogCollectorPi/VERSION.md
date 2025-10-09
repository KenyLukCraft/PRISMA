# LogCollectorPi Version Information

## Current Version: 1.0.0
**Release Date**: October 9, 2025

## Version History

### v1.0.0 (October 9, 2025)
**Status**: ✅ Consolidated & Production Ready

#### Changes
- ✅ Consolidated all Pi-specific files into `LogCollectorPi/` folder
- ✅ Updated all GitHub URLs to point to correct repository paths
- ✅ Created comprehensive README with full documentation
- ✅ Fixed URL inconsistencies across all files
- ✅ Standardized file naming conventions
- ✅ Added complete troubleshooting guide

#### Files Included
- `LogCollectorPi.ps1` - Main script (11,056 bytes)
- `install_pi.sh` - Automated installer (12,150 bytes)
- `update_pi.sh` - Update script (3,339 bytes)
- `run_logcollector.sh` - Wrapper script (1,276 bytes)
- `FixPermission.sh` - Permission fix (754 bytes)
- `Configuration_Template.ps1` - Config template (4,136 bytes)
- `logcollector.service` - Systemd service (753 bytes)
- `logcollector.timer` - Systemd timer (571 bytes)
- `RaspberryPi_Setup_Guide.md` - Detailed guide (10,666 bytes)
- `Pi_Quick_Start.md` - Quick start (4,636 bytes)
- `README.md` - Main documentation (22,000+ bytes)
- `VERSION.md` - This file

#### GitHub Repository Alignment
**Repository**: https://github.com/KenyLukCraft/PRISMA  
**Branch**: main  
**Path**: `/LogCollectorPi/`
**Branch**: master

All files use consistent GitHub URLs:
- ✅ `install_pi.sh` → `.../PRISMA/master/LogCollectorPi/install_pi.sh`
- ✅ `update_pi.sh` → `.../PRISMA/master/LogCollectorPi/LogCollectorPi.ps1`
- ✅ `Pi_Quick_Start.md` → Updated URLs
- ✅ `logcollector.service` → Updated documentation link
- ✅ `logcollector.timer` → Updated documentation link

## File Checksums (For Verification)

To verify file integrity after download:

```bash
# Generate checksums on your system
cd /opt/logcollector
sha256sum LogCollectorPi.ps1
sha256sum install_pi.sh
sha256sum update_pi.sh
```

## Compatibility

### Tested On
- ✅ Raspberry Pi Zero 2W (Debian Bookworm)
- ✅ Raspberry Pi 4B (Debian Bookworm)
- ✅ PowerShell 7.5.3 (arm64)
- ⚠️ Pi Zero W (Limited testing - may have performance issues)

### Requirements
- **PowerShell**: 7.5.3 or higher
- **OS**: Raspberry Pi OS Lite (64-bit recommended)
- **Memory**: 512MB minimum
- **Storage**: 8GB microSD minimum

## Migration Guide

### From SimpleVersion/ to LogCollectorPi/

If you're using files from `SimpleVersion/`, update your URLs:

**Old URLs (SimpleVersion)**:
```bash
# Old install URL
wget https://raw.githubusercontent.com/.../SimpleVersion/install_pi.sh

# Old script URL (in update_pi.sh)
REPO_URL=".../SimpleVersion/LogCollectorPi.ps1"
```

**New URLs (LogCollectorPi)**:
```bash
# New install URL
wget https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/install_pi.sh

# New script URL (in update_pi.sh)
REPO_URL="https://raw.githubusercontent.com/KenyLukCraft/OnelinePowerShell/main/LogCollectorPi/LogCollectorPi.ps1"
```

### Update Steps
```bash
# 1. Backup your current configuration
cd /opt/logcollector
sudo cp LogCollectorPi.ps1 ~/LogCollectorPi.ps1.backup

# 2. Extract your configuration
grep -E '^\$baseUrl|^\$pagePath|^\$smtpServer|^\$fromEmail|^\$toEmail|^\$base64Password' ~/LogCollectorPi.ps1.backup

# 3. Download new version
sudo wget https://raw.githubusercontent.com/KenyLukCraft/PRISMA/master/LogCollectorPi/LogCollectorPi.ps1 -O LogCollectorPi.ps1

# 4. Apply your configuration
sudo nano LogCollectorPi.ps1

# 5. Test
sudo pwsh -File LogCollectorPi.ps1

# 6. Restart services
sudo systemctl restart logcollector.service
sudo systemctl restart logcollector.timer
```

## Known Issues

### Current Issues
None reported for v1.0.0

### Fixed in v1.0.0
- ✅ URL inconsistencies (SimpleVersion vs LogCollectorPi paths)
- ✅ Missing comprehensive README
- ✅ Scattered documentation
- ✅ Placeholder URLs (your-repo)

## Future Roadmap

### v1.1.0 (Planned)
- [ ] Support for multiple printers in single script
- [ ] Configuration file support (external .conf file)
- [ ] Web dashboard for monitoring
- [ ] Enhanced error reporting with detailed logs

### v1.2.0 (Planned)
- [ ] Support for additional file types (PDF, TXT, etc.)
- [ ] Database integration for log history
- [ ] Advanced filtering and search capabilities
- [ ] RESTful API for remote management

### v2.0.0 (Future)
- [ ] Complete rewrite in Python for better Pi compatibility
- [ ] GUI configuration tool
- [ ] Multi-platform support (x86, arm32, arm64)
- [ ] Cloud backup integration

## Support & Contributions

### Getting Support
1. Check the README.md for common issues
2. Review RaspberryPi_Setup_Guide.md for detailed setup
3. Check GitHub issues: https://github.com/KenyLukCraft/OnelinePowerShell/issues
4. Create new issue with detailed information

### Contributing
Contributions welcome! Please:
1. Fork the repository
2. Create feature branch
3. Test on Pi Zero 2W
4. Submit pull request
5. Update documentation

## License
Open source - please ensure compliance with your organization's policies.

## Maintainer
**KenyLukCraft**  
GitHub: https://github.com/KenyLukCraft  
Repository: https://github.com/KenyLukCraft/PRISMA

---

**Last Updated**: October 9, 2025  
**Document Version**: 1.0

