#!/usr/bin/env bash
# SENTINEL BLE.sh Module
# Handles installation, configuration, and management of BLE.sh (Bash Line Editor)
# This module is part of the SENTINEL autocomplete system
# Version: 1.0.0

# Module information
BLESH_MODULE_VERSION="1.0.0"
BLESH_MODULE_DESCRIPTION="BLE.sh management module for SENTINEL"
BLESH_MODULE_AUTHOR="SENTINEL Team"

# Ensure log directory exists
mkdir -p ~/.sentinel/logs

# Logging functions
_blesh_log_error() {
    local msg="$1"
    mkdir -p ~/.sentinel/logs
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $msg" >> ~/.sentinel/logs/blesh-$(date +%Y%m%d).log
}

_blesh_log_info() {
    local msg="$1"
    mkdir -p ~/.sentinel/logs
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $msg" >> ~/.sentinel/logs/blesh-$(date +%Y%m%d).log
}

_blesh_log_warning() {
    local msg="$1"
    mkdir -p ~/.sentinel/logs
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $msg" >> ~/.sentinel/logs/blesh-$(date +%Y%m%d).log
}

# Main installation and check function for BLE.sh
sentinel_check_blesh() {
    # Create sentinel directory if it doesn't exist yet
    mkdir -p ~/.sentinel/autocomplete
    _blesh_log_info "Checking BLE.sh installation"

    if ! command -v blesh &>/dev/null; then
        echo "Installing ble.sh (Bash Line Editor) for advanced autocompletion..."
        _blesh_log_info "BLE.sh not found, starting installation"
        
        # Clean up existing installations
        echo "Cleaning up any existing ble.sh directories..."
        (
            # Find and remove existing blesh directories in a background subshell
            find /tmp -maxdepth 1 -type d -name "blesh*" 2>/dev/null | 
            while read -r dir; do
                echo "Removing $dir..."
                _blesh_log_info "Removing temporary directory: $dir"
                find "$dir" -type f -name "*.lock" -delete 2>/dev/null || true
                find "$dir" -type f -not -readable -exec chmod +r {} \; 2>/dev/null || true
                chmod -R 755 "$dir" 2>/dev/null || true
                rm -rf "$dir" 2>/dev/null || true
            done
        ) &
        
        # Use a unique timestamp-based temporary directory
        local tmp_dir="/tmp/blesh_$$_$(date +%s)"
        
        # Clone and install ble.sh
        echo "Cloning ble.sh to $tmp_dir..."
        _blesh_log_info "Cloning BLE.sh repository to $tmp_dir"
        if git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git "$tmp_dir" 2>/dev/null; then
            mkdir -p ~/.local/share/blesh
            
            echo "Compiling and installing ble.sh..."
            _blesh_log_info "Compiling and installing BLE.sh"
            # Capture both stdout and stderr from make to the log file
            if make -C "$tmp_dir" install PREFIX=~/.local > /tmp/blesh_make.log 2>&1; then
                echo "ble.sh installation successful."
                _blesh_log_info "BLE.sh installation successful"
            else
                echo "Error during ble.sh compilation. See /tmp/blesh_make.log for details."
                _blesh_log_error "BLE.sh compilation failed. See /tmp/blesh_make.log for details"
                rm -rf "$tmp_dir" 2>/dev/null || true
                return 1
            fi
            
            # Clean up temporary directory and handle errors gracefully
            if ! rm -rf "$tmp_dir" 2>/dev/null; then
                echo "Warning: Could not remove temporary directory $tmp_dir."
                echo "Scheduling cleanup for next login."
                _blesh_log_warning "Could not remove temporary directory $tmp_dir, scheduling cleanup"
                
                # Create a cleanup script with safeguards against path errors
                _blesh_create_cleanup_script "$tmp_dir"
            fi
            
            # Create improved loader with better error handling and fallbacks
            _blesh_create_loader_script
            
            # Try to source the loader immediately for this session
            source ~/.sentinel/blesh_loader.sh || true
            
        else
            echo "Failed to clone ble.sh repository. Advanced autocompletion will be limited."
            _blesh_log_error "Failed to clone BLE.sh repository"
            # Clean up in background
            (chmod -R 755 /tmp/blesh* 2>/dev/null; rm -rf /tmp/blesh* 2>/dev/null) &
        fi
    elif [[ -f ~/.local/share/blesh/ble.sh ]]; then
        # ble.sh installed but needs loading
        mkdir -p ~/.cache/blesh 2>/dev/null
        chmod 755 ~/.cache/blesh 2>/dev/null
        _blesh_log_info "BLE.sh is installed but not loaded"
        
        # Load ble.sh if not already loaded
        if ! type -t ble-bind &>/dev/null; then
            echo "ble.sh installed but not loaded. Loading now..."
            
            # Check for and create loader if needed
            if [[ ! -f ~/.sentinel/blesh_loader.sh ]]; then
                _blesh_log_info "Creating BLE.sh loader script"
                # Create improved loader
                _blesh_create_loader_script
            fi
            
            # Source the loader
            source ~/.sentinel/blesh_loader.sh || true
        fi
    fi
}

