# SENTINEL: Secure ENhanced Terminal INtelligent Layer

![SENTINEL Logo](https://via.placeholder.com/800x200/0d1117/30a14e?text=SENTINEL)

## Overview

SENTINEL (Secure ENhanced Terminal INtelligent Layer) is a comprehensive bash environment enhancement system designed for cybersecurity professionals, developers, and power users. This system provides a modular, secure, and feature-rich command-line experience with emphasis on security, productivity, and distributed computing capabilities.

**Version:** 2.1.0  
**Author:** John  
**Last Updated:** 2024-03-21  

## Key Features

- **Modular Architecture** with smart dependency management
- **Enhanced Security Features** including secure file deletion and runtime protection
- **Distributed Compilation** support via Distcc and Ccache integration
- **Automatic Security Cleanup** on logout to protect sensitive data
- **Advanced Text Processing** utilities with smart formatting
- **Specialized Security Tools** for cybersecurity workflows (e.g., hashcat integration)
- **Intelligent Prompt** with git status, exit codes, and job count indicators
- **Path Sanitization** to prevent directory traversal attacks
- **Enhanced Bash Completion** for common tools and custom commands

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/sentinel.git

# Navigate to directory
cd sentinel

# Run installation script
./install.sh

# Source the new configuration
source ~/.bashrc

# View available commands
sentinel_help
```

## Core Components

### Distributed Compilation (New!)

SENTINEL now includes integrated support for distributed compilation using Distcc and Ccache:

```bash
# View distcc status and configuration
distcc-status

# Configure compilation hosts
distcc_set_hosts localhost 192.168.1.100 192.168.1.101

# Set up build environment
automake-distcc    # For GNU Automake projects
cmake-distcc       # For CMake projects

# Monitor compilation
distcc-monitor text    # Text-based monitoring
distcc-monitor gui     # GUI monitoring (if available)
```

Key features:
- Automatic Ccache integration for faster rebuilds
- Smart host detection and configuration
- Build environment presets for common build systems
- Integrated monitoring tools
- Configurable compilation slots per host

### Secure File Operations

SENTINEL replaces standard file operations with secure alternatives:

```bash
# Secure file deletion (enabled by default)
rm sensitive_file.txt             # Multi-pass secure deletion
secure_rm_toggle                  # Toggle secure deletion mode

# Secure directory operations
secure_mkdir ~/secure_project     # Create directory with secure permissions
secure_cp source.txt dest.txt     # Copy with permission preservation

# View secure operation status
secure-status
```

### Automated Security

Comprehensive security automation:

```bash
# Configure secure logout behavior
secure-logout-config

# Add custom cleanup directories
secure-logout-add-dir ~/projects/sensitive

# Manual security cleanup
secure_clean all                  # Clean everything
secure_clean browser              # Clean browser data only
secure_clean workspace            # Clean workspace only
```

### Advanced Hash Operations

Enhanced cryptographic tools:

```bash
# Automatic hash detection
hashdetect '$2a$10$...'

# Smart hash cracking
hashcrack_smart hash.txt         # Auto-detects hash type and strategy
hashcrack_targeted hash.txt      # Optimized for specific hash types
hashcrack_distributed hash.txt   # Uses distributed resources

# Resource management
wordlists --update              # Update wordlist collection
rules --stats                   # View rule effectiveness stats
```

## Module System

SENTINEL's modular architecture allows easy extension:

### Core Modules

- **security**: Enhanced security tools and monitoring
- **distcc**: Distributed compilation management (New!)
- **hashcat**: Advanced password cracking and analysis
- **secure_logout**: Automated security cleanup
- **workspace**: Project space management
- **network**: Network security tools

### Module Management

```bash
# List and manage modules
module_list                    # Show all modules
module_enable distcc          # Enable distributed compilation
module_disable network        # Disable network tools
module_info security         # View module details

# Create custom modules
module_create custom_tools    # Create new module
module_edit custom_tools      # Edit existing module
```

## Security Features

### Runtime Protection

- **PATH Sanitization**: Prevents directory traversal attacks
- **Environment Hardening**: Secure environment variable handling
- **Memory Protection**: Automatic memory wiping for sensitive data
- **Process Isolation**: Sandboxed execution for untrusted code

### Secure Development

- **Build Environment**: Isolated compilation spaces
- **Dependency Scanning**: Automatic vulnerability checking
- **Code Analysis**: Integration with static analysis tools
- **Secure Defaults**: Hardened configuration templates

## Configuration

### Directory Structure

```
~/.sentinel/
├── config/                    # Configuration files
├── modules/                   # Module directory
├── secure/                    # Secure storage
├── cache/                     # Cache directory
└── logs/                     # Audit logs
```

### Custom Configuration

- **~/.bashrc.precustom**: Pre-load configuration
- **~/.bashrc.postcustom**: Post-load overrides
- **~/.bash_modules**: Module activation control
- **~/.sentinel/config/**: Module-specific settings

## Troubleshooting

### Common Issues

1. **Module Loading Failures**
   ```bash
   # Check module permissions
   sentinel-check permissions

   # Verify module dependencies
   sentinel-check dependencies

   # Test module configuration
   sentinel-test module_name
   ```

2. **Performance Issues**
   ```bash
   # Profile startup time
   sentinel-profile startup

   # Check resource usage
   sentinel-status resources

   # Optimize configuration
   sentinel-optimize
   ```

### Logging and Debugging

```bash
# Enable debug logging
export SENTINEL_DEBUG=1

# View logs
sentinel-logs view

# Export diagnostic information
sentinel-diagnostic export
```

## Credits

SENTINEL is based on the original bashrc work by Jason Thistlethwaite (2013), enhanced by Durandal, and significantly modernized for security and productivity by John (Epimetheus@swordintelligence.airforce).

*Note: Not affiliated with the USAF*

## License

Licensed under GNU GPL v2 or later. See LICENSE file for details.

---

For more information, visit the [SENTINEL Documentation](https://docs.sentinel-framework.org)

## Conversational Assistant

SENTINEL now includes a powerful conversational assistant that helps with shell commands, system administration tasks, and general Linux knowledge. This feature leverages local LLMs with the llama-cpp-python library.

### Features

- Interactive chat interface with context-aware responses
- Understands your current directory, recent commands, and environment
- Securely executes commands with HMAC verification
- Local execution - your data stays on your machine
- Fully customizable with different models

### Usage

```bash
# Start interactive chat session
sentinel_chat

# Ask a direct question
sentinel_chat "How do I grep JSON logs for errors?"

# Install dependencies if needed
sentinel_chat_install_deps

# Check status of the chat system
sentinel_chat_status
```

### Available Commands in Chat Mode

- `/help` - Show available commands
- `/exit` or `/quit` - Exit the chat
- `/clear` - Clear the current conversation
- `/save` - Save the current conversation
- `/context` - Show current shell context
- `/execute <command>` - Securely execute a shell command

## Windows Compatibility Features

SENTINEL now includes comprehensive Windows compatibility features that make it easier to work with bash scripts in a Windows environment.

### Automated Windows Fixes

A suite of PowerShell scripts has been added to automatically fix common issues that arise when using bash scripts on Windows:

- **Line Ending Conversion**: Automatically converts Windows-style CRLF line endings to Unix-style LF
- **Shebang Correction**: Ensures proper shebang lines for cross-platform compatibility
- **Function Syntax Fixing**: Corrects bash function syntax to work properly in both environments
- **File Permission Handling**: Attempts to set executable permissions where possible

To use these fixes:

1. Navigate to the `Windows Code Fixes` directory
2. Run `.\run_fixes.ps1` in PowerShell
3. The script will automatically detect and fix all bash-related files

For more details, see the [Windows Code Fixes README](Windows%20Code%20Fixes/README.md).

## Machine Learning Features

SENTINEL now incorporates machine learning capabilities to enhance your shell experience:

### Conversational Assistant

The `sentinel chat` command provides an LLM-backed REPL for context-aware answers to shell queries:

- Ask natural language questions about shell commands
- Get contextual help based on your current environment
- Receive command suggestions with explanations

### Command Auto-Learning

SENTINEL uses a Markov model to learn from your command history and provide intelligent suggestions:

- Automatically learns from commands you use frequently
- Suggests relevant commands based on your usage patterns
- Adapts to your specific workflow over time

To access this feature, use the `sentinel_suggest` command followed by the beginning of a command you're trying to remember.

### GitHub Star Analyzer

* Automatically download READMEs from your GitHub starred repositories
* Use machine learning to categorize repositories by purpose and functionality
* Intelligent search and suggestions for finding the right tool for specific tasks
* LLM-powered analysis for detailed understanding of repository features

### Cybersecurity ML Analyzer (New!)

SENTINEL now includes an advanced cybersecurity machine learning module that helps identify security vulnerabilities in code:

* **ML-powered vulnerability detection** that identifies potential security issues
* **Multi-language support** covering Python, JavaScript, PHP, Java, C/C++, and more
* **LLM-based code analysis** for advanced security review capabilities
* **Up-to-date vulnerability database** synchronized with NVD and other sources
* **Clustered findings** to identify patterns across security issues
* **Mitigation recommendations** to help fix identified vulnerabilities

```bash
# Quick security scan of current directory
securitycheck

# Full scan with options
cyberscan ~/my-project --recursive --include=py,js,php

# Update vulnerability database
cyberupdate

# Train custom security models
cybertrain

# Generate synthetic security training data
cyberdata --samples 200
```

For detailed documentation, see [Cybersecurity ML Documentation](contrib/README_CYBERSEC_ML.md) and [Machine Learning Capabilities](MACHINE_LEARNING.md).

### Installation of ML Features

To install the ML components:

```bash
# Activate your virtual environment (if using one)
source .venv/bin/activate

# Install required dependencies
pip install markovify numpy

# Enable the suggestion module
echo "source bash_modules.d/suggestions" >> ~/.bashrc

# Install cybersecurity ML dependencies
cyberinstall
```

## Key Components

- **bash_aliases**: Common command shortcuts and aliases
- **bash_functions**: Useful shell functions for everyday tasks
- **bash_modules**: Modular components that can be enabled/disabled
- **Windows Code Fixes**: Tools to ensure cross-platform compatibility

For detailed documentation on each component, see the individual README files in each directory.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
