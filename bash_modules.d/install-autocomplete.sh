#!/usr/bin/env bash
# SENTINEL Autocomplete Installation Script
# Version: 2.0.0
# This script installs the modular autocomplete system and migrates from the monolithic version

set -e

# Banner function
_print_banner() {
    echo -e "\e[1;34m"
    echo "  ____  _____ _   _ _____ ___ _   _ _____ _"
    echo " / ___|| ____| \ | |_   _|_ _| \ | | ____| |"
    echo " \___ \|  _| |  \| | | |  | ||  \| |  _| | |"
    echo "  ___) | |___| |\  | | |  | || |\  | |___|_|"
    echo " |____/|_____|_| \_| |_| |___|_| \_|_____(_)"
    echo -e "\e[0m"
    echo -e "\e[1;32mAutocomplete System Installation\e[0m"
    echo -e "\e[1;32m==============================\e[0m"
    echo ""
}

# Helper functions
_info() {
    echo -e "\e[1;34m[INFO]\e[0m $1"
}

_success() {
    echo -e "\e[1;32m[SUCCESS]\e[0m $1"
}

_warning() {
    echo -e "\e[1;33m[WARNING]\e[0m $1"
}

_error() {
    echo -e "\e[1;31m[ERROR]\e[0m $1" >&2
}

# Ask for confirmation
_confirm() {
    local prompt="$1"
    local default="${2:-y}"
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi
    
    read -p "$prompt" response
    response=${response,,}  # Convert to lowercase
    
    if [[ -z "$response" ]]; then
        response=$default
    fi
    
    [[ "$response" =~ ^(y|yes)$ ]]
}

# Check command exists
_check_command() {
    command -v "$1" >/dev/null 2>&1
}

# Get script directory
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$SCRIPT_DIR/.."
ALIASES_DIR="$REPO_ROOT/bash_aliases.d"

_print_banner

# System check
_info "Performing system checks..."
if ! _check_command bash; then
    _error "Bash is required for SENTINEL Autocomplete"
    exit 1
fi

if ! _check_command openssl; then
    _warning "OpenSSL not found - some security features may be limited"
fi

# Verify required directories
if [[ ! -d "$ALIASES_DIR" ]]; then
    _error "SENTINEL bash_aliases.d directory not found: $ALIASES_DIR"
    _error "Please ensure you're running this script from the SENTINEL repository"
    exit 1
fi

# Verify required files
required_modules=(
    "$MODULES_DIR/autocomplete.module"
    "$MODULES_DIR/logging.module"
    "$MODULES_DIR/ble_manager.module"
    "$MODULES_DIR/hmac.module"
    "$MODULES_DIR/snippets.module"
    "$MODULES_DIR/fuzzy_correction.module"
    "$MODULES_DIR/command_chains.module"
)

missing_files=0
for file in "${required_modules[@]}"; do
    if [[ ! -f "$file" ]]; then
        _error "Required module not found: $file"
        missing_files=$((missing_files + 1))
    fi
done

if [[ $missing_files -gt 0 ]]; then
    _error "$missing_files required module(s) missing. Cannot continue."
    exit 1
fi

# Check if wrapper file exists
if [[ ! -f "$ALIASES_DIR/autocomplete.new" ]]; then
    _error "Wrapper file not found: $ALIASES_DIR/autocomplete.new"
    _error "Please ensure the wrapper file is in place"
    exit 1
fi

