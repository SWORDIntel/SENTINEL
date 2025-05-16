# SENTINEL Autocomplete Modules Summary

## Core Modules

### 0. config_loader.module
- **Description**: Centralized configuration loader for all SENTINEL modules
- **Dependencies**: None (lowest level module, should be loaded first)
- **Features**:
  - Loads centralized configuration from ~/.sentinel/sentinel_config.sh
  - Creates default configuration if it doesn't exist
  - Validates configuration file syntax
  - Provides config editing and reloading capabilities
  - Configuration backup/recovery

### 1. logging.module
- **Description**: Centralized logging system with log rotation and levels
- **Dependencies**: config_loader.module
- **Features**:
  - Log levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)
  - Component-based logging
  - Automatic log rotation
  - Log retention policies
  - Colorized console output

### 2. ble_manager.module
- **Description**: BLE.sh installation, configuration, and management
- **Dependencies**: logging.module
- **Features**:
  - Robust BLE.sh installation
  - Automatic configuration
  - Error detection and recovery
  - Cleanup of orphaned installations
  - Status reporting

### 3. hmac.module
- **Description**: Security module for cryptographic functions
- **Dependencies**: logging.module
- **Features**:
  - HMAC token generation
  - Token verification
  - File/string HMAC generation
  - Secure command execution

## Feature Modules

### 4. snippets.module
- **Description**: Secure command snippet storage and expansion
- **Dependencies**: hmac.module
- **Features**:
  - HMAC-verified snippets
  - Snippet management (add/remove/list)
  - Secure storage
  - Expansion via BLE.sh (when available)

### 5. fuzzy_correction.module
- **Description**: Intelligent command correction for mistyped commands
- **Dependencies**: hmac.module
- **Features**:
  - Levenshtein distance calculations
  - Command correction suggestions
  - Quick fix via `!!:fix`
  - History integration

### 6. command_chains.module
- **Description**: Command prediction based on usage patterns
- **Dependencies**: hmac.module
- **Features**:
  - Command chain analysis
  - Prediction of next likely command
  - Quick execution via `!!:next`
  - Historical pattern recognition

### 7. project_suggestions.module
- **Description**: Context-aware project suggestions
- **Dependencies**: hmac.module
- **Features**:
  - Project type detection
  - Framework-specific suggestions
  - Directory context awareness
  - Multiple project type support

### 8. autocomplete.module
- **Description**: Main orchestration module
- **Dependencies**: All other modules
- **Features**:
  - Module loading and initialization
  - Command handling (@autocomplete commands)
  - Status reporting
  - Troubleshooting tools

## Module Dependency Tree

```
config_loader.module
    |
    └── logging.module
            |
            ├── ble_manager.module
            |
            └── hmac.module
                    |
                    ├── snippets.module
                    |
                    ├── fuzzy_correction.module
                    |
                    ├── command_chains.module
                    |
                    └── project_suggestions.module
    |
autocomplete.module (loads all modules in the correct order)
```

## Loading Order

The modules should be loaded in the following order to ensure dependencies are met:

1. config_loader.module
2. logging.module
3. ble_manager.module
4. hmac.module
5. snippets.module
6. fuzzy_correction.module
7. command_chains.module
8. project_suggestions.module
9. autocomplete.module (main module that loads others)

This ordering ensures that configuration is loaded first, followed by base functionality (logging, BLE.sh management, security), and then feature modules. 