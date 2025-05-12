# SENTINEL Configuration System Reference

## Overview

This document provides a comprehensive reference for all configuration options available in the SENTINEL system. The centralized configuration system provides a single point of configuration for all SENTINEL modules and components, replacing scattered settings previously found in various files.

## Configuration Location

The main configuration file is located at:
```
~/.sentinel/sentinel_config.sh
```

## Managing Configuration

### View or Edit Configuration

```bash
# Edit the configuration file in your default editor
sentinel_config

# Or use the direct command
nano ~/.sentinel/sentinel_config.sh
```

### Reload Configuration

After modifying the configuration, reload without restarting your shell:

```bash
sentinel_config_reload
```

## Configuration Categories

### Core System Configuration

These settings control the core behavior of the SENTINEL module system.

| Variable | Default | Description |
|----------|---------|-------------|
| `SENTINEL_QUIET_MODULES` | `1` | Silent mode (1) or verbose mode (0) |
| `SENTINEL_DEBUG_MODULES` | `0` | Enable detailed debug output |
| `SENTINEL_VERIFY_MODULES` | `1` | Enable HMAC verification for modules |
| `SENTINEL_REQUIRE_HMAC` | `1` | Require HMAC signatures for modules |
| `SENTINEL_CHECK_MODULE_CONTENT` | `0` | Check modules for suspicious patterns |
| `SENTINEL_HMAC_KEY` | *(unset)* | Custom HMAC key for better security |
| `SENTINEL_MODULES_PATH` | `~/.bash_modules.d` | Path to modules directory |
| `SENTINEL_VENV_DIR` | `~/.venv` | Python virtual environment location |

### Security Configuration

These settings control the security behavior of SENTINEL, particularly around secure deletion and logout procedures.

| Variable | Default | Description |
|----------|---------|-------------|
| `SENTINEL_SECURE_RM` | `1` | Use secure deletion with the `srm` command |
| `SENTINEL_SECURE_BASH_HISTORY` | `0` | Clear bash history on logout |
| `SENTINEL_SECURE_SSH_KNOWN_HOSTS` | `0` | Clear SSH known hosts on logout |
| `SENTINEL_SECURE_CLEAN_CACHE` | `0` | Clean cache directory on logout |
| `SENTINEL_SECURE_BROWSER_CACHE` | `0` | Clear browser cache/cookies on logout |
| `SENTINEL_SECURE_RECENT` | `0` | Clear recently used files on logout |
| `SENTINEL_SECURE_VIM_UNDO` | `0` | Clear Vim undo history on logout |
| `SENTINEL_SECURE_CLIPBOARD` | `0` | Clear clipboard contents on logout |
| `SENTINEL_SECURE_CLEAR_SCREEN` | `1` | Clear screen on exit |
| `SENTINEL_SECURE_DIRS` | *(unset)* | Additional directories to clean (colon-separated) |
| `SENTINEL_WORKSPACE_TEMP` | *(unset)* | Temporary workspace directory to clean |

### Module Enable/Disable Configuration

These settings control which feature modules are active.

| Variable | Default | Description |
|----------|---------|-------------|
| `SENTINEL_OBFUSCATE_ENABLED` | `1` | Enable obfuscation module |
| `SENTINEL_OSINT_ENABLED` | `1` | Enable OSINT (Open Source Intelligence) module |
| `SENTINEL_ML_ENABLED` | `1` | Enable machine learning module |
| `SENTINEL_CYBERSEC_ENABLED` | `1` | Enable cybersecurity ML module |
| `SENTINEL_CHAT_ENABLED` | `1` | Enable SENTINEL chat module |
| `SENTINEL_GITSTAR_ENABLED` | `1` | Enable GitHub star analyzer |

### Module-Specific Configurations

These settings control specific module behaviors.