# Check for existing autocomplete file
if [[ -f "$ALIASES_DIR/autocomplete" ]]; then
    _info "Existing autocomplete file found"
    
    # Create backup directory if it doesn't exist
    mkdir -p ~/.sentinel/backup
    
    # Check if backup already exists
    if [[ -f ~/.sentinel/backup/autocomplete ]]; then
        backup_timestamp=$(date +%Y%m%d%H%M%S)
        _info "Previous backup found, creating timestamped backup: autocomplete.$backup_timestamp"
        cp "$ALIASES_DIR/autocomplete" ~/.sentinel/backup/autocomplete.$backup_timestamp
    else
        _info "Creating backup at ~/.sentinel/backup/autocomplete"
        cp "$ALIASES_DIR/autocomplete" ~/.sentinel/backup/autocomplete
    fi
    
    # Create legacy directory for backward compatibility
    mkdir -p ~/.sentinel/legacy
    cp "$ALIASES_DIR/autocomplete" ~/.sentinel/legacy/autocomplete
    
    # Confirm replacement
    if _confirm "Replace existing autocomplete with the new modular version?"; then
        _info "Installing modular autocomplete system..."
        
        # Move the new file into place
        mv "$ALIASES_DIR/autocomplete.new" "$ALIASES_DIR/autocomplete"
        chmod +x "$ALIASES_DIR/autocomplete"
        
        _success "Modular autocomplete system installed!"
        _info "The previous version is available in legacy mode: source ~/.sentinel/legacy/autocomplete"
        _info "or by using: @autocomplete --legacy-mode"
    else
        _warning "Installation cancelled by user"
        exit 0
    fi
else
    _warning "No existing autocomplete file found. Installing fresh..."
    
    # Move the new file into place
    mv "$ALIASES_DIR/autocomplete.new" "$ALIASES_DIR/autocomplete"
    chmod +x "$ALIASES_DIR/autocomplete"
    
    _success "Modular autocomplete system installed!"
fi

# Create README document
_info "Creating documentation..."
cat > "$MODULES_DIR/README.md" << 'EOF'
# SENTINEL Modular Autocomplete System

The SENTINEL Autocomplete System has been redesigned with a modular architecture to improve:

- Maintainability
- Debugging capabilities
- Extensibility
- Security

## Module Structure

The system is organized into the following modules:

- **autocomplete.module**: Main orchestration module
- **hmac.module**: Security module for cryptographic functions
- **snippets.module**: Secure command snippet storage and expansion
- **fuzzy_correction.module**: Intelligent command correction
- **command_chains.module**: Command prediction based on usage patterns

## Features

1. **Secure HMAC Verification**
   - Cryptographically signed tokens and snippets
   - Protection against tampering
   - Secure key management

2. **Intelligent Command Correction**
   - Suggests corrections for mistyped commands
   - Levenshtein distance calculations
   - Quick fix commands (`!!:fix`)

3. **Context-Aware Suggestions**
   - Project type detection (Python, Node.js, Rust, etc.)
   - Framework-specific suggestions
   - Directory context awareness

4. **Command Chain Prediction**
   - Predicts likely next commands
   - Based on command usage patterns
   - Quick execution with `!!:next`

5. **Secure Snippet Management**
   - Cryptographically verified snippets
   - Protection against accidental or malicious changes
   - Easy snippet management

## Usage

The primary interface remains the same:

- `@autocomplete`: Show help
- `@autocomplete status`: Show system status
- `@autocomplete fix`: Fix common issues
- `@autocomplete reload`: Reload BLE.sh
- `@autocomplete install`: Force reinstall BLE.sh

## Legacy Support

The previous monolithic version is still available in legacy mode:

```bash
@autocomplete --legacy-mode
```

## Extending

To create a new module:

1. Create a file named `your_feature.module` in the suggestions directory
2. Follow the module template pattern
3. Add the module to the loading list in `autocomplete.module`

## Security Considerations

The modular design uses HMAC verification to ensure integrity of:

- Stored snippets
- Command corrections
- Secure tokens

This helps prevent tampering and reduces the risk of command injection attacks.
EOF

_success "Documentation created at $MODULES_DIR/README.md"

# Installation complete
_success "Installation complete!"
_info "To start using the new autocomplete system:"
_info "1. Close and reopen your terminal, or"
_info "2. Run: source $ALIASES_DIR/autocomplete"
_info ""
_info "Use '@autocomplete' for help and available commands"
_info "Use '@autocomplete logs' to view diagnostic logs if needed"

exit 0 