#!/usr/bin/env bash
# SENTINEL Centralized Configuration File
# Version: 1.1.0
# Description: Central configuration for all SENTINEL modules and components
# This file will be automatically sourced by SENTINEL modules

# ====================================================================================
# CORE SYSTEM CONFIGURATION
# ====================================================================================

# Module system configuration
export SENTINEL_QUIET_MODULES=1         # 1=Silent mode (default), 0=Verbose mode
export SENTINEL_DEBUG_MODULES=0         # 0=Normal mode (default), 1=Debug mode 
export SENTINEL_VERIFY_MODULES=1        # Enable HMAC verification for modules
export SENTINEL_REQUIRE_HMAC=1          # Require HMAC signatures for all modules
export SENTINEL_CHECK_MODULE_CONTENT=0  # Check modules for suspicious patterns
#export SENTINEL_HMAC_KEY="random_string" # Custom HMAC key (uncomment and set for better security)

# Module path configuration
export SENTINEL_MODULES_PATH="${HOME}/.bash_modules.d"  # Path to modules directory
export SENTINEL_VENV_DIR="${HOME}/.venv"               # Python virtual environment location

# ====================================================================================
# SECURITY CONFIGURATION
# ====================================================================================

# Secure deletion and handling
export SENTINEL_SECURE_RM=1             # Secure file deletion (srm)

# Secure logout configuration
export SENTINEL_SECURE_BASH_HISTORY=0   # Clear bash history on logout
export SENTINEL_SECURE_SSH_KNOWN_HOSTS=0 # Clear SSH known hosts on logout
export SENTINEL_SECURE_CLEAN_CACHE=0     # Clean cache directory on logout
export SENTINEL_SECURE_BROWSER_CACHE=0   # Clear browser cache/cookies
export SENTINEL_SECURE_RECENT=0          # Clear recently used files
export SENTINEL_SECURE_VIM_UNDO=0        # Clear vim undo history
export SENTINEL_SECURE_CLIPBOARD=0       # Clear clipboard contents
export SENTINEL_SECURE_CLEAR_SCREEN=1    # Clear screen on exit
#export SENTINEL_SECURE_DIRS="/path/to/sensitive/files:/another/path"  # Additional directories to clean
export SENTINEL_WORKSPACE_TEMP=""        # Temporary workspace directory to clean

# ====================================================================================
# MODULE ENABLE/DISABLE CONFIGURATION
# ====================================================================================

# Feature modules
export SENTINEL_OBFUSCATE_ENABLED=1     # Enable obfuscation module
export SENTINEL_OSINT_ENABLED=1         # Enable OSINT module
export SENTINEL_ML_ENABLED=1            # Enable machine learning module
export SENTINEL_CYBERSEC_ENABLED=1      # Enable cybersecurity ML module
export SENTINEL_CHAT_ENABLED=1          # Enable SENTINEL chat module
export SENTINEL_GITSTAR_ENABLED=1       # Enable GitHub star analyzer

# Module-specific configurations
export OBFUSCATE_OUTPUT_DIR="${HOME}/secure/obfuscated_files"  # Output directory for obfuscated files
export HASHCAT_BIN="/usr/bin/hashcat"                        # Path to hashcat binary
export HASHCAT_WORDLISTS_DIR="/usr/share/wordlists"          # Path to wordlists directory  
export HASHCAT_OUTPUT_DIR="${HOME}/.hashcat/cracked"         # Output directory for cracked hashes

# Distcc Configuration
export DISTCC_HOSTS="localhost"          # Space-separated list of compilation hosts
export CCACHE_SIZE="5G"                  # Maximum size of ccache

# ====================================================================================
# AUTOCOMPLETE SYSTEM CONFIGURATION
# ====================================================================================

# Logging configuration
export SENTINEL_LOG_LEVEL=1             # 0=DEBUG, 1=INFO, 2=WARNING, 3=ERROR, 4=CRITICAL
export SENTINEL_LOG_RETENTION_DAYS=30   # Number of days to keep logs
export SENTINEL_LOG_COLORS_ENABLED=true # Enable colored output in logs
export SENTINEL_LOG_ROTATION_SIZE=1024  # Size in KB before log rotation (1MB default)

# HMAC security configuration
export SENTINEL_SECRET_KEY="default_key" # Will be auto-generated if default

# BLE.sh configuration
export SENTINEL_BLE_AUTO_INSTALL=1      # Auto-install BLE.sh if not found
export SENTINEL_BLE_AUTO_CONFIGURE=1    # Auto-configure BLE.sh options
export DEBUG_BLESH=0                  # Enable BLE.sh debug mode (1=enabled)

# Autocomplete features
export SENTINEL_FUZZY_ENABLED=1         # Enable fuzzy command correction
export SENTINEL_CHAINS_ENABLED=1        # Enable command chain predictions
export SENTINEL_SNIPPETS_ENABLED=1      # Enable command snippets
export SENTINEL_PROJECT_ENABLED=1       # Enable project-specific suggestions

# ====================================================================================
# CUSTOM USER CONFIGURATION
# ====================================================================================

# Add your custom configuration below
# This section will not be modified by SENTINEL updates

# [Custom user settings] 