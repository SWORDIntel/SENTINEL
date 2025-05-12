#!/usr/bin/env bash
# Test the new BLE.sh loader implementation

# Copy the loader function from install.sh
cat > /tmp/test_blesh_loader.sh << 'EOL'
#!/usr/bin/env bash
# SENTINEL BLE.sh Test Loader
# This is extracted from install.sh for testing

# Set strict error handling
set -o pipefail

# Define logging functions
_blesh_log() {
    local level="$1"
    local message="$2"
    echo "[BLE.sh $level] $message"
}

_blesh_debug() {
    [[ "${SENTINEL_BLESH_DEBUG:-1}" == "1" ]] && _blesh_log "DEBUG" "$1"
}

_blesh_info() {
    _blesh_log "INFO" "$1"
}

_blesh_warn() {
    _blesh_log "WARN" "$1" >&2
}

_blesh_error() {
    _blesh_log "ERROR" "$1" >&2
}

# Clean up BLE.sh cache and lock files
_blesh_cleanup() {
    _blesh_debug "Running cleanup routine"
    
    if [[ -d "${HOME}/.cache/blesh" ]]; then
        # Fix permissions
        chmod -R 755 "${HOME}/.cache/blesh" 2>/dev/null
        
        # Remove lock files
        find "${HOME}/.cache/blesh" -name "*.lock" -type f -delete 2>/dev/null
        
        # Remove incomplete download files
        find "${HOME}/.cache/blesh" -name "*.part" -type f -delete 2>/dev/null
        
        # Remove any problematic cache files
        find "${HOME}/.cache/blesh" -name "decode.readline.*.txt*" -type f -delete 2>/dev/null
    fi
}

# BLE.sh loading methods
_blesh_load_direct() {
    _blesh_debug "Attempting direct source method"
    # Direct source method
    if source "${HOME}/.local/share/blesh/ble.sh" 2>/dev/null; then
        _blesh_debug "Direct source successful"
        return 0
    fi
    return 1
}

_blesh_load_cat() {
    _blesh_debug "Attempting cat source method"
    # Use cat to avoid issues with shell interpolation
    if source <(cat "${HOME}/.local/share/blesh/ble.sh") 2>/dev/null; then
        _blesh_debug "Cat source successful"
        return 0
    fi
    return 1
}

_blesh_load_eval() {
    _blesh_debug "Attempting eval method"
    # Last resort method using eval
    if eval "$(cat "${HOME}/.local/share/blesh/ble.sh")" 2>/dev/null; then
        _blesh_debug "Eval method successful"
        return 0
    fi
    return 1
}

# Configure BLE.sh settings
_blesh_configure() {
    _blesh_debug "Configuring BLE.sh settings"
    
    # Core settings - these are confirmed to exist
    bleopt complete_auto_delay=100
    bleopt complete_auto_complete=1
    bleopt complete_menu_complete=1
    
    # Appearance - syntax highlighting is available
    bleopt highlight_syntax=1
    bleopt highlight_filename=1
    bleopt highlight_variable=1
    
    # Menu settings
    bleopt complete_menu_style=align-nowrap
    bleopt complete_menu_color=on
    
    # Key bindings - needs to be updated to check if ble-bind exists
    ble-bind -m auto_complete -f right 'auto_complete/accept-line' 2>/dev/null || true
    
    _blesh_debug "Configuration complete"
    return 0
}

# Main BLE.sh loader function
load_blesh() {
    # Run cleanup first
    _blesh_cleanup
    
    # Check if BLE.sh exists
    if [[ -f "${HOME}/.local/share/blesh/ble.sh" ]]; then
        _blesh_debug "Found BLE.sh installation"
        
        # Try all loading methods
        if _blesh_load_direct || _blesh_load_cat || _blesh_load_eval; then
            _blesh_info "BLE.sh loaded successfully"
            _blesh_configure
            return 0
        else
            _blesh_error "All loading methods failed"
            return 1
        fi
    else
        _blesh_error "BLE.sh not found"
        return 1
    fi
}

# Load BLE.sh
load_blesh
EOL

chmod +x /tmp/test_blesh_loader.sh

# Run the test loader
echo "Testing new BLE.sh loader implementation..."
source /tmp/test_blesh_loader.sh

echo
echo "Done testing - check for any errors above." 