# Create the cleanup script for BLE.sh temporary directories
_blesh_create_cleanup_script() {
    local tmp_dir="$1"
    _blesh_log_info "Creating cleanup script for BLE.sh temporary directories"
    
    cat > ~/.sentinel/cleanup_blesh.sh << 'EOF'
#!/bin/bash
# Safety check for non-empty path
clean_dir() {
    local dir="$1"
    [[ -z "$dir" || "$dir" == "/" || "$dir" == "/tmp" ]] && return 1
    [[ -d "$dir" ]] || return 0
    
    chmod -R 755 "$dir" 2>/dev/null
    rm -rf "$dir" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        echo "Cleaned up $dir successfully."
        return 0
    else
        echo "Failed to clean up $dir."
        return 1
    fi
}

# Clean specified directories
for dir in "$@"; do
    clean_dir "$dir"
done

# Also try to clean up any orphaned blesh directories
find /tmp -maxdepth 1 -type d -name "blesh*" -mtime +1 2>/dev/null | 
while read -r old_dir; do
    clean_dir "$old_dir"
done

# Remove self after running
[[ -f "$0" ]] && rm -f "$0"
EOF
    chmod +x ~/.sentinel/cleanup_blesh.sh
    
    # Schedule cleanup with specific paths
    echo "$tmp_dir /tmp/blesh" > ~/.sentinel/blesh_cleanup_paths
}

# Create the loader script for BLE.sh with enhanced error recovery
_blesh_create_loader_script() {
    _blesh_log_info "Creating BLE.sh loader script with enhanced error recovery"
    
    cat > ~/.sentinel/blesh_loader.sh << 'EOF'
#!/usr/bin/env bash
# SENTINEL ble.sh integration loader with enhanced error recovery
# v1.1.0

# Set error handling and debugging options
set -o pipefail
export _ble_suppress_stderr=1

# Helper function for ble.sh loading attempts
_sentinel_load_attempt() {
    local method="$1"
    echo "Attempting to load ble.sh using $method method..."
    
    case "$method" in
        direct)
            source ~/.local/share/blesh/ble.sh 2>/dev/null
            ;;
        cat)
            source <(cat ~/.local/share/blesh/ble.sh) 2>/dev/null
            ;;
        eval)
            eval "$(cat ~/.local/share/blesh/ble.sh)" 2>/dev/null
            ;;
    esac
    
    # Check if loading was successful
    if type -t ble-bind &>/dev/null; then
        echo "ble.sh loaded successfully using $method method."
        return 0
    fi
    return 1
}

# Ensure cache directory exists with proper permissions
mkdir -p ~/.cache/blesh 2>/dev/null
chmod 755 ~/.cache/blesh 2>/dev/null

# Clean up any lock files that might cause issues
find ~/.cache/blesh -name "*.lock" -delete 2>/dev/null
find ~/.cache/blesh -name "*.part" -delete 2>/dev/null
find ~/.cache/blesh -name "decode.readline*.txt*" -type f -delete 2>/dev/null

# Check if ble.sh exists
if [[ -f ~/.local/share/blesh/ble.sh ]]; then
    # Try each loading method in sequence until one works
    if _sentinel_load_attempt "direct" ||
       _sentinel_load_attempt "cat" ||
       _sentinel_load_attempt "eval"; then
        # Success - initialize key features
        bleopt complete_auto_delay=100 2>/dev/null
        bleopt complete_auto_complete=1 2>/dev/null
        bleopt highlight_auto_completion='fg=242' 2>/dev/null
    else
        echo "Warning: All methods to load ble.sh failed. Using basic autocompletion instead."
        # Load bash standard completion as fallback
        [[ -f /etc/bash_completion ]] && source /etc/bash_completion
    fi
