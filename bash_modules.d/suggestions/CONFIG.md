# SENTINEL Centralized Configuration System

## Overview

The SENTINEL centralized configuration system provides a single point of configuration for all SENTINEL modules and components. It replaces the scattered configuration settings previously found in various files like `bashrc.postcustom` and individual module files.

## Configuration Location

The main configuration file is located at:
```
~/.sentinel/sentinel_config.sh
```

This file contains all configuration settings for SENTINEL modules in a well-organized format.

## Key Features

- **Centralized Management**: All settings in one place
- **Self-documenting**: Each option includes description comments
- **Categorized**: Settings organized by functional area
- **Error-resilient**: Validates syntax and recovers from errors
- **Self-healing**: Creates default configuration if missing
- **Custom Settings**: Preserved during updates

## Configuration Sections

The configuration file is organized into the following sections:

### 1. Core System Configuration

Settings for the module system itself, including debugging, verification, and security options.

```bash
# Module system configuration
export SENTINEL_QUIET_MODULES=1         # 1=Silent mode (default), 0=Verbose mode
export SENTINEL_DEBUG_MODULES=0         # 0=Normal mode (default), 1=Debug mode 
export SENTINEL_VERIFY_MODULES=1        # Enable HMAC verification for modules
export SENTINEL_REQUIRE_HMAC=1          # Require HMAC signatures for all modules
export SENTINEL_CHECK_MODULE_CONTENT=0  # Check modules for suspicious patterns
```

### 2. Module Enable/Disable Configuration

Toggles for enabling or disabling entire SENTINEL modules.

```bash
# Feature modules
export SENTINEL_OBFUSCATE_ENABLED=1     # Enable obfuscation module
export SENTINEL_OSINT_ENABLED=1         # Enable OSINT module
export SENTINEL_ML_ENABLED=1            # Enable machine learning module
export SENTINEL_CYBERSEC_ENABLED=1      # Enable cybersecurity ML module
export SENTINEL_CHAT_ENABLED=1          # Enable SENTINEL chat module
export SENTINEL_GITSTAR_ENABLED=1       # Enable GitHub star analyzer
```

### 3. Autocomplete System Configuration

Settings specific to the autocomplete system, including logging, security, and feature toggles.

```bash
# Logging configuration
export SENTINEL_LOG_LEVEL=1             # 0=DEBUG, 1=INFO, 2=WARNING, 3=ERROR, 4=CRITICAL
export SENTINEL_LOG_RETENTION_DAYS=30   # Number of days to keep logs
export SENTINEL_LOG_COLORS_ENABLED=true # Enable colored output in logs

# Autocomplete features
export SENTINEL_FUZZY_ENABLED=1         # Enable fuzzy command correction
export SENTINEL_CHAINS_ENABLED=1        # Enable command chain predictions
export SENTINEL_SNIPPETS_ENABLED=1      # Enable command snippets
export SENTINEL_PROJECT_ENABLED=1       # Enable project-specific suggestions
```

### 4. Custom User Configuration

Reserved area for user-specific settings that won't be overwritten during updates.

## Managing Configuration

### Editing Configuration

Use the built-in `sentinel_config` command to edit the configuration file:

```bash
sentinel_config
```

This opens the configuration file in your default editor (nano or vi).

### Reloading Configuration

After modifying the configuration, you can reload it without restarting your shell:

```bash
sentinel_config_reload
```

## Migration from Previous Configuration

If you're upgrading from an older SENTINEL installation, use the migration script to move your existing settings to the new centralized configuration:

```bash
~/Documents/GitHub/SENTINEL/bash_modules.d/suggestions/migrate_config.sh
```

The migration script:
1. Backs up existing configuration files
2. Creates the new centralized configuration file if it doesn't exist
3. Extracts and migrates settings from `bashrc.postcustom`
4. Creates an update script to modify `bashrc.postcustom`

## Implementation Details

### Configuration Loader Module

The `config_loader.module` is responsible for:

- Loading the configuration file
- Creating default configuration if it doesn't exist
- Validating configuration file syntax
- Providing functions for reloading and editing configuration

### Module Load Order

For proper operation, modules should be loaded in this order:

1. `config_loader.module` - Loads centralized configuration
2. Other modules - Use the loaded configuration

### Default Fallbacks

If `config_loader.module` isn't loaded first, modules will fall back to their default settings. 