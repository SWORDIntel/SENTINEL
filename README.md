# SENTINEL: Secure ENhanced Terminal INtelligent Layer

![SENTINEL Logo](https://via.placeholder.com/800x200/0d1117/30a14e?text=SENTINEL)

*Unified Documentation & Security Reference*

---

## Table of Contents

- [1. Overview](#1-overview)
- [2. Key Features](#2-key-features)
- [3. Installation & Quick Start](#3-installation--quick-start)
    - [Prerequisites](#prerequisites)
    - [Setup](#setup)
    - [FZF & BLE.sh](#fzf--blesh)
- [4. Configuration](#4-configuration)
    - [Configuration Migration](#configuration-migration)
- [5. Usage](#5-usage)
    - [Chat Assistant](#chat-assistant)
    - [Autocomplete](#autocomplete)
    - [FZF](#fzf)
    - [Context](#context)
    - [Distributed Compilation](#distributed-compilation)
    - [Secure File Operations](#secure-file-operations)
- [6. Machine Learning Capabilities](#6-machine-learning-capabilities)
    - [Command Learning & Suggestions](#command-learning--suggestions)
    - [Interactive Chat Assistant](#interactive-chat-assistant)
    - [OpenVINO Acceleration](#openvino-acceleration)
    - [GitHub Star Analyzer](#github-star-analyzer)
    - [Cybersecurity ML Analyzer](#cybersecurity-ml-analyzer)
    - [Technical Implementation](#technical-implementation)
    - [Customization](#customization)
- [7. Security Considerations](#7-security-considerations)
- [8. Troubleshooting](#8-troubleshooting)
- [9. Extending & Contributing](#9-extending--contributing)
- [10. References](#10-references)
- [11. Changelog](#11-changelog)

---

## 1. Overview

SENTINEL (Secure ENhanced Terminal INtelligent Layer) is a comprehensive, modular, security-focused bash environment enhancement system for cybersecurity professionals, developers, and power users. It provides:

- AI-powered conversational assistant
- Modular autocomplete and command prediction
- Secure snippet and context management
- Fuzzy finding and BLE.sh integration
- Centralized configuration and logging
- Distributed compilation and advanced security tools

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

## 3. Installation & Quick Start

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

## 4. Configuration

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

### Configuration Migration

If upgrading from a previous version:
```bash
bash ~/Documents/GitHub/SENTINEL/bash_modules.d/migrate_config.sh
```

---

## 5. Usage

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

## 6. Machine Learning Capabilities

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

## 7. Security Considerations

- **HMAC Verification**: All critical data (snippets, tokens) are HMAC-signed.
- **Permissions**: All scripts and config files should be `chmod 600` or stricter.
- **Input Validation**: All user input is validated; sensitive data is filtered.
- **Local Processing**: No data leaves your machine by default.
- **PATH Sanitization**: Prevents directory traversal attacks.
- **References**: [CVE-2021-3156](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-3156), [NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)

---

## 8. Troubleshooting

- `@autocomplete status` or `sentinel_config_reload` for diagnostics
- Check logs: `sentinel_show_logs "component" 50`
- Ensure all dependencies are installed and sourced
- Reset context: `rm -rf ~/.sentinel/context/*.json`
- Run `./fix_autocomplete.sh` and `./test_autocomplete.sh` for autocomplete issues
- For Windows, use PowerShell scripts in `Windows Code Fixes` directory

---

## 9. Extending & Contributing

- Add new modules in `bash_modules.d/suggestions/`
- Follow module template and security guidelines
- Submit improvements via Pull Request

---

## 10. References

- [fzf](https://github.com/junegunn/fzf)
- [ble.sh](https://github.com/akinomyoga/ble.sh)
- [NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [CVE Database](https://cve.mitre.org/)
- [SENTINEL Documentation](https://docs.sentinel-framework.org)

---

## 11. Changelog

*(Add versioned changes here)*

---

**Security and technical best practices are enforced throughout. For detailed module-specific usage, see the source code and comments.**
