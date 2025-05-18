# SENTINEL: Secure ENhanced Terminal INtelligent Layer

![SENTINEL Logo](https://via.placeholder.com/800x200/0d1117/30a14e?text=SENTINEL)

*Unified Documentation & Security Reference*

---

## Table of Contents

- [1. Overview](#1-overview)
- [2. Key Features](#2-key-features)
- [3. Performance Optimizations](#3-performance-optimizations)
    - [Configuration Caching](#configuration-caching)
    - [Dependency-Based Module Loading](#dependency-based-module-loading)
    - [Lazy Loading](#lazy-loading)
- [4. Installation & Quick Start](#4-installation--quick-start)
    - [Prerequisites](#prerequisites)
    - [Setup](#setup)
    - [FZF & BLE.sh](#fzf--blesh)
- [5. Configuration](#5-configuration)
    - [Configuration Migration](#configuration-migration)
- [6. Usage](#6-usage)
    - [Chat Assistant](#chat-assistant)
    - [Autocomplete](#autocomplete)
    - [FZF](#fzf)
    - [Context](#context)
    - [Distributed Compilation](#distributed-compilation)
    - [Secure File Operations](#secure-file-operations)
- [7. Machine Learning Capabilities](#7-machine-learning-capabilities)
    - [Command Learning & Suggestions](#command-learning--suggestions)
    - [Interactive Chat Assistant](#interactive-chat-assistant)
    - [OpenVINO Acceleration](#openvino-acceleration)
    - [GitHub Star Analyzer](#github-star-analyzer)
    - [Cybersecurity ML Analyzer](#cybersecurity-ml-analyzer)
    - [Technical Implementation](#technical-implementation)
    - [Customization](#customization)
- [8. Security Considerations](#8-security-considerations)
- [9. Troubleshooting](#9-troubleshooting)
- [10. Extending & Contributing](#10-extending--contributing)
- [11. References](#11-references)
- [12. Changelog](#12-changelog)

---

## 1. Overview

SENTINEL (Secure ENhanced Terminal INtelligent Layer) is a comprehensive, modular, security-focused bash environment enhancement system for cybersecurity professionals, developers, and power users. It provides:

- AI-powered conversational assistant
- Modular autocomplete and command prediction
- Secure snippet and context management
- Fuzzy finding and BLE.sh integration
- Centralized configuration and logging
- Distributed compilation and advanced security tools
- Optimized performance with configuration caching and dependency-based module loading

All modules are designed for robust error handling, security, and privacy, with a focus on terminal-based workflows and Linux-first compatibility.

---

## 2. Key Features

- **Modular Architecture**: Pluggable modules for logging, BLE.sh, HMAC security, snippets, fuzzy correction, command chains, project suggestions, and more.
- **Conversational Shell Assistant**: AI-powered, context-aware chat for shell help and command suggestions.
- **Centralized Configuration**: Single config file for all modules, with validation and self-healing.
- **Enhanced Machine Learning**: Predictive command chains, task detection, natural language understanding, and local LLM integration.
- **Context Management**: Unified context layer for intelligent, context-aware suggestions.
- **FZF Integration**: Secure, interactive fuzzy finding with BLE.sh and SENTINEL enhancements.
- **Distributed Compilation**: Distcc and Ccache integration for fast, distributed builds.
- **Advanced Security**: HMAC verification, cryptographic snippet storage, secure file operations, and strict permission controls.
- **Windows Compatibility**: Automated fixes for cross-platform use.

---

## 3. Performance Optimizations

SENTINEL implements several key performance optimizations to ensure a fast, responsive shell experience even with advanced features enabled.

### Configuration Caching

The configuration caching system significantly reduces startup time by caching parsed configuration files:

- **Centralized Cache Management**: All configuration files are cached in `~/.sentinel/cache/`
- **MD5 Hash Verification**: Integrity checks ensure cached configs match source files
- **Smart Variable Extraction**: Only modified variables are stored in cache files
- **Automatic Cache Invalidation**: Updates source files only when needed
- **Toggle via `SENTINEL_CONFIG_CACHE_ENABLED=1`**

```bash
# View cache statistics
config_cache_stats

# Force refresh all caches
SENTINEL_CONFIG_FORCE_REFRESH=1 source ~/.bashrc
```

### Dependency-Based Module Loading

SENTINEL uses a sophisticated module loading system that resolves dependencies automatically:

- **Automatic Dependency Resolution**: Modules specify dependencies that are loaded first
- **Circular Dependency Detection**: Prevents infinite loading loops
- **Cached Module Paths**: Faster module lookups on subsequent loads
- **Configurable via `SENTINEL_MODULE_CACHE_ENABLED=1`**

For module authors, simply specify dependencies in your module header:

```bash
# Module metadata for dependency resolution
SENTINEL_MODULE_DESCRIPTION="My awesome module"
SENTINEL_MODULE_VERSION="1.0.0"
SENTINEL_MODULE_DEPENDENCIES="logging config_cache"
```

### Lazy Loading

Heavy components are only loaded when first used, not during shell startup:

- Development environments (Pyenv, NVM, RVM, Cargo)
- Bash completion
- Custom tools via the `lazy_load` function

---

## 4. Installation & Quick Start

### Prerequisites

- Bash 4.0+ (Linux-first)
- Python 3.7+
- `fzf`, `ble.sh`, `openssl`
- Python: `pip install markovify numpy [llama-cpp-python]`

### Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/sentinel.git
cd sentinel

# Activate Python venv
source .venv/bin/activate

# Install Python dependencies
pip install markovify numpy

# Run installation script
./install.sh

# Enable modules in SENTINEL
echo "source bash_modules.d/sentchat/init.sh" >> bash_modules
echo "sentchat/sentinel_context" >> ~/.bash_modules
echo "sentchat/sentinel_ml_enhanced" >> ~/.bash_modules

# Source the new configuration
source ~/.bashrc
```

### FZF & BLE.sh

```bash
sudo apt install fzf
# or see fzf.md for other OS instructions

# Ensure BLE.sh is installed and sourced
source ~/.local/share/blesh/ble.sh
```

---

## 5. Configuration

All settings are managed in `~/.sentinel/sentinel_config.sh`.

Edit with:
```bash
sentinel_config
```
Reload with:
```bash
sentinel_config_reload
```

**Key options:**
- Enable/disable modules (e.g., `SENTINEL_FZF_ENABLED=1`)
- Logging level, retention, and color
- Autocomplete, fuzzy, chain, snippet, and project suggestion toggles
- Configuration caching settings:
  - `SENTINEL_CONFIG_CACHE_ENABLED=1` - Master toggle for config caching
  - `SENTINEL_CONFIG_FORCE_REFRESH=0` - Force rebuild all caches
  - `SENTINEL_CONFIG_VERIFY_HASH=1` - Verify cache integrity with MD5
  - `SENTINEL_CONFIG_CACHE_RETENTION_DAYS=30` - Auto-cleanup old caches

**Module system settings:**
  - `SENTINEL_MODULE_DEBUG=0` - Show detailed module loading info
  - `SENTINEL_MODULE_AUTOLOAD=1` - Auto-load required dependencies
  - `SENTINEL_MODULE_CACHE_ENABLED=1` - Enable module path caching
  - `SENTINEL_MODULE_VERIFY=1` - Security verification for modules

You can also use the built-in Toggle TUI to configure these options:
```bash
./sentinel_toggles_tui.py
```

### Configuration Migration

If upgrading from a previous version:
```bash
bash ~/Documents/GitHub/SENTINEL/bash_modules.d/migrate_config.sh
```

---

## 6. Usage

### Chat Assistant

```bash
sentinel chat
```
- `/help`, `/exit`, `/clear`, `/history`, `/context`, `/execute <cmd>`

### Autocomplete

- `@autocomplete` - Help
- `@autocomplete status` - System status
- `@autocomplete fix` - Fix issues
- `@autocomplete reload` - Reload BLE.sh

### FZF

- `Ctrl+R` - History search
- `Ctrl+T` - File search
- `Alt+C` - Directory change

### Context

- `sentinel_context` - Show context
- `sentinel_show_context` - Detailed info
- `sentinel_update_context` - Manual update

### Distributed Compilation

```bash
# View distcc status and configuration
distcc-status
# Configure hosts
distcc_set_hosts localhost 192.168.1.100 192.168.1.101
# Build environment presets
automake-distcc
cmake-distcc
```

### Secure File Operations

```bash
rm sensitive_file.txt             # Multi-pass secure deletion
secure_rm_toggle                  # Toggle secure deletion mode
secure_mkdir ~/secure_project     # Secure directory creation
secure_cp source.txt dest.txt     # Secure copy
```

---

## 7. Machine Learning Capabilities

### Command Learning & Suggestions
- Markov chain models analyze your command history for contextual suggestions.
- All data stays local; privacy-focused.
- Example: `sentinel_ml_stats`, `sentinel_ml_train`

### Interactive Chat Assistant
- Local LLMs (llama-cpp-python) for context-aware shell Q&A.
- Example: `sentinel_chat`, `/help`, `/context`, `/execute <cmd>`

### OpenVINO Acceleration
- Uses Intel OpenVINO for hardware-accelerated inference if available.

### GitHub Star Analyzer
- Downloads and analyzes your starred GitHub repos for tool suggestions.
- Example: `sgtui`, `sentinel_gitstar_fetch`, `sentinel_gitstar_analyze`

### Cybersecurity ML Analyzer
- ML-powered vulnerability detection, pattern-based scanning, LLM-based code review.
- Example: `securitycheck`, `cyberscan`, `cyberupdate`, `cybersecurity --list-tools`

#### Technical Implementation
- Markovify for command learning
- Local LLMs for chat and code review
- Random Forest, Isolation Forest, and deep learning for security
- TF-IDF, K-means for repo analysis

#### Customization
- Edit `~/.sentinel/config.json`, `chat_config.json`, `cybersec/config.json`, `gitstar/config.json` for advanced settings.

---

## 8. Security Considerations

- **HMAC Verification**: All critical data (snippets, tokens) are HMAC-signed.
- **Permissions**: All scripts and config files should be `chmod 600` or stricter.
- **Input Validation**: All user input is validated; sensitive data is filtered.
- **Local Processing**: No data leaves your machine by default.
- **PATH Sanitization**: Prevents directory traversal attacks.
- **References**: [CVE-2021-3156](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-3156), [NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)

---

## 9. Troubleshooting

- `@autocomplete status` or `sentinel_config_reload` for diagnostics
- Check logs: `sentinel_show_logs "component" 50`
- Ensure all dependencies are installed and sourced
- Reset context: `rm -rf ~/.sentinel/context/*.json`
- Run `./fix_autocomplete.sh` and `./test_autocomplete.sh` for autocomplete issues
- For Windows, use PowerShell scripts in `Windows Code Fixes` directory
- Clear configuration cache: `rm -rf ~/.sentinel/cache/config/*.cache`
- Rebuild module cache: `module_manager_init --rebuild-cache`

---

## 10. Extending & Contributing

- Add new modules in `bash_modules.d/suggestions/`
- Follow module template and security guidelines
- Submit improvements via Pull Request

**Creating a new module with dependencies:**

```bash
#!/usr/bin/env bash
# SENTINEL - My Module
# Version: 1.0.0
# Description: Description of what this module does
# Dependencies: logging config_cache  # List modules this depends on

# Module metadata for dependency resolution
SENTINEL_MODULE_DESCRIPTION="My awesome module"
SENTINEL_MODULE_VERSION="1.0.0"
SENTINEL_MODULE_DEPENDENCIES="logging config_cache"

# Prevent double loading
[[ -n "${_MY_MODULE_LOADED}" ]] && return 0
export _MY_MODULE_LOADED=1

# Module code here...
```

To test your module:
```bash
module_enable my_module
```

---

## 11. References

- [fzf](https://github.com/junegunn/fzf)
- [ble.sh](https://github.com/akinomyoga/ble.sh)
- [NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [CVE Database](https://cve.mitre.org/)
- [SENTINEL Documentation](https://docs.sentinel-framework.org)

---

## 12. Changelog

**v2.1.0** - Performance Optimizations
- Added configuration caching for faster startup
- Implemented dependency-based module loading
- Added module path caching
- Added Toggle TUI support for caching options

*(Add older versioned changes here)*

---

**Security and technical best practices are enforced throughout. For detailed module-specific usage, see the source code and comments.**
