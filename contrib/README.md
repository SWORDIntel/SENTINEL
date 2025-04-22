# SENTINEL: Enhanced Bash Environment

![SENTINEL Logo](https://via.placeholder.com/800x200/0d1117/30a14e?text=SENTINEL)

## Overview

SENTINEL (Secure ENhanced Terminal INtelligent Layer) is a comprehensive bash environment enhancement system designed for cybersecurity professionals and power users. This system provides a modular, secure, and feature-rich command-line experience with emphasis on security, productivity, and convenience.

**Version:** 2.0.0  
**Author:** John  
**Last Updates:** 2023-08-14  

## Key Features

- **Modular architecture** with dependency management
- **Enhanced security features** including secure file deletion
- **Automatic cleanup** on logout to protect sensitive data
- **Advanced text formatting** utilities
- **Specialized tools** for cybersecurity workflows (e.g., hashcat integration)
- **Intelligent prompt** with git status, exit codes, and job count indicators
- **Path sanitization** to prevent directory traversal attacks
- **Improved bash completion** for common tools

## Installation

Clone the repository and run the installation script:

```bash
git clone https://github.com/yourusername/sentinel.git
cd sentinel
./install.sh
```

Or, for manual installation:

```bash
cp -r sentinel/bash_modules.d ~/.bash_modules.d
cp sentinel/bash_modules ~/.bash_modules
cp sentinel/bash_functions ~/.bash_functions
cp sentinel/bash_aliases ~/.bash_aliases
cp sentinel/bashrc ~/.bashrc
# Ensure executable permissions
chmod +x ~/.bash_modules.d/*.sh ~/.bash_modules.d/*.module
```

## Core Components

### Secure RM

SENTINEL replaces the standard `rm` command with a secure alternative that prevents file recovery through multiple overwrites.

- **Usage**: Use `rm` as normal; files will be securely deleted by default
- **Toggle**: Use `secure_rm_toggle` to enable/disable secure deletion
- **Help**: Type `secure_rm_help` for more information

```bash
# Example usage
rm sensitive_file.txt             # Securely deletes the file
rm -rf sensitive_directory/       # Securely deletes all files in directory

# Disable secure deletion temporarily
secure_rm_toggle                  # Toggle between secure and standard rm
```

### Secure Logout

SENTINEL automatically cleans up sensitive data when you log out of your terminal session.

- **Configuration**: Checked via `secure-logout-config`
- **Customization**: Change settings with `secure-logout-set`
- **Manual Cleanup**: Use `secure_clean` to trigger cleanup manually
- **Add Directories**: Use `secure-logout-add-dir` to add directories to cleanup list

```bash
# View current configuration
secure-logout-config

# Change settings
secure-logout-set SENTINEL_SECURE_BROWSER_CACHE 1

# Add a directory to cleanup
secure-logout-add-dir ~/projects/sensitive-data

# Manually clean all data
secure_clean all

# Clean specific data type
secure_clean browser
```

Items cleaned on logout:
- Bash history
- Temporary files
- Browser cache/cookies (optional)
- Recently used files list
- Vim undo history
- Clipboard contents
- Custom directories

### Hashcat Module

Enhanced hashcat integration with automatic hash type detection and optimized cracking workflows.

- **Hash Detection**: `hashdetect` automatically identifies hash types
- **Wordlist Management**: `wordlists` and `rules` commands to manage resources
- **Targeted Cracking**: `hashcrack_targeted` for efficient multi-phase cracking
- **Thorough Cracking**: `hashcrack_thorough` for comprehensive multi-vector approaches

```bash
# Detect hash type
hashdetect '5f4dcc3b5aa765d61d8327deb882cf99'

# List available resources
wordlists
rules

# Crack a hash with auto-detection
hashcrack '5f4dcc3b5aa765d61d8327deb882cf99'

# Use targeted workflow
hashcrack_targeted hashes.txt

# Download a new wordlist
download_wordlist https://example.com/wordlist.txt
```

### Text Formatting Utilities

Enhanced text processing capabilities for command-line operations.

- **CSV Processing**: `csvview`, `csvsmart`, `csvcolor`
- **Text Transformations**: `upper`, `lower`, `titlecase`
- **JSON/XML Formatting**: `jsonpp`, `xmlpp`
- **Text Filtering**: `nocolor`, `noempty`, `uniqo`
- **Data Extraction**: Extract IPs, emails, URLs, and cryptographic hashes

```bash
# Format CSV with proper column alignment
cat data.csv | csvview

# Remove color codes from output 
command_with_color | nocolor

# Extract all emails from a file
cat document.txt | extractemail

# Pretty-print JSON with syntax highlighting
cat data.json | jsonpp

# Count word frequency in a document
cat document.txt | wordfreq
```

## Module System

SENTINEL features a robust module system for extending functionality.

### Module Management

- **List Modules**: `module_list`
- **Enable Module**: `module_enable <module_name>`
- **Disable Module**: `module_disable <module_name>`
- **Module Info**: `module_info <module_name>`
- **Create Module**: `module_create <module_name>`

```bash
# List all available modules
module_list

# Enable a module
module_enable security

# Get detailed information
module_info hashcat

# Create a new module
module_create custom_tools
```

### Available Modules

- **security**: Enhanced security tools and monitoring
- **productivity**: Task management and time tracking
- **hashcat**: Password cracking and hash analysis
- **secure_logout**: Configuration for secure logout behavior
- **secure_delete**: File deletion with secure overwriting

## Additional Features

### Enhanced Bash Completion

SENTINEL includes improved bash completion scripts for several tools:

- **nmap**: Enhanced completion with script suggestions and advanced options
- **hashcat**: Automatic completion of hash types and wordlists
- **others**: Various command-specific enhancements

### Intelligent Prompt

The SENTINEL prompt provides valuable information at a glance:

- Current git branch with status indicator
- Exit code of previous command
- Number of background jobs
- SSH/sudo security indicators
- Timestamps for command execution

### Virtual Environment Management

Automatically manages Python virtual environments:

- `venvon` / `venvoff`: Toggle automatic venv activation
- Enhanced `pip` and `pip3` commands that detect when you need a virtual environment

## Security Considerations

SENTINEL includes multiple security-focused features:

- **PATH sanitization** to prevent directory traversal attacks
- **Secure history** configuration to prevent storing sensitive commands
- **File permission checks** for critical configuration files
- **Secure deletion** of sensitive data using multi-pass overwriting

Note: For SSDs and some filesystems, secure deletion may not be completely effective due to wear-leveling and journaling. Full-disk encryption is recommended for maximum security.

## Configuration

SENTINEL can be configured through several methods:

- **~/.bashrc.precustom**: Configure settings before main bashrc loads
- **~/.bashrc.postcustom**: Override any settings after bashrc loads
- **~/.bash_modules**: Control which modules are loaded at startup
- **Module-specific config**: Each module may have its own configuration options

## Troubleshooting

### Common Issues

1. **Module not loading:**
   - Check permissions: `chmod +x ~/.bash_modules.d/module_name.sh` or `chmod +x ~/.bash_modules.d/module_name.module`
   - Ensure it's in modules list: `cat ~/.bash_modules`

2. **Secure deletion is slow:**
   - Toggle off temporarily: `secure_rm_toggle`
   - For large files, consider using standard deletion with full-disk encryption

3. **Command not found after installation:**
   - Source your bashrc: `source ~/.bashrc`
   - Check if module is enabled: `module_list`

### Getting Help

For each module, there is typically a help command available:
- `hchelp`: Help for hashcat module
- `secure_rm_help`: Help for secure deletion
- `secure-logout-config`: Shows configuration for secure logout

## Credits

SENTINEL is based on the original bashrc work by Jason Thistlethwaite (2013), with significant enhancements for modern security and productivity use cases.

## License

Licensed under GNU GPL v2 or later.

---

For more information, visit [GitHub Repository](https://github.com/yourusername/sentinel).