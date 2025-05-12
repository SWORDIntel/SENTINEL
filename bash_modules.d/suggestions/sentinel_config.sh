#!/usr/bin/env bash
# SENTINEL Simple Configuration File
# Just edit this file to toggle features on/off

# ----------------------------------
# MODULE ON/OFF SWITCHES
# ----------------------------------
# Set to 1 to enable, 0 to disable

# Core modules
SENTINEL_OBFUSCATE_ENABLED=1     # Obfuscation module
SENTINEL_OSINT_ENABLED=1         # OSINT module  
SENTINEL_ML_ENABLED=1            # Machine learning module
SENTINEL_CYBERSEC_ENABLED=1      # Cybersecurity ML module
SENTINEL_CHAT_ENABLED=1          # Chat module
SENTINEL_GITSTAR_ENABLED=1       # GitHub star analyzer

# Autocomplete features
SENTINEL_FUZZY_ENABLED=1         # Fuzzy command correction
SENTINEL_CHAINS_ENABLED=1        # Command chain predictions  
SENTINEL_SNIPPETS_ENABLED=1      # Command snippets
SENTINEL_PROJECT_ENABLED=1       # Project-specific suggestions

# ----------------------------------
# SYSTEM SETTINGS
# ----------------------------------

# Module system settings
SENTINEL_QUIET_MODULES=1         # 1=Silent mode, 0=Verbose mode
SENTINEL_DEBUG_MODULES=0         # Enable detailed debug output

# Security settings
SENTINEL_SECURE_RM=1             # Use secure deletion
SENTINEL_SECURE_BASH_HISTORY=0   # Clear bash history on logout
SENTINEL_SECURE_SSH_KNOWN_HOSTS=0 # Clear SSH known hosts on logout

# ----------------------------------
# APPLICATION PATHS
# ----------------------------------

# Tool paths
HASHCAT_BIN="/usr/bin/hashcat"             # Path to hashcat binary
HASHCAT_WORDLISTS_DIR="/usr/share/wordlists" # Wordlists directory
OBFUSCATE_OUTPUT_DIR="${HOME}/secure/obfuscated_files" # Output for obfuscated files 