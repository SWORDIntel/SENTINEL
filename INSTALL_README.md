# SENTINEL Installation Guide

## Overview

The SENTINEL framework provides enhanced security, autocomplete, and Python virtual environment support for your Bash shell. This document explains the installation process and troubleshooting steps.

## Installation

To install SENTINEL:

1. Clone the repository:
```bash
git clone https://github.com/username/SENTINEL.git
cd SENTINEL
```

2. Run the installer:
```bash
bash install.sh
```

3. Restart your shell or source the configuration:
```bash
source ~/.bashrc
```

## Reinstallation

If you need to completely reinstall SENTINEL:

1. Run the reinstall script:
```bash
bash reinstall.sh
```

2. Restart your shell or source the configuration.

## Uninstallation

To remove SENTINEL from your system:

1. Run the uninstall script:
```bash
bash uninstall.sh
```

2. Remove any remaining configuration files manually if needed.

## Directory Structure

1. Back up your current SENTINEL configuration
2. Clean up your environment
3. Remove all SENTINEL components

### Locations

- **Core Framework**: Located in `${HOME}`
- **Python venv**: Located in `${HOME}/venv`
- **BLE.sh**: Located in `${HOME}/.local/share/blesh`
- **Modules**: Located in `${HOME}/bash_modules.d`
- **Configuration**: Various files in `${HOME}`

## Verification

After installation, verify that SENTINEL was installed correctly:

```bash
source ${HOME}/bashrc.postcustom
@autocomplete status
```

## Troubleshooting

### Common Issues

1. **Autocomplete not working**:
   - Check that BLE.sh is properly installed
   - Ensure your .bashrc loads the SENTINEL framework
   - Try running `@autocomplete fix`

2. **Python environment issues**:
   - Ensure Python 3.6+ is installed
   - Check logs in `${HOME}/logs/`
   - Try reinstalling the venv with `bash reinstall.sh`

3. **Configuration problems**:
   - Ensure `VENV_AUTO=1` is set in your `${HOME}/bashrc.postcustom`
   - Check that your .bashrc is sourcing the SENTINEL framework
   - Check that required Python packages are installed in `${HOME}/venv/`

### Logs

For detailed troubleshooting, check the log files:

- Installation logs: `${HOME}/logs/install.log`
- Autocomplete logs: `${HOME}/logs/autocomplete-YYYYMMDD.log`
- Module logs: `${HOME}/logs/module-YYYYMMDD.log`

### Advanced Troubleshooting

1. Check the detailed logs in `${HOME}/logs/`
2. Run the verification checks: `bash sentinel_postinstall_check.sh`
3. Try a clean reinstallation: `bash reinstall.sh`

---

- SENTINEL Version: 2.3.0
- Last Updated: 2025-05-16 