# SENTINEL Installation Guide

## Overview

The SENTINEL framework provides enhanced security, autocomplete, and Python virtual environment support for your Bash shell. This document explains the installation process and troubleshooting steps.

## Installation

To install SENTINEL:

```bash
bash install.sh
```

This script will:

1. Install required dependencies
2. Create the necessary directory structure
3. Set up a Python virtual environment with required packages
4. Install BLE.sh for enhanced autocomplete functionality
5. Configure your Bash environment
6. Install modular autocomplete system

## Reinstallation

If you need to completely reinstall SENTINEL:

```bash
bash reinstall.sh
```

This will:
1. Back up your current SENTINEL configuration
2. Remove the existing installation
3. Run a fresh installation

## Uninstallation

To remove SENTINEL from your system:

```bash
bash uninstall.sh
```

This will:
1. Back up your current SENTINEL configuration
2. Restore your original Bash configuration where possible
3. Remove all SENTINEL components

## Components

SENTINEL consists of several key components:

- **Core Framework**: Located in `~/.sentinel/`
- **Autocomplete System**: Modular system for intelligent command completion
- **Python venv Integration**: Automatic virtual environment activation
- **Bash Enhancements**: Improved command history, aliases, and functions
- **Security Features**: Enhanced security for shell operations

## Directory Structure

```
~/.sentinel/
├── autocomplete/          # Autocomplete system data
├── bash_modules.d/        # Modular Bash enhancements
├── logs/                  # System logs
└── venv/                  # Python virtual environment

~/bash_aliases.d/          # Custom aliases
~/bash_completion.d/       # Bash completion scripts
~/bash_functions.d/        # Custom functions
~/contrib/                 # Contributed scripts and tools
```

## Troubleshooting

### Autocomplete Not Working

If the autocomplete system isn't functioning correctly:

1. Run `@autocomplete status` to check system status
2. Run `@autocomplete fix` to repair common issues
3. Check logs in `~/.sentinel/logs/`
4. Ensure BLE.sh is properly installed with `@autocomplete install`
5. Restart your terminal session

### Python Virtual Environment Issues

If Python venv auto-activation isn't working:

1. Ensure `VENV_AUTO=1` is set in your `~/.sentinel/bashrc.postcustom`
2. Run the installer again to fix Python environment issues
3. Check that required Python packages are installed in `~/.sentinel/venv/`

### Files Not Being Copied to Home Directory

If files aren't being properly copied to your home directory:

1. Check permissions of directories in your home folder
2. Run `reinstall.sh` to perform a clean installation
3. Manually copy key files from the repository to your home directory

## Logs

SENTINEL maintains detailed logs for troubleshooting:

- Installation logs: `~/.sentinel/logs/install.log`
- Autocomplete logs: `~/.sentinel/logs/autocomplete-YYYYMMDD.log`

## Further Assistance

If you continue to experience issues:

1. Check the detailed logs in `~/.sentinel/logs/`
2. Run the verification checks: `bash sentinel_postinstall_check.sh`
3. Refer to documentation in the `README.md` file

## Version Information

- SENTINEL Version: 2.3.0
- Last Updated: 2025-05-16 