| Variable | Default | Description |
|----------|---------|-------------|
| `OBFUSCATE_OUTPUT_DIR` | `~/secure/obfuscated_files` | Output directory for obfuscated files |
| `HASHCAT_BIN` | `/usr/bin/hashcat` | Path to hashcat binary |
| `HASHCAT_WORDLISTS_DIR` | `/usr/share/wordlists` | Path to wordlists directory |
| `HASHCAT_OUTPUT_DIR` | `~/.hashcat/cracked` | Output directory for cracked hashes |
| `DISTCC_HOSTS` | `localhost` | Space-separated list of compilation hosts |
| `CCACHE_SIZE` | `5G` | Maximum size of compiler cache |

### Autocomplete System Configuration

These settings control the behavior of the advanced autocomplete system.

| Variable | Default | Description |
|----------|---------|-------------|
| `SENTINEL_LOG_LEVEL` | `1` | Logging level (0=DEBUG, 1=INFO, 2=WARNING, 3=ERROR, 4=CRITICAL) |
| `SENTINEL_LOG_RETENTION_DAYS` | `30` | Number of days to keep logs |
| `SENTINEL_LOG_COLORS_ENABLED` | `true` | Enable colored output in logs |
| `SENTINEL_LOG_ROTATION_SIZE` | `1024` | Size in KB before log rotation (1MB default) |
| `SENTINEL_SECRET_KEY` | `default_key` | HMAC security key (auto-generated if default) |
| `SENTINEL_BLE_AUTO_INSTALL` | `1` | Auto-install BLE.sh if not found |
| `SENTINEL_BLE_AUTO_CONFIGURE` | `1` | Auto-configure BLE.sh options |
| `SENTINEL_FUZZY_ENABLED` | `1` | Enable fuzzy command correction |
| `SENTINEL_CHAINS_ENABLED` | `1` | Enable command chain predictions |
| `SENTINEL_SNIPPETS_ENABLED` | `1` | Enable command snippets |
| `SENTINEL_PROJECT_ENABLED` | `1` | Enable project-specific suggestions |

## Examples

### Enabling/Disabling Features

```bash
# Edit configuration
sentinel_config

# Disable the OSINT module
export SENTINEL_OSINT_ENABLED=0

# Enable verbose mode
export SENTINEL_QUIET_MODULES=0

# Save and reload
sentinel_config_reload
```

### Configure Security Options

```bash
# Enhance security for sensitive work
export SENTINEL_SECURE_BASH_HISTORY=1
export SENTINEL_SECURE_SSH_KNOWN_HOSTS=1
export SENTINEL_SECURE_CLEAN_CACHE=1
export SENTINEL_SECURE_DIRS="$HOME/sensitive-project:$HOME/client-data"
```

### Adjusting Autocomplete Behavior

```bash
# Use more aggressive logging
export SENTINEL_LOG_LEVEL=0  # DEBUG level
export SENTINEL_LOG_RETENTION_DAYS=7  # Keep logs for a week

# Disable features you don't need
export SENTINEL_CHAINS_ENABLED=0  # Disable command chain suggestions
```

## Troubleshooting

If you encounter issues with your configuration:

1. Check your syntax with: `bash -n ~/.sentinel/sentinel_config.sh`
2. Look for errors in the log: `cat ~/.sentinel/logs/config-*.log`
3. Reset to defaults by removing the file and letting it re-create: `rm ~/.sentinel/sentinel_config.sh`
4. Run the migration script to re-extract settings: `~/Documents/GitHub/SENTINEL/bash_modules.d/migrate_config.sh`

## Advanced: Custom Configuration Variables

You can add your own configuration variables in the "Custom User Configuration" section. Follow these guidelines:

1. Use the `SENTINEL_` prefix to maintain consistency
2. Add descriptive comments for each setting
3. Group related settings together
4. Consider using the format: `export SENTINEL_CATEGORY_NAME=value`

Example:
```bash
# Custom project paths
export SENTINEL_PROJECT_WEB="$HOME/www"
export SENTINEL_PROJECT_SCRIPTS="$HOME/scripts"
``` 