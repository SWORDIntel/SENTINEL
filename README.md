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
chmod +x ~/.bash_modules.d/*.sh
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
   - Check permissions: `chmod +x ~/.bash_modules.d/module_name.sh`
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


Key Additions for Distcc Integration
I've made the following enhancements to support the Distcc module in the installation script:

New Function for Module Installation:
Added install_module function that handles module creation and activation
Additional Directories:
Added ~/.distcc directory for Distcc configuration
Added ~/.ccache directory for Ccache storage
Added ~/build_workspace for compilation projects
Distcc Module Installation:
Created the complete Distcc module inline (with escaped quotes for bash)
Installed the module using the new install_module function
Added it to enabled modules automatically
Environment Configuration:
Added Distcc-specific environment variables to .bashrc.postcustom:
DISTCC_HOSTS set to "localhost" by default
DISTCC_DIR and CCACHE_DIR pointing to their respective directories
CCACHE_SIZE set to 5GB by default
Added Distcc/Ccache paths to PATH
Help Documentation:
Updated the sentinel_help function to include Distcc commands
Added a section specifically for "Build Environment" tools
Added reference to the build workspace directory

# SENTINEL Module System Enhancement Report

## User: John
## Date: 2023-11-25 10:15:04 UTC

### Progress Summary
✅ Analyzed existing SENTINEL module system
✅ Identified key improvement opportunities
✅ Developed enhanced SENTINEL 3.0 implementation
✅ Created module template format
✅ Documented implementation guide

### Key Enhancements
- Combined best features from both systems
- Added integrity verification with SHA256 hashing
- Improved dependency resolution with cycle detection
- Added performance metrics and diagnostics
- Enhanced logging system
- Implemented better error handling
- Added backward compatibility

### Next Steps
1. Migrate existing modules to new format
2. Update module hashes for integrity verification
3. Test dependency resolution with complex module trees
4. Consider adding a module repository feature
5. Implement automated testing for modules

### Codename: NIGHTHAWK
## Credits

SENTINEL is based on the original bashrc work by Jason Thistlethwaite (2013),added on to significantly by Durandal calling it bashrc with significant enhancements for modern security and productivity use cases by myself John aka Epimetheus@swordintelligence.airforce

nb:not with the USAF

## License

Licensed under GNU GPL v2 or later.

---

# SENTINEL Module System Enhancement Report

## User: John
## Date: 2023-11-25 10:15:04 UTC

### Progress Summary
✅ Analyzed existing SENTINEL module system

✅ Identified key improvement opportunities

✅ Developed enhanced SENTINEL 3.0 implementation

✅ Created module template format

✅ Documented implementation guide

### Key Enhancements
- Combined best features from both systems
- Added integrity verification with SHA256 hashing
- Improved dependency resolution with cycle detection
- Added performance metrics and diagnostics
- Enhanced logging system
- Implemented better error handling
- Added backward compatibility

### Next Steps
1. Migrate existing modules to new format
2. Update module hashes for integrity verification

# Expanded Bash Functions - Documentation

This document provides an overview of the expanded bash functions file, explaining the new functions and their usage.

## Overview

The expanded bash functions file has been organized into the following sections:

1. **Utility Functions** - General-purpose helper functions
2. **Virtual Environment Management** - Python virtual environment tools
3. **System Administration** - System maintenance and monitoring
4. **Secure File Operations** - Security-focused file handling
5. **File and Directory Management** - File manipulation utilities
6. **Development Tools** - Functions for software development
7. **Network Tools** - Network diagnostics and information
8. **Productivity Tools** - Note-taking, todo lists, and timers

## Installation

To use these functions, add the content to your `~/.bash_functions` file or source it from your `.bashrc`:

```bash
# Add to your .bashrc file
if [ -f ~/expanded_bash_functions.sh ]; then
    . ~/expanded_bash_functions.sh
fi
```

## New Functions Overview

### Utility Functions

- **progress_bar** - Display a percentage-based progress bar
  ```bash
  progress_bar 50 # Shows a 50% complete progress bar
  ```

- **countdown** - Display a countdown timer
  ```bash
  countdown 10 "Ready to go!" # 10-second countdown
  ```

- **remove_from_path** - Remove a directory from PATH
  ```bash
  remove_from_path /usr/local/bin # Remove specific directory
  remove_from_path # Interactive mode
  ```

### Virtual Environment Management

- **mkvenv** - Create and activate a Python virtual environment
  ```bash
  mkvenv # Create .venv in current directory
  mkvenv myproject 3.9 # Create with specific Python version
  ```

- **lsvenv** - List all virtual environments in current directory
  ```bash
  lsvenv # Default depth of 2
  lsvenv 3 # Search with depth of 3
  ```

### System Administration

- **sysupdate** - Update system packages across different distributions
  ```bash
  sysupdate # Detect distribution and update accordingly
  ```

- **sysmonitor** - Monitor system resources
  ```bash
  sysmonitor # Default 5-second interval, 10 iterations
  sysmonitor 2 20 # 2-second interval, 20 iterations
  ```

- **killzombies** - Find and kill zombie processes
  ```bash
  killzombies # Find and terminate zombie processes
  ```

- **killbyname** - Find and kill processes by name
  ```bash
  killbyname firefox # Kill Firefox processes
  killbyname chrome 1 # Force kill Chrome processes
  ```

### Secure File Operations

- **encrypt_file** - Securely encrypt a file with OpenSSL
  ```bash
  encrypt_file secret.txt # Creates secret.txt.enc
  encrypt_file secret.txt encrypted.dat # Custom output name
  ```

- **decrypt_file** - Decrypt an encrypted file
  ```bash
  decrypt_file secret.txt.enc # Creates secret.txt
  decrypt_file secret.txt.enc decrypted.txt # Custom output name
  ```

### File and Directory Management

- **backup** - Create a timestamped backup of a file or directory
  ```bash
  backup important.txt # Backup to ~/backups
  backup project/ /mnt/backups # Specify backup location
  ```

- **find_replace** - Find and replace text in files
  ```bash
  find_replace "old text" "new text" # Current directory, all files
  find_replace "old text" "new text" ./src "*.py" # Python files in src
  ```

- **find_dupes** - Find duplicate files in a directory
  ```bash
  find_dupes # Current directory, min size 1k
  find_dupes /home/user/docs 10M # Docs directory, min size 10M
  ```

- **mkcd** - Create a directory and cd into it
  ```bash
  mkcd new_project # Creates and enters directory
  ```

- **extract** - Extract various archive formats
  ```bash
  extract archive.tar.gz # Auto-detects format and extracts
  ```

### Development Tools

- **set_git_prompt** - Set prompt with git branch information
  ```bash
  set_git_prompt # Updates PS1 with git branch info
  ```

- **gitstatus** - Show git repository status summary
  ```bash
  gitstatus # Shows branch, commit, changes, remote status
  ```

- **gitquick** - Quick commit and push changes
  ```bash
  gitquick "Fix bug in login form" # Add, commit, push
  ```

- **pyserver** - Run a Python HTTP server
  ```bash
  pyserver # Default port 8000
  pyserver 8080 # Custom port
  ```

- **genpassword** - Generate a random password
  ```bash
  genpassword # 16 chars with special chars
  genpassword 20 0 # 20 chars, no special chars
  ```

### Network Tools

- **portcheck** - Check if a port is open
  ```bash
  portcheck example.com 80 # Check if port 80 is open
  ```

- **portscan** - Scan common ports on a host
  ```bash
  portscan 192.168.1.1 # Scan ports 1-1024
  portscan example.com 80 100 # Scan ports 80-100
  ```

- **myip** - Get public IP address
  ```bash
  myip # Shows your public IP
  ```

- **netinfo** - Show network interface information
  ```bash
  netinfo # Shows interfaces, routes, DNS, public IP
  ```

### Productivity Tools

- **note** - Simple note-taking function
  ```bash
  note add Remember to update documentation # Add a note
  note list # List all notes
  note search documentation # Search notes
  note delete 3 # Delete note #3
  ```

- **todo** - Simple todo list function
  ```bash
  todo add Fix login bug # Add todo item
  todo list # List all items
  todo done 2 # Mark item #2 as done
  todo delete 3 # Delete item #3
  ```

- **timer** - Simple timer function
  ```bash
  timer 5m # 5-minute timer
  timer 1h30m "Break time!" # 1.5-hour timer with custom message
  ```

## Existing Functions Enhancements

- **add2path** - Added option to make PATH changes permanent
- **secure_rm_toggle** - Improved with clearer status messages
- **secure_clean** - Enhanced with more thorough cleaning options

## Dependencies

Some functions require additional tools:

- **encrypt_file/decrypt_file** - Requires OpenSSL
- **find_dupes** - Works best with fdupes installed
- **sysmonitor** - Uses standard Linux tools (top, free, df, netstat)
- **timer** - Sound notification works with paplay, spd-say, or say

## Customization

You can customize the behavior of certain functions by setting environment variables:

- **NOTES_DIR** - Directory for storing notes (default: ~/.notes)
- **TODO_FILE** - File for storing todo items (default: ~/.todo.txt)
- **SENTINEL_SECURE_RM** - Enable/disable secure deletion (default: 1)

3. Test dependency resolution with complex module trees
4. Consider adding a module repository feature
5. Implement automated testing for modules

### Codename: NIGHTHAWK