else
    echo "Warning: ble.sh not found at ~/.local/share/blesh/ble.sh"
    [[ -f /etc/bash_completion ]] && source /etc/bash_completion
fi

# Run pending cleanup if needed
if [[ -f ~/.sentinel/cleanup_blesh.sh && -f ~/.sentinel/blesh_cleanup_paths ]]; then
    echo "Running pending blesh cleanup tasks..."
    ~/.sentinel/cleanup_blesh.sh $(cat ~/.sentinel/blesh_cleanup_paths)
    rm -f ~/.sentinel/blesh_cleanup_paths
fi
EOF
    chmod +x ~/.sentinel/blesh_loader.sh
}

# Cleanup function for BLE.sh directories
sentinel_cleanup_blesh_dirs() {
    _blesh_log_info "Running BLE.sh directory cleanup"
    local dirs=($(find /tmp -maxdepth 1 -type d -name "blesh*" -mtime +1 2>/dev/null))
    if [[ ${#dirs[@]} -gt 0 ]]; then
        echo "Cleaning up orphaned ble.sh installation directories..."
        for dir in "${dirs[@]}"; do
            _blesh_log_info "Removing orphaned directory: $dir"
            chmod -R 755 "$dir" 2>/dev/null
            rm -rf "$dir" 2>/dev/null && 
                echo "Removed $dir" || 
                echo "Failed to remove $dir"
        done
    fi
    
    # Clean BLE.sh cache files that might cause issues
    if [[ -d ~/.cache/blesh ]]; then
        _blesh_log_info "Cleaning BLE.sh cache files"
        find ~/.cache/blesh -name "*.part" -type f -delete 2>/dev/null
        find ~/.cache/blesh -name "*.lock" -type f -delete 2>/dev/null
        find ~/.cache/blesh -name "decode.readline*.txt*" -type f -delete 2>/dev/null
    fi
    
    # Run cleanup script if it exists
    if [[ -f ~/.sentinel/cleanup_blesh.sh ]]; then
        _blesh_log_info "Running pending cleanup tasks"
        echo "Running pending cleanup tasks..."
        bash ~/.sentinel/cleanup_blesh.sh
    fi
}

# Function to fix common BLE.sh issues
sentinel_fix_blesh() {
    echo "Fixing common BLE.sh issues..."
    _blesh_log_info "Running BLE.sh fix procedure"
    
    # Fix cache directory permissions
    mkdir -p ~/.cache/blesh 2>/dev/null
    chmod 755 ~/.cache/blesh 2>/dev/null
    echo "✓ Fixed cache directory permissions"
    
    # Clean up problematic cache files
    find ~/.cache/blesh -name "*.part" -type f -delete 2>/dev/null
    find ~/.cache/blesh -name "*.lock" -type f -delete 2>/dev/null
    find ~/.cache/blesh -name "decode.readline*.txt*" -type f -delete 2>/dev/null
    echo "✓ Cleaned up cache files"
    
    # Clean up temporary installation directories
    sentinel_cleanup_blesh_dirs
    echo "✓ Cleaned up temporary installation directories"
    
    # Reload BLE.sh if available
    if [[ -f ~/.local/share/blesh/ble.sh ]]; then
        export _ble_suppress_stderr=1
        source ~/.local/share/blesh/ble.sh 2>/dev/null || true
        echo "✓ Reloaded BLE.sh"
    fi
    
    # Update the loader script
    _blesh_create_loader_script
    echo "✓ Updated loader script"
    
    echo -e "\nAll issues fixed. Please \033[1;32mclose and reopen your terminal\033[0m for changes to take full effect."
    _blesh_log_info "BLE.sh fix procedure completed"
}

# Function to check BLE.sh status
sentinel_blesh_status() {
    echo -e "\033[1;32mBLE.sh Status:\033[0m"
    _blesh_log_info "Checking BLE.sh status"
    
    # Check installation
    echo -n "Installation: "
    if [[ -f ~/.local/share/blesh/ble.sh ]]; then
        echo -e "\033[1;32mInstalled\033[0m"
        
        # Get version if possible
        local version=$(grep -E "^_ble_version=" ~/.local/share/blesh/ble.sh 2>/dev/null | cut -d'"' -f2)
        if [[ -n "$version" ]]; then
            echo "Version: $version"
        fi
    else
        echo -e "\033[1;31mNot installed\033[0m"
    fi
    
    # Check if loaded
    echo -n "Loaded: "
    if type -t ble-bind &>/dev/null; then
        echo -e "\033[1;32mYes\033[0m"
    else
        echo -e "\033[1;31mNo\033[0m"
    fi
    
    # Check loader script
    echo -n "Loader script: "
    if [[ -f ~/.sentinel/blesh_loader.sh ]]; then
        echo -e "\033[1;32mExists\033[0m"
    else
        echo -e "\033[1;31mMissing\033[0m"
    fi
    
    # Check cache directory
    echo -n "Cache directory: "
    if [[ -d ~/.cache/blesh ]]; then
        local perms=$(stat -c "%a" ~/.cache/blesh 2>/dev/null)
        if [[ "$perms" == "755" ]]; then
            echo -e "\033[1;32mOK (permissions: $perms)\033[0m"
        else
            echo -e "\033[1;33mWarning (permissions: $perms, should be 755)\033[0m"
        fi
    else
        echo -e "\033[1;31mMissing\033[0m"
    fi
    
    # Check for problematic files
    local lock_files=$(find ~/.cache/blesh -name "*.lock" 2>/dev/null | wc -l)
    local part_files=$(find ~/.cache/blesh -name "*.part" 2>/dev/null | wc -l)
    
    if [[ $lock_files -gt 0 || $part_files -gt 0 ]]; then
        echo -e "\033[1;33mProblematic cache files: $lock_files lock files, $part_files part files\033[0m"
        echo "Run 'sentinel_fix_blesh' to clean up these files"
    else
        echo -e "Cache files: \033[1;32mClean\033[0m"
    fi
    
    _blesh_log_info "BLE.sh status check completed"
}

# Function to reload BLE.sh
sentinel_reload_blesh() {
    echo "Reloading BLE.sh..."
    _blesh_log_info "Reloading BLE.sh"
    
    # Unset any existing BLE.sh variables
    for var in $(set | grep -E "^_ble_" | cut -d= -f1); do
        unset "$var" 2>/dev/null
    done
    
    # Export to suppress stderr
    export _ble_suppress_stderr=1
    
    if [[ -f ~/.sentinel/blesh_loader.sh ]]; then
        source ~/.sentinel/blesh_loader.sh
        echo "BLE.sh reloaded using loader script."
        _blesh_log_info "BLE.sh reloaded using loader script"
    elif [[ -f ~/.local/share/blesh/ble.sh ]]; then
        source ~/.local/share/blesh/ble.sh 2>/dev/null
        echo "BLE.sh reloaded directly."
        _blesh_log_info "BLE.sh reloaded directly"
    else
        echo "BLE.sh not found. Run 'sentinel_check_blesh' to install."
        _blesh_log_warning "BLE.sh not found during reload attempt"
    fi
}

# Function to force reinstall BLE.sh
sentinel_reinstall_blesh() {
    echo "Reinstalling BLE.sh..."
    _blesh_log_info "Starting BLE.sh reinstallation"
    
    # Remove existing installation
    rm -rf ~/.local/share/blesh 2>/dev/null
    rm -f ~/.sentinel/blesh_loader.sh 2>/dev/null
    
    # Clean cache
    rm -rf ~/.cache/blesh 2>/dev/null
    mkdir -p ~/.cache/blesh
    chmod 755 ~/.cache/blesh
    
    # Run installation
    sentinel_check_blesh
    
    echo "BLE.sh reinstallation complete. Please restart your terminal."
    _blesh_log_info "BLE.sh reinstallation completed"
}

# Export functions for use in other modules
export -f sentinel_check_blesh
export -f sentinel_cleanup_blesh_dirs
export -f sentinel_fix_blesh
export -f sentinel_blesh_status
export -f sentinel_reload_blesh
export -f sentinel_reinstall_blesh

# Log module loading
_blesh_log_info "BLE.sh module loaded successfully"
echo "SENTINEL BLE.sh Module v${BLESH_MODULE_VERSION} loaded" 